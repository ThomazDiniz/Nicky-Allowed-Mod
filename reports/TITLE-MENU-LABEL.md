# Title-menu label — September 22, 2026

Requested text: **Nicky Allowed - Invisible Centipedes**.

**Installed for testing** on September 22, 2026 at 10:11 with Sekiro closed. The installed hash matched the validated build. No prior menu override existed. Rollback record: `work/backups/before-title-label-20260922-101105/manifest.json`; installation record: `work/title-menu/installation.json`. In-game appearance is still pending user confirmation.

Prepared an independent override of `menu/05_000_title.gfx`, adding one read-only, non-selectable text field in the original `MenuFont_01` font. Intended position: upper-left, 64/50 px on the 1920x1080 menu stage; 24 px warm-white text. It is an unnamed placement without a game text-variable binding.

All 80 original top-level GFX tags remain byte-identical, including existing menu elements, nested timelines and ActionScript. The additions are one DefineEditText and one PlaceObject2 tag. The declared file length and zero alignment padding were updated. The new character ID 69 and root depth 24 do not collide with the original definitions/placements. The added placement matrix was decoded and checked.

No combat, character, scenery, FXR or texture package changes are part of this test. The main alpha 0.1.6 ZIP remains unchanged until the menu is tested. The label demonstrates loading of the menu override, not integrity or successful loading of all mod files.

## Files and reproducibility

- Build: `work/title-menu/build_title_label.py`.
- Original tag inspection: `work/title-menu/inspect_gfx.py`.
- Structural checks: `work/title-menu/validation.json`.
- Test override: `dist/title-label-test/mods/menu/05_000_title.gfx`.
- Install with backup/hash checks: `work/title-menu/install.ps1`.
- Installation result, when run: `work/title-menu/installation.json`.

The game was not running during preparation. In-game rendering remains unverified: check the initial prompt, main-menu options and entry into gameplay. Font resolution and runtime behavior cannot be established by structural checks alone.

## Original textures, available for manual editing

As a fallback, extracted the original SB_Title and SB_Title_02 textures from both quality variants of `menu/hi/01_common.tpf.dcx` and `menu/low/01_common.tpf.dcx`. DDS files and lossless PNG previews are under `work/title-menu/original-textures/`:

| File stem | Size |
| --- | --- |
| hi-SB_Title | 2048 × 1024 |
| hi-SB_Title_02 | 1024 × 1024 |
| low-SB_Title | 1024 × 2048 |
| low-SB_Title_02 | 512 × 512 |

These are texture atlases, not full-screen screenshots. Their dimensions, transparency and element layout must be preserved when editing. They are not needed for the text-label approach.

## References

The original-file inspection established the menu path, text flags, font-class mechanism and stage size. Field layout was cross-checked against [Ruffle's SWF reader](https://github.com/ruffle-rs/ruffle/blob/master/swf/src/read.rs), including the HasFontClass font-height rule. [The title-screen resource author's notes](https://www.nexusmods.com/sekiro/mods/729) identify SB_Title/SB_Title_02 as the title atlases; no third-party mod files were downloaded or incorporated.
