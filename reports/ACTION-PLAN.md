# Action plan — Nicky Allowed — Invisible Centipedes

Updated September 22, 2026. This English edition consolidates the earlier chronological notes and distinguishes current status from superseded plans.

## Current status

**Current release: alpha 0.1.8, September 22.** The remaining s04092 texture properties in fifteen particle renderers were replaced with the existing splash donor s11606. This addresses a concrete remaining centipede texture reference in the monk effect chain after the reported vomit appearance. See [the correction report](SENPOU-VOMIT-ALPHA-0.1.8.md).

The complete 29-file release is installed with Sekiro closed and all installed hashes verified. Three effect packages and the menu version label changed from 0.1.7; the other 25 payload files are identical. Backup: `work/backups/before-alpha-018-20260922-185749/`. Installation record: `work/alpha-0.1.8-installation.json`. The new texture correction has not yet been tested in gameplay.

Current distribution: `releases/Nicky-Allowed-Invisible-Centipedes-alpha-0.1.8.zip`, with English instructions, VERSION and a SHA-256 manifest. Only the latest release is retained. The title-menu label reads `Nicky Allowed - Invisible Centipedes | alpha 0.1.8`. Hanbei's separate C1013 parasite remains hidden; see [the audit](HANBEI-FINAL-QUEST.md).

- [x] Complete the selected model, object, scenery and particle edits.
- [x] Preserve Long-arm Centipede/C1030/C1040.
- [x] Reopen and compare edited packages; verify distribution and installed hashes.
- [x] Record user confirmation of the Guardian Ape result in the tested sequence.
- [x] Record user confirmation of animated and static Senpou floor removals at the observed location.
- [x] Record user confirmation that the splash particle substitution worked without a crash in the tested encounter.
- [ ] Test the latest Dungeon bodies and separate Senpou 502001 layer in game.
- [ ] Confirm the alpha 0.1.8 particle texture correction during monk vomit and grab attacks.
- [ ] Test remaining attacks, phases, finishing sequences, distance variants and shadows as saves allow.
- [ ] Develop the separate model-replacement variant after the invisible version.

An edited/validated file is not the same as a gameplay-tested appearance. No assistant-run gameplay test is claimed. The user reviews the alpha by playing.

## Scope and preserved content

The primary target is centipedes, while preserving characters, combat and progression. The user clarified that worms generally do not bother Nick. Nevertheless, the user explicitly retained earlier worm removals for this alpha and authorized particular additional worm layers. These exceptions do not justify removing every asset whose name contains `worm` or `insect`.

**Always preserve Long-arm Centipede and C1030/C1040 in both mod variants.** Also preserve:

- C1211 crickets, reviewed and excluded by the user.
- o157000/o157001/o157002 moths. The family was preserved after inspection of o157000; the other two were not individually inspected.
- o253100/o253110 baskets/cages. Each has four single-mesh variants using `insect_Basket`, with no separate parasite layer identified. Textured gameplay appearance remains unverified.
- C5005 Illusory Monk: approximately 130 Worm bone references, but no positively weighted vertices or parasite materials found. Shared skeleton names are not sufficient grounds for removal.
- C5090 Lady Butterfly: an alias match alone is not centipede evidence.
- m13 scenery 201300, 206510 and 206600, preserved after user review. The latter showed a pile of bones; worm texture names did not establish centipedes.
- o116050/o116051: user confirmed no centipedes. Their Material #337 references charcoal textures.
- Webs, eroded rock, vegetation and other textual false positives.

## Final invisible-model coverage

Mesh indices are zero-based. All packages below are included in installed alpha 0.1.6. “Hidden” refers to selected faces; skeletons and combat logic were retained.

| Character | Hidden meshes | Validation and remaining gameplay work |
| --- | --- | --- |
| C5100 Guardian Ape | 32 / 33 | User confirmed no centipede in the observed boss sequence on September 19. Check spear extraction, transitions and finishing sequences separately. |
| C1013 alternate Hanbei | 0 | Visually identified as the parasite-only mesh. File/package validated; corresponding gameplay sequence pending. |
| C1200 infested monk | 0 / 1 / 5 / 12 | Mukade, scroll, body and Bugs layers; remaining model data and four auxiliary resources preserved. Other attack/finish appearances pending. |
| C1210 infested monk | 3 / 4 / 10 / 11 / 14 / 21 / 22 / 23 / 24 | Nine Mukade/Bugs layers; remaining model data and three auxiliary resources preserved. Full gameplay coverage pending. |
| C5000 True Monk | 25 | Parasite visually confirmed and removal reapplied in the editor; Monk remained visible. Four auxiliary resources preserved. Gameplay phases/finishers pending. |
| C5001 Immortal Centipede | All four meshes | Standalone prototype validated. The Ape test does not validate this distinct model; a corresponding appearance is still needed. |

