# Changes and test status — alpha {{VERSION}}

This document describes the final contents of alpha {{VERSION}}. Mesh numbers are zero-based. The `_S` variants are included where listed.

## Senpou monk particle texture correction — 0.1.8

The user reported centipede shapes in the monks' vomit after the earlier grab-effect substitution. Alpha 0.1.8 replaces the remaining `s04092` texture property with `s11606`, the same splash texture selected from original effect 220505. Fifteen properties across nine FXR entries in the three existing effect packages were corrected. The earlier renderer settings are retained. Each change occupies one existing four-byte field; no effect components were deleted or reserialized.

The C1210 animation references include effect 612110, which calls corrected effect 612100. Original texture s04092 was visually confirmed to contain centipedes. This identifies a concrete remaining texture reference associated with the monk effects; the exact vomit appearance still needs gameplay confirmation.

A fresh scan of 2,913 original FXR files found these same nine entries using the identified texture property. The previous audit checked integer renderer settings and missed this floating-point texture property. All other mod payload files are unchanged from 0.1.7, except the title-menu version label. Package checks do not constitute an in-game crash test.

## Title-menu label and version

Alpha 0.1.7 adds `mods/menu/05_000_title.gfx` to the complete release. The user confirmed that the menu label works. It now reads `Nicky Allowed - Invisible Centipedes | alpha {{VERSION}}`, using the same tested field, font, position and placement. The version suffix passed structural checks; the user accepted this text-only update without requesting another gameplay test.

The central project `VERSION` file controls the menu label, archive name, packaged VERSION and generated release documentation. In alpha 0.1.7, all 28 earlier mod files were unchanged from alpha 0.1.6. The menu label indicates that the menu override loaded, not that every other mod file was independently verified by the game.

## Character and object coverage

| Target | Included change |
| --- | --- |
| C5100 — Guardian Ape | Embedded parasite meshes 32/33 hidden. |
| C1013 — Hanbei parasite | Mesh 0 hidden. |
| C5001 — standalone centipede | All four meshes hidden. |
| C1200 — monk | Meshes 0/1/5/12, including Mukade and Bugs layers, hidden. |
| C1210 — infested monk | Meshes 3/4/10/11/14/21/22/23/24 hidden. |
| C5000 — True Monk | Only parasite mesh 25 hidden. |
| o205900 / o205910 — decorative monks | Mukade layers: main meshes 0/1 and `_S` mesh 0 hidden. |
| o134290 — pot | Worm layers: main meshes 2/3/4 and `_S` meshes 0/1 hidden. |
| o134390 — wooden container and food | Worm layers: main meshes 3/4 and `_S` meshes 1/2 hidden. |
| o124290 — pot | Worm layers: main meshes 0/1 hidden. In-game location unconfirmed. |

Some worm/insect removals are specific user choices, not confirmed centipede identifications. Unselected meshes were preserved.

Hanbei coverage was freshly checked for alpha 0.1.7: C1012 is the preserved body, while C1013 is the separate single-mesh parasite associated with Hanbei in the map and event initialization. C1013 mesh 0 is hidden in both the release and installed override. This does not rely solely on C5001, whose four meshes are also hidden. The check inspected files rather than replaying the final quest.

## Scenery coverage

| Map and asset | Included change |
| --- | --- |
| m13: 000800 / 000810 | Worm layers: main mesh 7 and `_S` mesh 2 hidden. |
| m13: 001200 | Worm layers on bodies: main meshes 1/4 and `_S` meshes 0/2 hidden. Bodies, clothing and hair preserved. Added in 0.1.5. |
| m13: 206500 | Worm layers 1/2 hidden; rock preserved. Specific user-authorized exception. |
| m25: 000710 / 000711 / 000712 / 000750 / 311050 | Insect/possible glowing-larva layers: main meshes 0/1 and `_S` mesh 0 hidden by user choice. Not confirmed as centipedes. |

Senpou uses map prefix `m20_00_00_00`:

