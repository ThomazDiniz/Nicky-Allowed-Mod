# Two-variant production plan

## Current status

Invisible alpha 0.1.8 remains the playable release. The replacement build profile is prepared but disabled until replacement assets exist and pass review. No game files were changed during this preparation. Both profiles share the central VERSION and have distinct archive names and title-menu labels.

## Community suggestions

Source: [Reddit discussion](https://www.reddit.com/r/Sekiro/comments/1wno6x0/comment/pbtwq3v/), supplied as pasted text by the user after Reddit blocked automated access. Suggestions are ideas, not authorized downloads or tested assets.

| Candidate | Assessment | Proposed use |
| --- | --- | --- |
| Inflatable tube man | A simple original tube mesh can follow the parasite spine. Arms, if included, need deliberate weighting and clipping checks. | Best first deforming prototype; humorous. |
| Rokurokubi-inspired head and long neck | Strong stylistic fit; requires an original head/neck, materials and careful deformation. Horror imagery may still be uncomfortable. | Preferred atmospheric option after the prototype. |
| White tube creatures suggested from Elden Ring | Their shape could work, but importing a model still requires rig, material and format adaptation. | Prefer an original tube-spirit design; do not assume permission to redistribute a ripped asset. |
| Original smiley sphere | Simple geometry and texture; a rigid head attachment does not fill the long animated body. | Fast attachment proof of concept, not a full animated replacement. |

No design has been selected for production. Ask Nick to review a neutral preview before committing to the final silhouette. Avoid legs, dense segmentation and a centipede-shaped outline.

## Production sequence

1. Begin with C1013, Hanbei's separate parasite, using the preserved original model and skeleton. Do not build from a mesh whose face sets have already been hidden.
2. Create an original low-poly tube or head/neck model with source files and a recorded redistribution license.
3. Match the original scale, orientation and attachment points. Transfer or author skin weights against the original bone chain. Preserve required bones and animation references.
4. Import the geometry into a working FLVER, with compatible materials, texture bindings, bounding boxes and face sets. Repack its binder while preserving unrelated entries.
5. Validate in the editor, then in the relevant execution/cutscene and at multiple distances. Check clipping, twisting, shadows and visibility. A rigid smiley attachment is a separate, simpler prototype.
6. Extend separately to C5001, C1200, C1210, C5000 and C5100. Embedded parasites require replacing only the selected parasite meshes, preserving the host. Do not assume all targets share a skeleton.
7. Keep the existing scenery removals and blood substitutions shared between variants initially. Replacing scenery clutter and particle sprites would be separate work.
8. Produce a complete reviewed overlay and hash-bound replacement-validation.json. Update the replacement release templates with actual coverage, and enable the profile only after review.
9. Package both variants at the same version, each as a complete standalone ZIP. Install only one at a time.

## Community coverage follow-ups

- [ ] Inspect the reported metal centipede ornament on the Shichimen Warrior's head/shoulder. Treat this as unconfirmed until the model/material is identified. If confirmed, address it in shared coverage for both variants.
- [ ] Inspect the former Great Carp corpse area for possible centipedes. The comment described worms; do not remove every worm solely on that basis.
- [x] Hanbei was already included in the invisible variant; the community reminder is not a new unresolved target.

Long-arm Centipede C1030/C1040 remains protected in both variants.

## Simplified recommendation after source inspection

The user requested minimal complexity. Fresh inspection favors a smooth rounded tube without arms or legs, starting with separate parasite C1013. A rigid sphere is simpler but follows only one attachment point. Defer the detailed Rokurokubi and inflatable-man features. See [the asset assessment](SIMPLE-REPLACEMENT-ASSESSMENT.md). No replacement was generated or installed during this assessment.
