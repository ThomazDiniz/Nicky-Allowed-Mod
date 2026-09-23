# Monk vomit and shared particle audit — September 22, 2026

## Result

True Monk C5000 directly invokes effect 650010 in animation 100003040. Alpha 0.1.8 already substitutes the identified centipede texture and renderer settings in that effect in both m15 and m25 packages. The installed packages match the release by SHA-256. No additional binary change or version bump was necessary. The exact vomit appearance still requires gameplay confirmation.

## Scope

Read 2,913 original FXR entries and 139 TAE files extracted from character animation binders. Parsed 336,787 animation events. Matched explicit first-parameter FFXID events using the Sekiro TAE template, following reverse FXR reference chains. Texture searches included the Action 603 first texture property for 4092, 4093 and donor 11606. Effect IDs duplicated across binders were conservatively merged for the reference graph, so indirect shared-texture results indicate candidates rather than definitive runtime resolution.

## Centipede particle callers

| Character | Animation | Effect |
| --- | --- | --- |
| c1200 — Infested Seeker (Parasite) | 4100, 4101 | 612010 |
| c1210 — Infested Seeker | 3002, 3003, 3004 | 612110 |
| c5000 — Corrupted Monk | 100003040 | 650010 |

C1210 uses 612110, which calls 612100. C1200 uses 612010. C5000 uses 650010. Related effect entries 612101, 650011 and 650012 are also included in the existing substitution. All nine modified FXR entries were reopened from the current release: none retained a field value of 4092 or 4093, and all expected s11606 texture properties were present.

## Characters using the same splash texture or a referring effect

50 character animation sets reference effects that directly or indirectly use s11606 in the original game. This is a texture-sharing inventory, not a list of enemies that vomit blood. The same sprite atlas may be recolored or used for ordinary impacts, wounds, executions or other liquids. No unrelated blood effects were changed.

| Character alias | Referenced effect IDs |
| --- | --- |
| c0000 — Player | 220500, 220501, 220502, 220505, 220506, 220508, 220600, 220602, 229500, 229501, 229502, 300001, 310391, 613422, 615040, 615041, 650132, 650691, 650692, 671100, 671105 |
| c1010 — Ashina Soldier | 220505, 220506, 229500 |
| c1020 — Samurai General | 220500, 220501, 220505, 220506 |
| c1030 — Centipede | 220505, 220506, 220508 |
| c1040 — Centipede Boss | 220505, 220506, 220508, 220510 |
| c1050 — Shinobi Hunter | 220500, 220505, 220506, 220508 |
| c1060 — Spear Adept | 220500, 220505, 220506, 220508 |
| c1070 — Shura Samurai | 220505, 220506 |
| c1080 — Shichimen Warrior | 220500, 220501, 220505, 220506 |
| c1100 — Gecko | 230505, 230508, 231505, 231508 |
| c1110 — Old Maid | 220505, 220506, 600810 |
| c1120 — Sentry | 220505, 220506, 220508 |
| c1140 — Rock Diver | 220500, 220502, 220505, 611403 |
| c1150 — Hound | 220505, 220506, 220508, 255505, 255506 |
| c1180 — Taro Troop | 220500, 220505, 220506, 220508, 229500 |
| c1190 — Sunken Valley Clan | 220505, 220506, 220508, 220509, 255505, 255506, 255508, 600810 |
| c1200 — Infested Seeker (Parasite) | 220505, 220506 |
| c1210 — Infested Seeker | 220505, 220506 |
| c1211 — Cricket | 612120 |
| c1220 — Seeker | 220505, 220506, 255505, 255506 |
| c1240 — Gamefowl | 220505, 220506, 220508, 300021 |
| c1250 — Valley Monkey | 220505, 220506, 220508, 255505, 255506, 255508 |
| c1300 — Palace Noble | 220505, 220506, 220508 |
| c1310 — Okami Warrior | 220505, 220506, 600810 |
| c1350 — Headless | 220501, 220505, 220506, 613530 |
| c1360 — Assassin (Senpou) | 220505, 220506 |
| c1370 — Blazing Bull | 220500, 220505, 220506 |
| c1400 — Fencer | 220500, 220505, 220506, 220508, 220509, 220510, 255500, 255505, 255508 |
| c1450 — Nightjar Ninja | 220505, 220506, 255505, 255506 |
| c1470 — Lone Shadow | 220500, 220505, 220506, 220508, 220509, 220510 |
| c1500 — Mibu Villager | 220502, 220506, 220507, 220508, 220509, 229500, 255506, 255508, 600810 |
| c1550 — Bandit | 220505, 220506, 255505, 255506 |
| c1700 — Red Guard | 220505, 220506 |
| c5000 — Corrupted Monk | 220605, 220606, 255605, 255606, 600810, 696015 |
| c5010 — Great Serpent | 650130, 650134, 650135 |
| c5020 — Chained Ogre | 220505, 220506, 220507 |
| c5060 — Owl | 220505, 220506, 220508, 650690 |
| c5080 — Gyoubu Oniwa | 220505, 220507 |
| c5090 — Lady Butterfly | 220501, 220502, 220505, 220506, 229501, 600810 |
| c5100 — Guardian Ape | 220505, 220506, 651000, 651026 |
| c5300 — Old Dragon | 220506 |
| c5400 — Sword Saint Isshin | 220506, 220509 |
| c7000 — O'Rin | 220505, 220506, 600810 |
| c7020 — Demon of Hatred | 220505, 220606 |
| c7100 — Genichiro Ashina | 220502, 220505 |
| c7110 — Genichiro, Way of Tomoe | 220502, 220505, 220506, 671103 |
| c7400 — Emma | 220506, 600810, 674020 |
| c9800 —  | 220505, 220506 |
| c9820 —  | 220505, 220506 |
| c9830 —  | 220505, 220506 |

## Limits and evidence

No gameplay attack was reproduced during this audit. Event scripts, bullets, parameter-driven emitters, non-603 renderers, alternate textures and dynamic effect selection are outside this animation-to-texture search. No additional character caller of the identified centipede particle family was found within that scope; this is not proof of complete visual coverage. Long-arm C1030/C1040 remain unchanged.

Evidence: `work/monk-fx-audit/effects.json`, `animation-references.json`, `tae-index.json` and `current-validation.json`. Reproduction scripts: `scan.ps1`, `analyze.py` and `verify.ps1`.
