# Versioning and local releases

The central `VERSION` file contains the numeric version, currently `0.1.7`. The display label is `alpha` while the project remains in its alpha phase. The menu, archive name, packaged VERSION and release documentation receive the same number automatically.

## Normal next release

From the project folder in PowerShell:

```powershell
.\release.ps1 -Bump patch
```

From 0.1.7 this produces alpha 0.1.8. It verifies the current base manifest, builds the versioned menu from the original game file, packages a complete ZIP, checks all archive contents, updates VERSION and the root README, and then removes older release artifacts. It does not install the game files or publish online.

To preview the next number without changing anything:

```powershell
.\release.ps1 -Bump patch -Preview
```

Other choices:

```powershell
.\release.ps1 -Bump minor
.\release.ps1 -Version 0.2.0
.\release.ps1 -Bump patch -KeepPrevious
```

Use either Bump or Version. Existing published versions are not overwritten; decreasing the version is rejected. Alternatively, edit VERSION to a higher numeric version and run `.\release.ps1` without arguments. `-KeepPrevious` disables automatic old-release cleanup.

## Including reviewed mod changes

Prepare and validate the changed files first in a directory containing a `mods` subfolder. Then use:

```powershell
.\release.ps1 -Bump patch -Overlay .\dist\reviewed-changes
```

The complete previous payload is retained and those files are overlaid. The versioned title menu is always rebuilt, so an overlay cannot replace its generated version label. Unrelated payload hashes must remain unchanged. This combines whole files, not conflicting edits inside the same game package. Review compression/model details in the source validation for changed binders; the packaging script does not infer their internal model counts.

Before a release, update `docs/release/README.md` and `docs/release/CHANGES-AND-TESTS.md` for substantive changes. Preserve `{{VERSION}}` and `{{PAYLOAD_COUNT}}` placeholders. Historical report versions should remain historical rather than being globally replaced.

## Local requirements and recovery

- Python 3.11 or later. The wrapper prefers the existing bundled runtime and otherwise uses `python` from PATH.
- The latest complete release under `releases/`, with a matching file manifest. A source-only clone is not a clean-room build of game assets.
- The original unpacked Sekiro `menu/05_000_title.gfx` at the local path used by `work/title-menu/build_title_label.py`.
- Failed builds retain the previous release and may leave `work/release-staging/<release-name>` for inspection. Resolve the cause and remove only that failed staging directory/ZIP before retrying; the script deliberately refuses to overwrite it.
- Installation is separate. For a menu-only update with an otherwise identical installed payload, run `work/title-menu/install.ps1` with Sekiro closed and appropriate filesystem permission. For a release with other changes, install the full `mods/` folder following the release README.

## Publishing alpha 0.1.7

The distributable is `releases/Nicky-Allowed-Invisible-Centipedes-alpha-0.1.7.zip`. It contains 29 mod files plus four documentation/metadata files. Upload that ZIP, not the whole workspace or an intermediate test folder.

On Nexus Mods, use the Sekiro game section, version `0.1.7`, and identify the upload as an alpha. Declare Sekiro Mod Engine as the loading requirement and retain accurate scope information: Long-arm is preserved and this is not proven full-game coverage. The [official author guidance](https://help.nexusmods.com/article/136-best-practices-for-mod-authors) describes file presentation and maintenance.

On GitHub, commit the authored source/docs while retaining `.gitignore`. Attach the ZIP and optional `.zip.sha256` to a Release tagged `v0.1.7-alpha`, marked as a pre-release. Do not force-add `releases/`, `tools_to_mod/`, extracted game files or backups into Git history. GitHub's automatically generated source archive is not the playable mod. [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases) support binary assets; this approximately 93 MB ZIP is below the 2 GiB per-file limit.

The checksum is a text record of the ZIP's SHA-256 hash, useful for checking download integrity. It is not an installation file. This workflow prepares local artifacts and does not publish to either service.
