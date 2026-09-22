# Centipede, parasite and insect inventory

**Scan completed September 19, 2026. This inventories local file references; it does not guarantee that every visual appearance has been identified or removed.** The scan itself changed no game or installed mod package.

This is the initial candidate inventory. Its proposed interventions and classifications are historical, not the final removal list. See [the action plan](ACTION-PLAN.md) for current scope, preserved candidates and alpha 0.1.6 status. In particular, crickets and moths were subsequently excluded by the user.

## Scope and results

| Group | Packages read | FLVER models read | Final errors |
| --- | ---: | ---: | ---: |
| Characters, objects and parts | 1,658 | 4,114 | 0 |
| Scenery | 5,094 | 10,166 | 0 |
| Visual effects, internal FLVER models only | 8 | 144 | 0 |
| **Total** | **6,760** | **14,424** | **0** |

Also cross-referenced 10 maps, 53,396 part records (including objects and auxiliary parts, not just enemies), and 54 cutscene packages containing 4,658 resource references. Packages may contain repeated models, distance or destruction variants; these are not counts of different creatures.

The search inspected bones, materials, texture paths and English/Japanese aliases, including worm, centipede, mukade, parasite, infested, cricket, spider, insect, moth, millipede, larva, ムカデ and 虫. A second pass checked parasite-bone vertex weights in eight characters.

## Main candidates

Mesh indices are zero-based, as in FLVER Editor. These are inspection leads, not authorization to hide entire meshes. Some meshes combine unrelated elements and require visual identification.

| ID | Identity | Evidence | Initial investigation |
| --- | --- | --- | --- |
| `c5100` | Guardian Ape | WormRoot, WormHead, leg bones and Insectebody material; weighted vertices in meshes **32/33**. User confirmed the appearance. | Isolate the parasite while preserving the Ape; highest initial priority. |
| `c1013` | Alternate Hanbei | Worm/Leg bones and `c1013_centipede_Decal`; weights in mesh **0**. | Check the variant and associated sequence; hide only the parasite. |
| `c1200` | Infested monk with parasite | Mukade materials and hundreds of bone references; weighted meshes **1/3/5/12**, plus suspicious material in **0**. | Inspect separate parts, surfaces and animated materials. |
| `c1210` | Infested monk | GroundWorm and Mukade/Scroll/Cloth materials; weights in **1/14**, suspicious materials elsewhere. | Include centipedes represented by textures/materials. |
| `c5000` | Corrupted / True Monk | Worm bones and weighted geometry in mesh **25**. | Inspect the embedded parasite while preserving the Monk. |
| `c5001` | Immortal Centipede | Standalone centipede, visually inspected. | Existing prototype does not cover parasites embedded in other characters. |
| `c1211` | Cricket | Cricket alias and `c1200_cricket` bone; placements in Senpou and the Dungeon. | Initial broad many-legged candidate; subsequently preserved by user decision. |

**Protected exception:** `c1030` and `c1040`, the Centipede / Long-arm family. Similar names must not cause automatic removal.

### Avoiding incorrect removals

- `c5005`, Illusory Monk: 130 Worm skeleton references, but no positively weighted vertices on those bones and no parasite materials found. Likely a shared skeleton; do not hide the entire Monk.
- `c5090`, Lady Butterfly: matched only by name. This does not establish centipedes on the character. Her effects would require separate investigation if butterflies were in scope.

## Relevant scenery objects

| IDs | Evidence | Recorded location / notes |
| --- | --- | --- |
| `o205900`, `o205910` | Decorative monks with ムカデ materials and Mukade textures | Senpou; o205900 also referenced in cutscene `s20_00_0000`. |
| `o134290`, `o134390` | Containers/surfaces with `worm_body` and `worm_01` | Abandoned Dungeon; inspect intact/broken variants and every internal FLVER. |
| `o124290` | `worm_body`, `worm_01`, and 虫の大群 nodes (insect swarm) | Not located in searched map parts; possibly unused or activated by another mechanism. |
| `o157000`, `o157001`, `o157002` | `m15_moth_01` textures | Broad moth/insect candidates, not confirmed centipedes; later preserved. |
| `o253100`, `o253110` | `insect_Basket` textures | Fountainhead Palace; the name may describe the container. Inspect before editing. |