| Object | Hidden main meshes | Hidden `_S` meshes | Preserved content |
| --- | --- | --- | --- |
| o205900 | 0 / 1 | 0 | Decorative monk and other surfaces; check shadows in game. |
| o205910 | 0 / 1 | 0 | Other surfaces; check shadows and appearance. |
| o134290 | 2 / 3 / 4 | 0 / 1 | Pottery, wood and `_1` variants. Authorized worm removal. |
| o134390 | 3 / 4 | 1 / 2 | Wood, food and `_1` variants. Authorized worm removal. |
| o124290 | 0 / 1 | Unchanged | Pottery, wood and shadow variant. Location not confirmed in the map-part search. |

| Map / suffix | Hidden main meshes | Hidden `_S` meshes | Notes |
| --- | --- | --- | --- |
| m13 / 000800, 000810 | 7 | 2 | Earlier authorized worm removals. |
| m13 / 206500 | 1 / 2 | Unchanged | User authorized worms too because the large object was hard to inspect. Rock mesh 0 preserved. |
| m13 / 001200 | 1 / 4 | 0 / 2 | Distant-body worms, added in 0.1.5; bodies, clothes and hair preserved. Gameplay test pending. |
| m25 / 000710, 000711, 000712, 000750, 311050 | 0 / 1 | 0 | User-edited insect/possible glowing-larva layers, not confirmed centipedes. Shadow mesh preserved. |
| m20 / 450000 | Animated 2 / 3; static 0 / 1 | 0 | Floor preserved. |
| m20 / 450001, 450002 | Animated 3 / 4; static 1 / 2 | 1 | Other scenery preserved. |
| m20 / 502003 | Animated 2 / 3; static 0 / 1 | 0 | Material #337/#341 identify the animated layers here only. |
| m20 / 502001 | Static 3; individual worm/insect layer 2 | Static 1; individual layer 0 | Individual layer added in 0.1.6; wood and previous fixes preserved. Gameplay test pending. |

The full map prefixes are `m13_00_00_00`, `m20_00_00_00` and `m25_00_00_00`. Alpha 0.1.6 contains six character, five object, fourteen map and three effect packages.

## Particle coverage

Texture `s04093` was visually confirmed as a 64-frame centipede atlas. Alpha 0.1.1 removed 15 Effect 1004 components and was followed by a grab crash. That method was reverted in 0.1.2. Do not repeat or redistribute it.

Alpha 0.1.4 instead copied the splash renderer configuration from original FXR 220505 / texture s11606 into 15 Action 603 `Fields1` blocks, each 60 bytes:

- Common package: FXR 612010 / 612100 / 612101, with 1 / 1 / 3 renderers.
- m15 and m25: FXR 650010 / 650011 / 650012 in each, with 1 / 1 / 3 renderers.

Raw patches preserve FXR lengths, nodes, offsets and all other bytes. Outer binders retain original compression and unmodified entries. FXR 612110 calls 612100, so it inherits the change. The user confirmed success without a crash in the tested grab. Other attacks and True Monk effects remain to be tested.

## Reference audit and previously empty models

The September 21 audit reanalyzed metadata for 14,424 models, checked the same 6,760 archive paths, freshly read 2,913 FXR files without errors and confirmed 40 direct-reference meshes across ten packages were already hidden. The 15 known particle references were already covered. It found no new confirmed target under the searched names; it did not prove universal coverage. See [the audit](REFERENCE-AUDIT-2026-09-21.md).

The six models previously deferred after empty editor views were m13…001200 and m20…450000, 450001, 450002, 502001 and 502003. The user completed the requested re-opening, but empty views were never treated as evidence that no geometry existed. All six now have relevant edits included in 0.1.6. There is no remaining six-model opening queue; gameplay checks remain.

The later material-number search confirmed both #337 and #341 use Mukade scroll materials in 502003. The same #337 label on o116050/o116051 refers to charcoal. See [the material report](MATERIALS-337-341.md).

