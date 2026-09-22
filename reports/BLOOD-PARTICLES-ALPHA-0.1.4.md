# Centipede particles replaced with splashes — alpha 0.1.4

September 21, 2026. After confirming the static Senpou floor fix, the user requested blood-like particles instead of the component deletion followed by the 0.1.1 crash.

**User result:** the substitution worked and did not crash in the tested encounter. This does not automatically validate every attack, variant or the True Monk.

## Implementation

Inspected texture s11606: liquid-splash frames without centipedes. Original effect 220505, called by monk finishing events, uses it in an Action 603 renderer. Its `Fields1` configuration has 15 fields/60 bytes and a 64-frame layout compatible with the s04093 renderers.

Replaced 15 visual blocks using that original renderer configuration:

- Common package: FXR 612010, 612100 and 612101.
- Both m15 and m25: FXR 650010, 650011 and 650012.

The blocks were located and patched directly in the original FXR bytes. No FXR writer reconstructed the files. Nodes, file lengths, internal positions and all bytes outside the selected blocks were preserved. Results were parsed and compared with the expected patch. Outer binders retained their original compression; untouched entries were byte-identical.

This reuses a splash renderer configuration, not an entire blood effect. Original particle timing, trajectories and other properties remain. The exact cause of the earlier crash was not proven; preserving the structure reduced the extent of the change but did not guarantee runtime safety.

All 24 model/scenery packages from 0.1.3 stayed byte-identical. Long-arm Centipede/C1030/C1040 were not edited.

## Historical installation

Installed alpha 0.1.4 with the game closed and all 27 installed files matching the distribution. Backup: `work/backups/before-alpha-014-install-20260921-093534/`.

Evidence: `work/senpou-effects/blood-swap-validation.json`, `work/alpha-014-release-validation.json` and `work/alpha-014-installation.json`.

The replacement remains included in alpha 0.1.6. Older release ZIPs were later deleted to save space. For a particle-only rollback, close the game and restore the three `mods/sfx` files from an appropriate verified backup; this leaves floor/model changes in place. Do not restore the failed 0.1.1 particle edits.

## Test record

- [x] User confirmed the static Senpou floor removal in 0.1.3.
- [x] Prepared the substitution, validated files, packaged and installed with backup.
- [x] User confirmed the substitution worked without a crash on September 21, 2026, for the observed encounter.
- [ ] Explicitly check other appearances for squares, flashes or unexpected distortion.
- [ ] Test other monk attacks and True Monk effects.

The user subsequently requested packaging and installation of the complete alpha 0.1.6. Its distribution instructions retain these testing limits.
