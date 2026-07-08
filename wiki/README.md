# TypeManager Wiki Drafts

These files are drafts for the standalone GitHub Wiki.

The repository workflow at `.github/workflows/sync-wiki.yml` publishes these pages to:

```txt
https://github.com/Kooraseru/TypeManager.wiki.git
```

It runs when `wiki/**` changes on `main` or `master`, and it can also be run manually from GitHub Actions.

Manual fallback:

```bash
git clone git@github.com:Kooraseru/TypeManager.wiki.git
cp wiki/*.md TypeManager.wiki/
cd TypeManager.wiki
git add .
git commit -m "Add TypeManager wiki"
git push
```

> [!IMPORTANT]
> Do not copy this `README.md` into the wiki unless you want it as an internal maintenance page. The wiki landing page should be `Home.md`.