## Reusable workflow with Computer Use

Use the editor for visual identification and selective mesh decisions. File copies, repacking and comparisons can be automated. If app launch/control is unavailable, the user opens the tool and the assistant continues from the available files or supported UI. Do not assume an unavailable desktop-control capability. Gameplay reproduction is performed by the user with a suitable save.

Local tools:

- FLVER Editor: `tools_to_mod/FLVER_Editor_X2.6/Debug/MySFformat.exe`.
- Yabber: `tools_to_mod/Yabber.1.3.1/Yabber 1.3.1/Yabber.exe`.
- DSMapStudio: `tools_to_mod/DSMapStudio-1.11.1.hotfix3/DSMapStudio.exe`.
- Mod Engine configured for `Sekiro/mods`, with `useModOverrideDirectory=1`.

### 1. Prepare a reversible edit

1. Close Sekiro before replacing installed files.
2. Preserve a save backup from `%APPDATA%/Sekiro` when preparing a gameplay trial.
3. Back up current Mod Engine configuration and every mod file that will be replaced; record newly added files separately.
4. Make original and editing copies in a target-specific workspace. Never install the whole project folder.

### 2. Identify and edit the intended faces

1. Open the extracted `.flver` in an editing copy, not the game installation. Extract textures if needed for identification.
2. Bring FLVER-X Viewer forward and inspect before editing. Open **Mesh** and use the zero-based indices only as a starting point.
3. Confirm actual geometry/materials. Empty views may mean geometry is far from the camera. Bone names alone do not establish visible centipedes.
4. For a mesh containing only the intended creature, select **Delete?** on that row and **Delete faceset only**. Do not use the column's **A** button on a mixed character: that selects every mesh.
5. Leave transforms, bones and dummies unchanged. If a mesh mixes the host and parasite, isolate selected faces instead of hiding the entire mesh; Blender may be needed.
6. Click **Modify** only after checking the selection; in the tested editor flow this saves the edit and shows a confirmation.
7. Reopen the saved file and confirm that the host/scenery remains visible. Purple skeleton lines are editor helpers, not necessarily visible geometry.
8. If the file was edited externally, reload the editor before saving again to avoid overwriting new changes with a stale session.

For C5100, meshes 32/33 both used material `#12#` in the inspected file. Parasite-bone weights supported identification but were not sufficient alone. For C5000, choose the saved `c5000.flver`, not either `.bak` copy.

### 3. Repack and verify

1. Replace only the edited FLVER inside the original binder using the compatible SoulsFormats library.
2. Preserve the original DCX_KRAK compression. An early Yabber C5100 repack used DFLT and was replaced; do not distribute that intermediate file.
3. Reopen/extract the generated binder and compare the intended mesh edit, untouched model data and HKX/auxiliary entries.
4. Check all internal variants, including `_S` and broken/distance variants, without hiding unrelated shadows or container surfaces automatically.
5. Record source/output hashes, target indices, compression and any writer-induced header changes.
6. Build a complete release with only required files, English instructions, change/test notes and a file manifest. Verify every ZIP entry.

### 4. Install and reproduce the sighting

1. With Sekiro closed, back up and copy into the effective Mod Engine override directory. Current paths begin `Sekiro/mods/chr`, `obj`, `map` or `sfx`.
2. Check installed hashes, then launch through Steam. Editing tools do not need to stay open.
3. Reproduce the same enemy/action/location. Check host visibility, parasite absence, complete animation and normal combat/progression.
4. Test nearby/distant views, reloads, object breakage, transitions and finishing sequences separately where applicable.
5. Record any remaining surface or particle with its exact moment/location, then investigate its source. Do not assume the loader failed.
6. On regression, close the game and restore only affected files from the verified backup, removing only additions recorded by the manifest.

### 5. Investigate scenery and future sightings

1. Use [the inventory](CENTIPEDE-INVENTORY.md), `reports/full-inventory.csv` and `work/creature-inventory/map-placements.csv` to locate candidate IDs.
2. Locate map parts in DSMapStudio and record a route to the relevant in-game spot.
3. Inspect all relevant internal variants and actual textures.
4. Hide a separate insect layer selectively. If an image is shared with desired scenery, edit the texture/material selectively rather than removing the floor, wall, rock or whole object.
5. Preserve collisions and map references; check movement, camera, shadows and appearance.
6. Search actual references such as Mukade materials and known texture IDs. Keep broad `worm`/`insect` matches as candidates until inspected or explicitly authorized.

