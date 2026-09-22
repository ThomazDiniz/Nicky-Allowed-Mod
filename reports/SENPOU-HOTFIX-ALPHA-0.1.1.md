# Senpou floor and particle hotfix — alpha 0.1.1

**Superseded historical record. Do not distribute alpha 0.1.1.** The user reported a crash during a monk grab. Recovery 0.1.2 restored the original effects while retaining the model/floor changes. See [the crash report](GRAB-CRASH-ALPHA-0.1.1.md). The current release uses the later [particle substitution](BLOOD-PARTICLES-ALPHA-0.1.4.md).

Prepared and installed with Sekiro closed on September 20, 2026. All 26 installed hashes matched the distribution. Gameplay verification was pending when this report was first written.

## Trigger

The user showed centipedes on Senpou's floor and red centipede-like shapes during a monk grab. FLVER inspection alone did not cover all FXR effects, so particle textures were also investigated.

## Animated Senpou floor

| Package in m20_00_00_00 | Hidden main-model meshes |
| --- | --- |
| 450000 | 2 / 3 |
| 450001 | 3 / 4 |
| 450002 | 3 / 4 |
| 502003 | 2 / 3 |

These meshes use `Mukade_Scroll/Mukade_Scroll2`. Face indices were made degenerate to hide them. Remaining parsed data were compared with the source. At this stage, `_S` variants, floor, wood, leaves and layers named `worm` were preserved. All four packages reopened with their original compression and passed internal-file checks.

Matching each piece to each location in the screenshot still required gameplay testing. Scenery 502001 was not changed solely because it contained `worm` names. Static layers were addressed later in 0.1.3.

## Particle attempt, subsequently reverted

Exported and visually inspected 375 common-effect textures. **s04093 is a 64-frame centipede sequence with visible legs.** The effect search found:

| Package | FXR | Removed particle components |
| --- | --- | --- |
| sfxbnd_commoneffects | 612010 / 612100 / 612101 | 1 / 1 / 3 |
| sfxbnd_m15 | 650010 / 650011 / 650012 | 1 / 1 / 3 |
| sfxbnd_m25 | 650010 / 650011 / 650012 | 1 / 1 / 3 |

The failed approach removed 15 Effect 1004 components containing Action 603 references to texture 4093, across nine FXR files and three packages. Remaining parsed components were compared after saving/reopening, untouched entries stayed byte-identical, and DCX_KRAK compression was preserved. These checks did not establish runtime safety.

C1200 animation events call 612010; C1210 calls 612110, which references 612100. Variants 650010/11/12 occur in m15/m25. This established use of the texture but did not conclusively identify the exact effect producing the red grab in the screenshot. Attack/SpEffect parameters and the exact sequence were potential further leads.

No animation, combat parameter, collision or event script was edited. C1030/C1040 remained unchanged. Gameplay tests also needed to assess any visual cues lost with the particles.

## Historical delivery and recovery evidence

- Complete 0.1.1 package: 26 files, retaining all 19 files from 0.1.0 and adding four scenery and three effect packages. Every ZIP entry was hash-checked.
- Installed at `C:\Program Files (x86)\Steam\steamapps\common\Sekiro\mods` on September 20, 2026 at 21:11 with the game closed.
- Backup: `work/backups/before-alpha-011-install-20260920-211155/`. Includes replaced mod files and `modengine.ini`, not saves or the whole game.
- The backup manifest distinguishes replaced files from newly added files. Restore prior files and remove only recorded additions with the game closed.
- The old release ZIP is no longer retained. Current instructions are in the latest release.

## Tests originally requested

- Revisit the photographed floor nearby, at a distance and after reloading.
- Reproduce the photographed monk grab.
- Check other monk attacks and the True Monk's phases, attacks and finishing sequences.
- Check that Long-arm Centipede remains intact.

Do not treat file validation as completed gameplay testing. Later test results are recorded in the action plan.

## Evidence and references

`work/verify-senpou-hotfix/validation.json`, `work/senpou-effects/centipede-fx-inventory.json`, `work/senpou-effects/fx-hotfix-validation.json`, `work/alpha-011-release-validation.json` and `work/alpha-011-installation.json`.

Read-only TAE investigation used the [SoulsFormatsNEXT format code](https://github.com/soulsmods/SoulsFormatsNEXT/tree/master/SoulsFormats/Formats/TAE) and the [DSAnimStudio SDT template](https://github.com/Meowmaritus/DSAnimStudio/blob/master/DSAnimStudioNETCore/Res/TAE.Template.SDT.xml). No TAE was edited.