| Asset | Animated layers hidden | Static/individual layers hidden | `_S` layers hidden |
| --- | --- | --- | --- |
| 450000 | 2/3 | 0/1 | 0 |
| 450001 | 3/4 | 1/2 | 1 |
| 450002 | 3/4 | 1/2 | 1 |
| 502001 | None | 2/3 | 0/1 |
| 502003 | 2/3 | 0/1 | 0 |

The animated layers use `Mukade_Scroll` and `Mukade_Scroll2`. The static textures `m20_worm_03_a` and `m20_worm_04_a` were visually confirmed to contain centipedes mixed with other insects. The complete layers were hidden, including the other insects. The individual `m20_worm_02` layer in 502001 was added to the removal by explicit request in 0.1.6; it is not a newly confirmed centipede texture. Stone, wood and other unselected surfaces were preserved.

## Particle substitution

Fifteen visual renderer blocks in nine FXR files use a splash configuration from the original effect 220505 and texture `s11606` instead of the centipede configuration using `s04093`:

| Effect package | Modified FXR IDs |
| --- | --- |
| sfxbnd_commoneffects | 612010, 612100, 612101 |
| sfxbnd_m15 | 650010, 650011, 650012 |
| sfxbnd_m25 | 650010, 650011, 650012 |

Only fixed-size visual field blocks were changed directly in the original FXR bytes. File size, structure, internal offsets and all bytes outside those blocks were preserved. Existing timing, movement and unrelated properties remain, so this is a visual substitution rather than a copy of an entire blood attack. Other entries in the effect packages remained byte-for-byte identical to their originals.

The earlier 0.1.1 attempt removed effect components and was followed by a reported monk-grab crash. That approach was reverted. The earlier substitution, introduced in 0.1.4, was confirmed by the user to work without a crash in the tested encounter; the exact cause of the earlier crash was not proven.

## Intentionally preserved

- Long-arm Centipede and its C1030/C1040 variants.
- C1211 crickets, o157000/o157001/o157002 moth objects and o253100/o253110 cages.
- C5005 (illusory Monk), C5090, and m13 scenery 201300/206510/206600.
- o116050/o116051, inspected by the user and found not to contain centipedes. Their Material #337 uses charcoal textures.

Collision files, combat parameters and event scripts are not included as separate modifications. This does not guarantee the absence of indirect gameplay effects, and hiding a creature can remove an attack cue.

## Validation and remaining tests

- [x] Edited models and packages reopened and compared against the intended changes; original package compression retained.
- [x] Particle file size and all bytes outside the selected visual fields checked.
- [x] The {{PAYLOAD_COUNT}} mod files and every ZIP entry checked by hash.
- [x] Guardian Ape parasite removal confirmed by the user in gameplay, limited to the observed sequence.
- [x] Senpou animated and static floor removals confirmed by the user in the tested location.
- [x] Alpha 0.1.4 particle substitution confirmed by the user without a crash in the tested encounter.
- [ ] Alpha 0.1.8 texture-property correction: verify monk vomit and grab attacks in gameplay.
- [ ] Latest additions to Dungeon bodies (001200) and Senpou individual layers (502001), including near/far views and area reloads.
- [ ] Remaining monk attacks, True Monk phases/effects, executions and cutscenes.
- [ ] Full-game coverage and compatibility with other mods.

The reference audit rechecked metadata for 14,424 models and read 2,913 original FXR files, finding no additional model targets under the known references. Its particle search missed floating-point texture properties; alpha 0.1.8 corrects the remaining s04092 references described above. This does not exclude other names, baked textures, shadows or unexamined visual appearances.

## Historical documentation update — 0.1.6

On September 22, 2026, the release instructions and test notes were rewritten in English and renamed to `README.md`, `CHANGES-AND-TESTS.md` and `FILES-SHA256.csv`. Historical notes were consolidated into the current coverage above. All 28 mod binaries are unchanged; the ZIP checksum changed because its documentation changed.

