# Arbor Docs Site

This folder is a Jekyll source folder for GitHub Pages.

Do not open files in `_layouts/` directly in a browser. They contain Liquid templates such as `{{ content }}` that only render after Jekyll builds the site.

GitHub Pages builds the site through:

```txt
.github/workflows/pages.yml
```

Local preview, if Ruby and Bundler are installed:

```bash
bundle exec jekyll serve --source docs
```

Then open the local Jekyll URL, not `docs/_layouts/default.html`.
