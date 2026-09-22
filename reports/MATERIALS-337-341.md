# Material #337 and Material #341 references

**Final user validation:** o116050 and o116051 were inspected and contained no identified centipedes. Preserve both. This confirmation is reflected in alpha 0.1.6.

The user requested this search during a manual recheck. Metadata for all 14,424 inventory models were searched; the two materials in scenery 502003 were also checked directly in the original package.

In the main `m20_00_00_00_502003.flver`:

| Name | Mesh, zero-based | Actual material |
| --- | --- | --- |
| Material #337 | 2, third row | M[m20_00]_Mukade_Scroll.mtd |
| Material #341 | 3, fourth row | M[m20_00]_Mukade_Scroll2.mtd |

Both are associated with animated Mukade layers. This does not prove that each layer independently looks the same; one may complement the other. The user recognized a centipede in one layer. The audit confirms both material associations without claiming separate visual confirmation of centipedes in each. Both have been hidden since the Senpou hotfix.

Material #337 also occurs in the main and `_1` models of o116050 and o116051. Those instances use `M[AMSN]_md` and `m11_charcoal_12_a/m11_charcoal_11_n`: charcoal references, not centipede identification. Do not remove those objects based on the material number.

No other Material #341 was found in the inventory. These numbers are reusable local names, not global creature identifiers. Use actual materials/textures, such as `Mukade_Scroll/Mukade_Scroll2`, for further searches.

This query itself made no new mod edits, package or installation. At the time, installation of 0.1.5 was deferred until the next review. That historical state was superseded by installation of 0.1.6 on September 21. Evidence: `work/material-337-341-audit.json`.
