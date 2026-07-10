# Changelog

All notable Arbor package changes are constructed from release notes.

<!-- This file is constructed from release-notes/Stable/*.md and release-notes/Pre-release/*.md. Do not edit it by hand. -->

## v1.0.1 - 2026-07-09

### Stable

#### Summary

First stable Arbor release, focused on typed access to analyzer-visible Roblox
instance trees.

#### Changes

- Added direct child-name and child-record helpers.
- Added class-filtered child helpers.
- Added validated loading for direct `ModuleScript` children.
- Added the `Arbor.rbxm` release asset.

#### Notes

- `v1.0.0` was taken from us by GitHub's poorly written **Enable release immutability** setting. 2026-2026. (somber music)
- Arbor depends on what the active Luau analyzer can see in the Roblox data model.
- Runtime loading still requires validation at the dynamic boundary.
