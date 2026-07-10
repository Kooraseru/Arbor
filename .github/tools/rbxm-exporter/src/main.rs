use std::{
    collections::HashSet,
    env,
    error::Error,
    fs::{self, File},
    io::{BufReader, BufWriter},
    path::{Path, PathBuf},
};

use rbx_dom_weak::{types::Variant, InstanceBuilder, WeakDom};

fn main() -> Result<(), Box<dyn Error>> {
    let mut args = env::args().skip(1);

    if matches!(args.next().as_deref(), Some("verify")) {
        let model_path = PathBuf::from(
            args.next()
                .unwrap_or_else(|| ".tmp/results/export/rbxm-export/result/Arbor.rbxm".to_owned()),
        );
        let package_name = args.next().unwrap_or_else(|| "Arbor".to_owned());
        return verify_model(&model_path, &package_name);
    }

    let mut args = env::args().skip(1);
    let source_root = PathBuf::from(args.next().unwrap_or_else(|| "src".to_owned()));
    let output_path = PathBuf::from(
        args.next()
            .unwrap_or_else(|| ".tmp/results/export/rbxm-export/result/Arbor.rbxm".to_owned()),
    );
    let package_name = args.next().unwrap_or_else(|| "Arbor".to_owned());

    if !source_root.is_dir() {
        return Err(format!("source root is not a directory: {}", source_root.display()).into());
    }

    let init_path = source_root.join("init.luau");
    if !init_path.is_file() {
        return Err(format!("source root is missing init.luau: {}", init_path.display()).into());
    }

    if let Some(parent) = output_path.parent() {
        fs::create_dir_all(parent)?;
    }

    let root_source = fs::read_to_string(&init_path)?;
    let mut dom = WeakDom::new(module_script(&package_name, root_source));
    let root_ref = dom.root_ref();
    insert_children(&mut dom, root_ref, &source_root)?;

    let output = BufWriter::new(File::create(&output_path)?);
    rbx_binary::to_writer(output, &dom, &[root_ref])?;

    println!("RBXM export OK: {}", output_path.display());

    Ok(())
}

fn insert_children(
    dom: &mut WeakDom,
    parent_ref: rbx_dom_weak::types::Ref,
    directory: &Path,
) -> Result<(), Box<dyn Error>> {
    for entry in sorted_entries(directory)? {
        let path = entry.path();
        let name = entry.file_name().to_string_lossy().into_owned();

        if path.is_dir() {
            let folder_ref = dom.insert(parent_ref, InstanceBuilder::new("Folder").with_name(name));
            insert_children(dom, folder_ref, &path)?;
            continue;
        }

        if !path.is_file() || name == "init.luau" {
            continue;
        }

        if let Some(module_name) = module_name_from_path(&path) {
            let source = fs::read_to_string(&path)?;
            dom.insert(parent_ref, module_script(&module_name, source));
        }
    }

    Ok(())
}

fn sorted_entries(directory: &Path) -> Result<Vec<fs::DirEntry>, Box<dyn Error>> {
    let mut entries = fs::read_dir(directory)?.collect::<Result<Vec<_>, _>>()?;
    entries.sort_by_key(|entry| entry.file_name());
    Ok(entries)
}

fn module_name_from_path(path: &Path) -> Option<String> {
    match path.extension().and_then(|extension| extension.to_str()) {
        Some("luau") | Some("lua") => path
            .file_stem()
            .map(|stem| stem.to_string_lossy().into_owned()),
        _ => None,
    }
}

fn module_script(name: &str, source: String) -> InstanceBuilder {
    InstanceBuilder::new("ModuleScript")
        .with_name(name)
        .with_property("Source", Variant::String(source))
}

fn verify_model(model_path: &Path, package_name: &str) -> Result<(), Box<dyn Error>> {
    let input = BufReader::new(File::open(model_path)?);
    let dom = rbx_binary::from_reader(input)?;
    let dom_root = dom
        .get_by_ref(dom.root_ref())
        .ok_or("RBXM root instance was not found")?;
    let root = if dom_root.class == "DataModel" {
        let root_ref = dom_root
            .children()
            .first()
            .ok_or("RBXM DataModel did not contain a model root")?;
        dom.get_by_ref(*root_ref)
            .ok_or("RBXM model root instance was not found")?
    } else {
        dom_root
    };

    if root.class != "ModuleScript" {
        return Err(format!("expected root class ModuleScript, got {}", root.class).into());
    }

    if root.name != package_name {
        return Err(format!("expected root name {package_name}, got {}", root.name).into());
    }

    let has_source = root
        .properties
        .iter()
        .any(|(name, value)| name.as_str() == "Source" && matches!(value, Variant::String(_)));

    if !has_source {
        return Err("expected root Source property to be present".into());
    }

    let child_names = root
        .children()
        .iter()
        .filter_map(|child_ref| dom.get_by_ref(*child_ref))
        .map(|child| child.name.as_str())
        .collect::<HashSet<_>>();

    for expected_child in ["InstanceTree", "RuntimeLoaders"] {
        if !child_names.contains(expected_child) {
            return Err(format!("expected root child {expected_child}").into());
        }
    }

    println!("RBXM verify OK: {}", model_path.display());

    Ok(())
}
