# Arbor Wiki Drafts

These files are drafts for the standalone GitHub Wiki.

Each `*.md` file in this folder becomes a wiki page, except this maintenance `README.md`.

The repository workflow at `.github/workflows/sync-wiki.yml` publishes these pages to:

```txt
https://github.com/Kooraseru/Arbor.wiki.git
```

It runs when `wiki/**` changes on `main` or `master`, and it can also be run manually from GitHub Actions.

Manual fallback:

```bash
git clone git@github.com:Kooraseru/Arbor.wiki.git
cp wiki/*.md Arbor.wiki/
cd Arbor.wiki
git add .
git commit -m "Add Arbor wiki"
git push
```

> [!IMPORTANT]
> Do not copy this `README.md` into the wiki unless you want it as an internal maintenance page. The wiki landing page should be `Home.md`.