## Insects and worms embedded in map models

Editing `chr/` alone is insufficient: map packages also contain relevant materials.

| Area | Candidate prefix and suffixes | Evidence |
| --- | --- | --- |
| Dungeon | `m13_00_00_00_` + `000800`, `000810`, `001200`, `201300`, `206500`, `206510`, `206600` | worm_body/worm_01 textures; some models also contain rock and need selective edits. |
| Senpou | `m20_00_00_00_` + `450000`, `450001`, `450002`, `502001`, `502003` | Worm, Mukade_Scroll materials and insect names. |
| Fountainhead Palace | `m25_00_00_00_` + `000710`, `000711`, `000712`, `000750`, `311050` | insect textures; some materials named 芋虫_発光, consistent with glowing larvae/caterpillars. Visual identity initially pending. |

## Matches that do not establish a many-legged creature

- `spiderweb` and 蜘蛛の巣: webs in Hirata, Senpou, Ashina, the Valley and Palace, not evidence of living spiders. Objects o108100, o109910, o109920 and o109930 also contain webs.
- `worm_eaten_rock` and 虫食 describe erosion in rock/wood. Do not remove terrain based on those names.
- `karamushi`, ムシロ and 蝶番 occur in vegetation, mats and hardware: textual coincidences, not automatic targets.
- Parameter aliases such as “sandworm” or “spider thread” may be old/reused labels. They remain in raw evidence but were not treated as proof of an enemy present in the game.

## Limits

The 14,424 models were not all manually viewed. Generic names can escape the search, and not every texture was opened as an image. Effect-package FLVER models were parsed, but this initial scan did not reconstruct FXR particle logic, events or animations. The game's two BK2 videos were not watched. No keyword match does not prove no visible insects.

Locations below come from map references, not gameplay. Some parts may be disabled, belong to another phase or be activated by events. An appearance absent from the cutscene table may still occur in a finishing animation outside cutscene packages.

## Initial implementation order

1. Guardian Ape and the reported extraction sequence.
2. Hanbei, infested monks and True Monk, alongside C5001.
3. Visually inspect broad insect/object candidates; apply subsequent user exclusions for crickets and moths.
4. Selectively treat Senpou, Dungeon and Palace materials while preserving floors, walls and hosts.
5. Test appearances, finishers, transitions, shadows and Long-arm preservation; record untested coverage.

## Evidence

- `reports/full-inventory.csv`: one row per matching internal model, including archive, classification, regions, scenes, evidence and material-matched meshes.
- `work/creature-inventory/parasite-meshes.csv`: priority character weights/materials. Worm bone weights alone do not delimit the full parasite surface.
- `work/creature-inventory/models.json`, `work/map-model-inventory/models.json`, `work/effect-model-inventory/models.json`: metadata for every parsed model, including nonmatches.
- `work/creature-inventory/map-placements.csv` and `cutscene-resources.csv`: map/cutscene cross-references.
- `work/creature-inventory/parameter-references.txt`: parameter alias text, not a list of executed events.
- `work/scan-creatures.ps1`, `scan-locations.ps1`, `inspect-parasite-meshes.ps1`, `build-creature-report.ps1`: repeatable inspection scripts.

## Complete matching-package catalog

Includes candidates, protected exceptions and false positives. Full internal variants and evidence are retained in the CSV. “Material meshes” is the material-name filter, not the bone-weight analysis. Raw asset identifiers remain in their source language.

