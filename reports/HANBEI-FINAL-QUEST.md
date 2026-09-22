# Hanbei's final quest — model coverage check

Checked September 22, 2026 against original game files, the alpha 0.1.7 release and installed overrides.

**The Hanbei-associated parasite is a separate C1013 model, already hidden by this mod. It is not dependent solely on the generic C5001 removal.**

| Asset | Original contents | Release / installed result |
| --- | --- | --- |
| C1012 | Hanbei's body: 29 meshes, no Worm/Centipede/Mukade bone-name matches | No override; body preserved. |
| C1013 | Separate parasite: one mesh, material `c1013_centipede_Decal.mtd`, 195 parasite bone-name matches | Mesh 0 has only degenerate face sets in both release and installed files. |
| C5001 | Separate generic Immortal Centipede: four meshes | All four meshes hidden in both release and installed files. |

The fresh Ashina Outskirts map read places C1012 as `c1012_0000`, entity 1100270, and C1013 as `c1013_0000`, entity 1100706, near Hanbei. Event initialization passes both entities together to event 11105752 from event 0 and to 11105750 from event 50. This supports the association independently of the informal alternate-Hanbei alias.

The model inspection confirms that C1013's geometry is covered. This check did not replay the final quest or independently validate every particle/camera moment in that sequence. No additional model change was necessary.

Evidence: `work/title-menu/hanbei-audit.json`; reproducible read-only audit: `work/title-menu/audit_hanbei.ps1`.
