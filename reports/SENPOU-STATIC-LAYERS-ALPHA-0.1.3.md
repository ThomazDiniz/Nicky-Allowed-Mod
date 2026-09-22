# Static Senpou centipedes — alpha 0.1.3

Completed September 21, 2026: packaged and installed with Sekiro closed. All 27 installed files matched the manifest; all ZIP entries were hash-checked. **The user subsequently confirmed that this removal worked at the observed location.**

## Identification and edit

The user confirmed the animated floor centipedes were resolved but showed stationary insects over the stones. Visual inspection of `m20_worm_03_a` and `m20_worm_04_a` confirmed centipedes mixed with other insects. These textures are applied to meshes separate from the floor.

Entire layers using these textures were hidden, also hiding the other insects drawn alongside them. Painting the floor black was unnecessary. Stone, wood and other meshes were preserved, together with previous animated-layer fixes.

| Scenery in m20_00_00_00 | Hidden static main meshes | Hidden `_S` meshes |
| --- | --- | --- |
| 450000 | 0 / 1 | 0 |
| 450001 | 1 / 2 | 1 |
| 450002 | 1 / 2 | 1 |
| 502001 | 3 | 1 |
| 502003 | 0 / 1 | 0 |

All five packages reopened with their original compression. After normalizing only the changed indices for comparison, the remaining parsed model data matched the source. Internal files were checked after repacking.

## Effects and crash status at the time

Version 0.1.3 retained the three original SFX packages from recovery 0.1.2. It introduced no particle edits. Particle removal and confirmation of grab recovery were still pending then; confirmation of floor animation was not treated as confirmation of the grab. The successful 0.1.4 substitution is documented separately.

Long-arm Centipede/C1030/C1040 remained preserved.

## Historical delivery

- Installed under `C:\Program Files (x86)\Steam\steamapps\common\Sekiro\mods`.
- Backup: `work/backups/before-alpha-013-install-20260921-091420/`.
- Evidence: `work/senpou-static/validation.json`, `work/alpha-013-release-validation.json`, `work/alpha-013-installation.json`.
- The historical 0.1.3 ZIP has since been removed. The changes remain in the complete current release.

## Test record and later work

- [x] User confirmed the earlier animated-floor correction at the observed location.
- [x] Visually identified the static textures.
- [x] Hid layers, validated files, packaged and installed with backup.
- [x] User confirmed the static removal worked on September 21, 2026.
- [ ] Separately verify all edited pieces nearby, at a distance and after reloading.

At this stage m13_00_00_00_001200 remained deferred, and the worm_02 layer in 502001 was untouched. Those were later addressed by explicit request in 0.1.5 and 0.1.6. The particle follow-up was implemented in 0.1.4; see [the report](BLOOD-PARTICLES-ALPHA-0.1.4.md).