| ID | Name/alias | Classification | Recorded region | Matching models | Material meshes |
| --- | --- | --- | --- | ---: | --- |
| `c1013` | Hanbei the Undying (Alternate) | Parasite — strong evidence | Ashina Outskirts | 1 | 0 |
| `c1030` | Centipede | PROTECTED — Long-arm family | Sunken Valley; Senpou Temple | 1 |  |
| `c1040` | Centipede Boss | PROTECTED — Long-arm family | Sunken Valley; Senpou Temple | 1 |  |
| `c1200` | Infested Seeker (Parasite) | Parasite — strong evidence | Senpou Temple | 1 | 0, 1, 5 |
| `c1210` | Infested Seeker | Parasite — strong evidence | Senpou Temple | 1 | 3, 4, 10, 11, 21, 22, 23, 24 |
| `c1211` | Cricket | Insect — cricket | Abandoned Dungeon; Senpou Temple | 1 |  |
| `c5000` | Corrupted Monk | Parasite — strong evidence | Mibu Village; Fountainhead Palace | 1 |  |
| `c5001` | Immortal Centipede | Parasite — strong evidence | Sunken Valley; Fountainhead Palace | 1 | 1 |
| `c5005` | Corrupted Monk Illusion | Inherited bones; parasite surface unconfirmed | Fountainhead Palace | 1 |  |
| `c5090` | Lady Butterfly | Lady Butterfly name; preserve character | Hirata Estate | 1 |  |
| `c5100` | Guardian Ape | Parasite — strong evidence | Sunken Valley | 1 | 33 |
| `m10_00_00_00_002507` |  | Webs — no confirmed spider | Hirata | 1 | 3, 4, 5 |
| `m10_00_00_00_603000` |  | Webs — no confirmed spider | Hirata | 1 | 0, 1 |
| `m11_00_00_00_002500` |  | Webs — no confirmed spider | Ashina Outskirts | 2 | 13, 14, 15; 3, 4, 5 |
| `m11_00_00_00_002501` |  | Webs — no confirmed spider | Ashina Outskirts | 2 | 14; 4 |
| `m11_00_00_00_003693` |  | Webs — no confirmed spider | Ashina Outskirts | 2 | 11, 12, 13; 2, 3, 4 |
| `m11_00_00_00_006080` |  | Likely false positive: erosion/vegetation/object | Ashina Outskirts | 2 | 2, 3; 1 |
| `m11_00_00_00_006081` |  | Likely false positive: erosion/vegetation/object | Ashina Outskirts | 2 | 2, 3; 1 |
| `m11_00_00_00_006082` |  | Likely false positive: erosion/vegetation/object | Ashina Outskirts | 2 | 2, 3; 1 |
| `m11_00_00_00_006083` |  | Likely false positive: erosion/vegetation/object | Ashina Outskirts | 2 | 2, 3; 1 |
| `m11_00_00_00_015010` |  | Webs — no confirmed spider | Ashina Outskirts | 1 | 2, 3 |
| `m11_00_00_00_015051` |  | Webs — no confirmed spider | Ashina Outskirts | 1 | 2, 3 |
| `m11_00_00_00_603000` |  | Likely false positive: erosion/vegetation/object | Ashina Outskirts | 2 | 12, 13; 1 |
| `m11_00_00_00_802040` |  | Webs — no confirmed spider | Ashina Outskirts | 1 | 0, 1, 2 |
| `m11_01_00_00_002050` |  | Webs — no confirmed spider | Ashina Castle | 1 | 7, 8, 9, 10, 11, 12, 13, 14, 15 |
| `m11_01_00_00_002060` |  | Webs — no confirmed spider | Ashina Castle | 1 | 8, 9, 10, 11, 12, 13, 14, 15, 16 |
| `m11_01_00_00_003511` |  | Webs — no confirmed spider | Ashina Castle | 1 | 6, 7, 8 |
| `m11_01_00_00_003693` |  | Webs — no confirmed spider | Ashina Castle | 2 | 8, 9, 10; 3, 4, 5 |
| `m11_01_00_00_015049` |  | Webs — no confirmed spider | Ashina Castle | 1 | 0, 1, 2 |
| `m11_01_00_00_015055` |  | Webs — no confirmed spider | Ashina Castle | 1 | 8, 9 |
| `m11_01_00_00_700090` |  | Webs — no confirmed spider | Ashina Castle | 1 | 0, 1, 2 |
| `m11_01_00_00_700091` |  | Webs — no confirmed spider | Ashina Castle | 1 | 0, 1, 2 |
| `m11_01_00_00_702000` |  | Likely false positive: erosion/vegetation/object | Ashina Castle | 1 | 3 |
| `m11_01_00_00_702210` |  | Likely false positive: erosion/vegetation/object | Ashina Castle | 1 | 4 |
| `m11_02_00_00_102000` |  | Likely false positive: erosion/vegetation/object | Ashina Reservoir | 1 | 2 |
| `m11_02_00_00_102100` |  | Likely false positive: erosion/vegetation/object | Ashina Reservoir | 1 | 1 |
| `m11_02_00_00_102200` |  | Likely false positive: erosion/vegetation/object | Ashina Reservoir | 1 | 1 |
| `m11_02_00_00_102300` |  | Likely false positive: erosion/vegetation/object | Ashina Reservoir | 1 | 40 |
| `m11_02_00_00_201090` |  | Webs — no confirmed spider | Ashina Reservoir | 1 | 0, 1, 2 |
| `m11_02_00_00_201590` |  | Webs — no confirmed spider | Ashina Reservoir | 1 | 0, 1, 2 |
| `m11_02_00_00_204000` |  | Likely false positive: erosion/vegetation/object | Ashina Reservoir | 1 | 2 |
| `m11_02_00_00_303000` |  | Webs — no confirmed spider | Ashina Reservoir | 1 | 7, 8 |
| `m11_02_00_00_304000` |  | Webs — no confirmed spider | Ashina Reservoir | 1 | 0, 1, 2 |
| `m13_00_00_00_000800` |  | Scenery/object — likely worms or centipedes | Abandoned Dungeon | 2 | 7; 2 |
| `m13_00_00_00_000810` |  | Scenery/object — likely worms or centipedes | Abandoned Dungeon | 2 | 7; 2 |
| `m13_00_00_00_001200` |  | Scenery/object — likely worms or centipedes | Abandoned Dungeon | 2 | 1, 4; 0, 2 |
| `m13_00_00_00_003001` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 0 |
| `m13_00_00_00_003011` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 0 |
| `m13_00_00_00_007000` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 0 |
| `m13_00_00_00_101000` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 0, 1, 5, 8, 10 |
| `m13_00_00_00_105000` |  | Webs — no confirmed spider | Abandoned Dungeon | 1 | 3, 5, 6 |
| `m13_00_00_00_105200` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 5 |
| `m13_00_00_00_105300` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 0 |
| `m13_00_00_00_200200` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 4 |
| `m13_00_00_00_201300` |  | Scenery/object — likely worms or centipedes | Abandoned Dungeon | 2 | 2, 3; 1, 2 |
| `m13_00_00_00_202300` |  | Webs — no confirmed spider | Abandoned Dungeon | 1 | 0, 1, 2 |
| `m13_00_00_00_205110` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 0, 2 |
| `m13_00_00_00_205111` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 0 |
| `m13_00_00_00_205120` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 0, 2 |
| `m13_00_00_00_205121` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 0 |
| `m13_00_00_00_205130` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 0 |
| `m13_00_00_00_206000` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 0 |
| `m13_00_00_00_206010` |  | Likely false positive: erosion/vegetation/object | Abandoned Dungeon | 1 | 0 |
| `m13_00_00_00_206500` |  | Scenery/object — likely worms or centipedes | Abandoned Dungeon | 1 | 0, 1, 2 |
| `m13_00_00_00_206510` |  | Scenery/object — likely worms or centipedes | Abandoned Dungeon | 1 | 0, 1 |
| `m13_00_00_00_206600` |  | Scenery/object — likely worms or centipedes | Abandoned Dungeon | 1 | 0, 1 |
| `m13_00_00_00_300000` |  | Webs — no confirmed spider | Abandoned Dungeon | 1 | 10, 11, 12 |
| `m13_00_00_00_300100` |  | Webs — no confirmed spider | Abandoned Dungeon | 1 | 8, 9, 10 |
| `m15_00_00_00_242008` |  | Webs — no confirmed spider | Mibu Village | 1 | 0, 1, 2 |
| `m15_00_00_00_602000` |  | Webs — no confirmed spider | Mibu Village | 1 | 0, 1, 2 |
| `m15_00_00_00_602010` |  | Webs — no confirmed spider | Mibu Village | 1 | 5, 6, 7 |
| `m17_00_00_00_300001` |  | Webs — no confirmed spider | Sunken Valley | 2 | 0, 1, 2, 3 |
| `m17_00_00_00_300101` |  | Webs — no confirmed spider | Sunken Valley | 2 | 0, 1, 2, 3 |
| `m17_00_00_00_300201` |  | Webs — no confirmed spider | Sunken Valley | 2 | 0, 1, 2 |
| `m17_00_00_00_300301` |  | Webs — no confirmed spider | Sunken Valley | 2 | 0, 1 |
| `m17_00_00_00_300401` |  | Webs — no confirmed spider | Sunken Valley | 2 | 0, 1, 2, 3 |
| `m17_00_00_00_301001` |  | Webs — no confirmed spider | Sunken Valley | 2 | 0, 1, 2 |
| `m17_00_00_00_808100` |  | Webs — no confirmed spider | Sunken Valley | 2 | 0, 1, 2, 3 |
| `m20_00_00_00_102030` |  | Webs — no confirmed spider | Senpou Temple | 1 | 7, 8, 9 |
| `m20_00_00_00_102031` |  | Webs — no confirmed spider | Senpou Temple | 1 | 4, 5 |
| `m20_00_00_00_102041` |  | Webs — no confirmed spider | Senpou Temple | 1 | 1, 2, 3 |
| `m20_00_00_00_102050` |  | Webs — no confirmed spider | Senpou Temple | 1 | 2, 3, 4 |
| `m20_00_00_00_122012` |  | Webs — no confirmed spider | Senpou Temple | 1 | 4, 5, 6 |
| `m20_00_00_00_132021` |  | Webs — no confirmed spider | Senpou Temple | 1 | 12, 13 |
| `m20_00_00_00_132026` |  | Webs — no confirmed spider | Senpou Temple | 1 | 0, 1, 2 |
| `m20_00_00_00_252110` |  | Webs — no confirmed spider | Senpou Temple | 1 | 8, 9, 10 |
| `m20_00_00_00_312006` |  | Webs — no confirmed spider | Senpou Temple | 1 | 2, 3, 4 |
| `m20_00_00_00_450000` |  | Scenery/object — likely worms or centipedes | Senpou Temple | 2 | 0, 1, 2, 3; 0 |
| `m20_00_00_00_450001` |  | Scenery/object — likely worms or centipedes | Senpou Temple | 2 | 1, 2, 3, 4; 1 |
| `m20_00_00_00_450002` |  | Scenery/object — likely worms or centipedes | Senpou Temple | 2 | 1, 2, 3, 4; 1 |
| `m20_00_00_00_502001` |  | Scenery/object — likely worms or centipedes | Senpou Temple | 2 | 1, 2, 3; 0, 1 |
| `m20_00_00_00_502003` |  | Scenery/object — likely worms or centipedes | Senpou Temple | 2 | 0, 1, 2, 3; 0 |
| `m20_00_00_00_502005` |  | Likely false positive: erosion/vegetation/object | Senpou Temple | 1 | 3 |
| `m20_00_00_00_602011` |  | Webs — no confirmed spider | Senpou Temple | 1 | 0, 1, 2 |
| `m20_00_00_00_632110` |  | Webs — no confirmed spider | Senpou Temple | 1 | 18, 19, 20 |
| `m20_00_00_00_800002` |  | Webs — no confirmed spider | Senpou Temple | 1 | 4, 5, 6 |
| `m20_00_00_00_810111` |  | Webs — no confirmed spider | Senpou Temple | 1 | 2, 3, 4 |
| `m20_00_00_00_820111` |  | Webs — no confirmed spider | Senpou Temple | 1 | 0, 1, 2 |
| `m20_00_00_00_830111` |  | Webs — no confirmed spider | Senpou Temple | 1 | 1, 2, 3 |
| `m20_00_00_00_840110` |  | Webs — no confirmed spider | Senpou Temple | 1 | 0, 1, 2 |
| `m20_00_00_00_850200` |  | Webs — no confirmed spider | Senpou Temple | 1 | 0, 1, 2 |
| `m20_00_00_00_860111` |  | Webs — no confirmed spider | Senpou Temple | 1 | 2, 3, 4 |
| `m25_00_00_00_000710` |  | Scenery/object — likely worms or centipedes; Scenery insects — visual inspection pending | Fountainhead Palace | 2 | 0, 1; 0 |
| `m25_00_00_00_000711` |  | Scenery/object — likely worms or centipedes; Scenery insects — visual inspection pending | Fountainhead Palace | 2 | 0, 1; 0 |
| `m25_00_00_00_000712` |  | Scenery insects — visual inspection pending | Fountainhead Palace | 2 | 0, 1; 0 |
| `m25_00_00_00_000750` |  | Scenery insects — visual inspection pending | Fountainhead Palace | 2 | 0, 1; 0 |
| `m25_00_00_00_002223` |  | Webs — no confirmed spider | Fountainhead Palace | 2 | 4, 5, 6; 1, 2, 3 |
| `m25_00_00_00_002500` |  | Webs — no confirmed spider | Fountainhead Palace | 2 | 6, 7, 8; 0, 1, 2 |
| `m25_00_00_00_002502` |  | Webs — no confirmed spider | Fountainhead Palace | 1 | 6, 7, 8 |
| `m25_00_00_00_002520` |  | Webs — no confirmed spider | Fountainhead Palace | 2 | 2, 3, 4; 1, 2, 3 |
| `m25_00_00_00_004151` |  | Webs — no confirmed spider | Fountainhead Palace | 2 | 0, 1, 2 |
| `m25_00_00_00_006700` |  | Insect container — visual inspection pending | Fountainhead Palace | 2 | 1 |
| `m25_00_00_00_311050` |  | Scenery insects — visual inspection pending | Fountainhead Palace | 2 | 0, 1; 0 |
| `o007800` | Plant | Likely false positive: erosion/vegetation/object | Not located | 1 | 0 |
| `o108100` | Hirata Estate hidden temple giant idol | Webs — no confirmed spider | Hirata Estate | 2 | 0, 1 |
| `o109910` | Bridge wooden supports? | Webs — no confirmed spider | Hirata Estate | 2 | 3, 4, 5 |
| `o109920` | Bridge wooden supports? | Webs — no confirmed spider | Hirata Estate | 2 | 4, 5, 6 |
| `o109930` | Bridge wooden supports? | Webs — no confirmed spider | Hirata Estate | 2 | 0, 1, 2 |
| `o114585` | Destroyed wooden cart | Likely false positive: erosion/vegetation/object | Not located | 2 | 9, 10; 6 |
| `o123001` | Destroyed wooden cart | Likely false positive: erosion/vegetation/object | Not located | 2 | 10, 11; 7 |
| `o124290` | Pot with cloth underneathe | Scenery/object — likely worms or centipedes | Not located | 2 | 0, 1 |
| `o134290` | Infested pot? | Scenery/object — likely worms or centipedes; Review name; not proof of a creature | Abandoned Dungeon | 4 | 2, 3, 4; 0, 1 |
| `o134390` | Infested drawer on wooden board? | Scenery/object — likely worms or centipedes; Review name; not proof of a creature | Abandoned Dungeon | 4 | 3, 4; 1, 2 |
| `o157000` | Long folder cloth | Scenery insects — visual inspection pending | Mibu Village | 2 | 3 |
| `o157001` | Long folder cloth | Scenery insects — visual inspection pending | Mibu Village | 2 | 3 |
| `o157002` | Long folder cloth | Scenery insects — visual inspection pending | Mibu Village | 2 | 3 |
| `o205900` | Infested monk | Scenery/object — likely worms or centipedes | Senpou Temple | 2 | 0, 1; 0 |
| `o205910` | Infested high priest monk | Scenery/object — likely worms or centipedes | Senpou Temple | 2 | 0, 1; 0 |
| `o253100` | Large lantern? | Insect container — visual inspection pending | Fountainhead Palace | 4 | 0 |
| `o253110` | Destroyed container | Insect container — visual inspection pending | Fountainhead Palace | 4 | 0 |

Total matching rows: **189**; distinct matching packages: **130**. These totals include false positives and variants; they are not counts of distinct creatures.
