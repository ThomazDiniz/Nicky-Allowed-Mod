# Remaining reference audit — September 21, 2026

**Result: no additional confirmed target under the references searched.** This does not rule out centipedes with other names or in content that has not been visually inspected.

The user first confirmed that the alpha 0.1.4 particle substitution worked without a crash in the tested encounter. This does not validate every attack or the True Monk.

This is a historical audit of alpha 0.1.4. The two optional follow-ups below were subsequently included in 0.1.5/0.1.6 at the user's request. Alpha 0.1.6 is now installed; see [the action plan](ACTION-PLAN.md).

## Scope actually checked

- Reanalyzed cached metadata for 14,424 FLVER models, including bones, materials, textures and aliases. This was not a fresh read of every original model.
- Compared current archive paths with the inventory: the same 6,760 packages, with none added or missing. Historical hashes of all originals were not compared.
- Read installed models with direct references: all 40 relevant meshes across 10 packages were hidden. None had three distinct face indices, a necessary condition for a visible nondegenerate face.
- Freshly read all 2,913 FXR files in eight original effect packages, with zero read errors.
- Verified that the 27 installed files matched the alpha 0.1.4 manifest.

Search terms: `mukade`, `centipede`, `millipede`, `ムカデ`, `百足`, `s04092/s04093`, and `m20_worm_03/04`. `worm`, `parasite`, and `寄生` were broader candidate terms. The FXR search examined direct field references and calls to already treated effects.

## Direct model references

The ten packages were C1013, C1200, C1210, o205900, o205910 and Senpou scenery 450000, 450001, 450002, 502001 and 502003. All meshes linked to the specific materials/textures searched were hidden in the installed files.

C5001 matched the Immortal Centipede alias and was already treated. C1030/C1040 matched their aliases but belong to the explicitly protected Long-arm family. Bone references in C1200 do not necessarily indicate a remaining visible surface.

The Ape and Monk also use generic bone names such as `Worm`; their earlier changes remained included. This audit was not a new complete visual inspection of those characters.

## Effect references

The 15 references to 4093 occurred in exactly the nine FXR files already treated:

| Package | FXR | Renderers |
| --- | --- | --- |
| Common | 612010 / 612100 / 612101 | 1 / 1 / 3 |
| m15 | 650010 / 650011 / 650012 | 1 / 1 / 3 |
| m25 | 650010 / 650011 / 650012 | 1 / 1 / 3 |

Effect 612110 calls 612100 and inherits its visual substitution; it is not an additional uncovered centipede effect.

Resources `s04092.tpf` and `s04093.tpf` remain in the common package. A texture's presence does not prove active use. No reference to 4092 was found in the action fields searched. Identified uses of 4093 were replaced in 0.1.4. Materials, shaders and other linkage mechanisms are not fully covered by that conclusion.

## Broad matches and historical follow-ups

- Seven map models matched only `worm_eaten_rock`: m11…702000 and m13…003001, 003011, 101000, 200200, 206000 and 206010. This describes eroded rock and is not centipede evidence. No changes.
- Inspected images `m13_worm_01_a` and `m13_worm_body_01_a` showed larvae/bodies without apparent legs. This did not justify a general expansion beyond centipedes; previous explicit user choices remained valid.
- **m13_00_00_00_001200:** previously displayed an empty viewport. Textures did not establish centipedes, and the complete model was not visually validated during this audit. The user later identified worms on distant bodies and authorized their removal in 0.1.5.
- **m20_worm_02_a in m20…502001:** a small texture/atlas that could not be conclusively identified from the available preview. The worm_04 layer was already hidden. The separate worm_02 layer was subsequently hidden by request in 0.1.6, without reclassifying it as confirmed centipedes.
- Scenery 201300, 206510 and 206600 remained preserved following earlier reviews; no new specific centipede evidence was found.

## Follow-up and evidence

This search alone called for no new removal. For another sighting, record the location, enemy/action and image to locate assets with different names. An empty editor viewport does not establish absence of geometry.

No mod file, installation or ZIP was changed by this audit. The 0.1.4 ZIP retained its hash at that time; the user's test confirmation was recorded separately. Older releases have since been removed to save space.

Reproducible evidence under `work/reference-audit/`: `model-references.json`, `mesh-coverage.json`, `effects-audit.json`, `installed-hashes.json` and `catalog-check.json`.
