# Nicky Allowed — Invisible Centipedes

A visual accessibility mod for **Sekiro: Shadows Die Twice** on PC, made for a friend named Nick who is afraid of centipedes.

The mod hides selected centipede models and environmental layers, and replaces identified centipede particles with a splash configuration from the game. It aims to preserve combat and progression. **Long-arm Centipede and its C1030/C1040 variants are intentionally preserved.**

## Current release

**Invisible alpha 0.1.8** contains 29 mod files, including the versioned title-menu label. The complete release was packaged and verified locally.

The local distribution is `releases/Nicky-Allowed-Invisible-Centipedes-alpha-0.1.8.zip`, with a matching `.zip.sha256` checksum. Release binaries are ignored by Git and must be distributed separately.

The ZIP contains the complete `mods/` folder, `VERSION`, English `README.md`, `CHANGES-AND-TESTS.md` and `FILES-SHA256.csv`.

## Coverage

- Selected centipede appearances associated with Hanbei, infested monks, the Guardian Ape, and the True Monk.
- Animated and static centipede layers on identified Senpou Temple scenery.
- Identified centipede particles replaced with splash rendering, while retaining the original effect structure, timing and movement.
- Additional worm/insect layers removed by explicit request, including worms on bodies in the Abandoned Dungeon and a separate layer in Senpou scenery `502001`.

Some layers contain other insects alongside centipedes, so this alpha also removes some non-centipede visuals. It is not a guaranteed centipede-free version of the entire game.

## Installation

1. Close Sekiro completely and back up your existing mod folder.
2. Install [Sekiro Mod Engine](https://www.nexusmods.com/sekiro/mods/6) if needed, following its author's instructions. The loader files belong beside `sekiro.exe`.
3. Check these settings in the `[files]` section of `modengine.ini`:

   ```ini
   loadUXMFiles=0
   useModOverrideDirectory=1
   modOverrideDirectory="\mods"
   ```

4. Extract the release ZIP and copy its `mods` folder into the game directory, beside `sekiro.exe`. Accept replacement of this mod's older files when upgrading. The resulting folders are `Sekiro/mods/chr`, `obj`, `map`, and `sfx`; do not create `Sekiro/mods/mods`.
5. Launch the game normally through Steam. You do not need to run Yabber, FLVER Editor or DSMapStudio to use the mod.

If your loader uses a different override directory, copy the contents of `mods` there instead. Mods that replace the same files require a compatible merge; copying one over another does not combine their changes. Alpha 0.1.8 is a complete package, so earlier versions are not required.

## Project layout and development

The root `VERSION` file is the version source. To build the next complete release, run `./release.ps1 -Bump patch` in PowerShell; it updates the menu version, ZIP, manifest and release documentation together. `-Preview` shows the next number without changes. See [the release workflow](reports/RELEASE-WORKFLOW.md) for explicit versions, reviewed overlays and publishing instructions. Release templates live in `docs/release/`; the build does not install or publish automatically.

| Path | Purpose |
| --- | --- |
| `reports/` | Coverage inventories, decisions, validation records and investigation notes in English. |
| `work/` | Inspection/build scripts and local working files. Only PowerShell and Python scripts are eligible for Git tracking. |
| `tools_to_mod/` | Local copies of modding tools; excluded from Git. The alternative spelling `tool_to_mod/` is also ignored. |
| `dist/` | Intermediate generated packages; excluded from Git. |
| `releases/` | Local distributable packages; excluded from Git. |
| `recovery/`, `param/`, `.dsms/` | Local recovery data, extracted parameters and editor state; excluded from Git. |
| `project.json` | Local DSMapStudio configuration with a machine-specific game path; excluded from Git. |

The work scripts reflect an iterative local workflow. Some require a local Sekiro installation, extracted assets, previous working artifacts or specific tool paths; they are not a standalone clean-checkout build system. Installation scripts must only be run intentionally with the game closed.

Model changes hide selected faces while preserving the remaining model data. Packages retain their original compression. Particle changes are validated separately against the original effect bytes. Keep backups and inspect the actual material/texture before selecting a mesh: names such as `worm` or `Material #337` are not reliable global identifiers for centipedes.

## Investigation records

- [Title-menu label and user confirmation](reports/TITLE-MENU-LABEL.md)
- [Hanbei final-quest model check](reports/HANBEI-FINAL-QUEST.md)
- [Versioning and publishing](reports/RELEASE-WORKFLOW.md)
- [Action plan and current status](reports/ACTION-PLAN.md)
- [Reference coverage audit](reports/REFERENCE-AUDIT-2026-09-21.md)
- [Particle substitution and user validation](reports/BLOOD-PARTICLES-ALPHA-0.1.4.md)
- [Static Senpou floor layers](reports/SENPOU-STATIC-LAYERS-ALPHA-0.1.3.md)
- [Material #337 / #341 investigation](reports/MATERIALS-337-341.md)
- [Original creature inventory](reports/CENTIPEDE-INVENTORY.md)

Older reports document historical states and may refer to releases or artifacts that are no longer retained. The current status in this README takes precedence over those historical installation instructions.

## Credits

Built using [FLVER Editor](https://github.com/asasasasasbc/FLVER_Editor), SoulsFormats, [Yabber](https://github.com/JKAnderson/Yabber), and [DSMapStudio](https://github.com/soulsmods/DSMapStudio). Loaded through [Sekiro Mod Engine](https://github.com/katalash/ModEngine).

Original game assets belong to their respective rights holders. This is an unofficial fan project.