## Gameplay checklist

- [ ] Dungeon 001200: hidden worms, intact bodies/clothes/hair, nearby and distant views.
- [ ] Senpou 502001: hidden individual layer, intact wood and retained older fixes.
- [ ] Hanbei's corresponding parasite sequence and a confirmed C5001 appearance.
- [ ] Remaining C1200/C1210 attacks, finishing sequences and body surfaces.
- [ ] True Monk parasite, transitions, attacks and finishing sequence.
- [ ] Guardian Ape spear extraction, transitions and finishers beyond the observed successful test.
- [ ] All edited object variants, shadows and map layers after reload.
- [ ] Long-arm Centipede appearance and behavior intact.
- [ ] Record inaccessible cutscenes, videos and locations as untested. The two BK2 videos were not reviewed by the initial inventory.

## Separate future mod: visual replacement

The user requested two independent alternatives: first the invisible mod, then a replacement mod, initially considering a smiley face. The second variant has not started.

1. Preserve the invisible release and originals; create a separate editing area and package.
2. Prototype on C1013, whose single mesh represents the parasite.
3. Fit replacement scale, position, material/texture and skeleton attachment without exposing original centipede geometry.
4. Check movement in the editor and corresponding game sequence.
5. Adapt each confirmed character, object and scenery target separately; invisible-mod tests do not automatically validate replacements.
6. Keep target-specific records for preparation, package validation and gameplay testing. Preserve C1030/C1040 and combat/progression.
7. Deliver a complete independent ZIP with English installation, switching and removal instructions. Install only one alternative at a time; overlapping files do not merge automatically.

## Historical milestones

| Version / period | Outcome |
| --- | --- |
| Prototype / v0.2–v0.6 | C5001, Ape, Hanbei, both monks and True Monk prepared. Ape result confirmed September 19; C5000 removal reapplied and visually checked. |
| v0.7–v0.11 | Five objects prepared. o134390 saved changes rechecked after interruption. Crickets, moths and baskets preserved. |
| v0.12–v0.13 | Dungeon 000800/000810 prepared. Six empty-view candidates deferred. |
| Pre-alpha map review | 206500 and five Palace edits validated, including `_S` counterparts; user authorized specific non-centipede worm/insect removals. |
| 0.1.0, September 20 | Complete 19-file package assembled from v0.13 plus map edits. Initially prepared without installation; subsequently installed by explicit request, all 19 hashes checked. |
| 0.1.1, September 20 | 26 files; four animated Senpou layers and three edited effect packages. Installed at 21:11. User reported grab crash; particle deletion reverted. |
| 0.1.2, September 20 | 26 files; original SFX restored, 23 model/scenery files retained. |
| 0.1.3, September 21 | 27 files; five static Senpou pieces and variants treated. User confirmed floor result. |
| 0.1.4, September 21 | 27 files; 15 fixed visual-field particle substitutions. User confirmed success without a crash in the tested encounter. |
| 0.1.5 | 28 files; Dungeon 001200 added. Installation deferred until review finished. |
| 0.1.6, September 21 | 28 files; separate 502001 layer added while retaining all previous fixes. Packaged, then installed at 15:36. |
| September 22 | Retained only latest release; cleaned orphaned Git objects after commits were undone; English documentation and script text update. No mod binary changes. |

## Evidence and backups

- Initial save/config/mod backup: `work/backups/20260919-081621/`.
- Pre-alpha backup: `work/backups/pre-alpha-0.1.0-20260920-142057/`; immediate pre-install backup: `work/backups/before-alpha-install-20260920-143746/`.
- Release-specific backups and validation records are described in the individual reports. They do not necessarily include saves or the whole game.
- Final review: `work/review-user-mesh-changes.json`, `work/m13-corpses/validation.json`, `work/senpou-502001-final/validation.json`, `work/alpha-016-release-validation.json` and `work/alpha-016-installation.json`.
- Early C5100 installed SHA-256: `D48EC818D3F578E79312C01F4C3328C077B9CCAC5E42148F5629C3C911676779`.
- Historical intermediate paths include `dist/nicky-allowed-invisible-v02/`, `dist/pending-m13-206500/`, `dist/pending-palacio/` and `work/verify-palacio/validation.json`. Path spellings are preserved as technical identifiers.
