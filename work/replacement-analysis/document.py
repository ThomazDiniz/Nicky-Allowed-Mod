import json
from pathlib import Path
r=Path.cwd()
p=r/'variants/replacement-plan.json';j=json.loads(p.read_text(encoding='utf-8'));j['candidate']='Recommended after file inspection: a smooth low-poly tube with rounded end, solid color, no legs or arms; user selection pending';p.write_text(json.dumps(j,indent=2)+'\n',encoding='utf-8')
text='''# Simplest replacement assessment

September 25, 2026. Fresh read-only inspection of the original six character binders with SoulsFormats. This is a structural assessment, not a rendered preview or animation test. Evidence: work/replacement-analysis/models.json. No game or release files changed.

## Recommendation

Use an original smooth low-poly tube with a rounded end and one solid color. Avoid arms, legs, segmentation and a detailed face for the first prototype. This is simpler than a complete inflatable man or Rokurokubi while retaining a long silhouette that can follow the existing parasite animation. A smiley can be added later as a small texture detail.

A sphere rigidly attached to one bone is the smallest geometry/weighting prototype, but it does not follow the whole parasite body and can leave execution motions visually disconnected. The tube is the simplest useful deforming replacement. Neither option has yet been imported or tested.

## Original asset observations

| Character | Total meshes | Total skeleton nodes | Selected parasite-related meshes | Consequence |
| --- | ---: | ---: | --- | --- |
| C1013 | 1 | 236 | 0: 20,869 vertices | Best starting point: separate parasite, no host body to preserve inside the FLVER. |
| C5001 | 4 | 253 | 0–3 | Similar Worm/leg naming, but not an identical skeleton; adapt after C1013. |
| C5000 | 36 | 571 | 25: 21,430 vertices | Worm1/Worm2 chain exists; preserve all host meshes. |
| C5100 | 34 | 789 | 32/33 | WormRoot and Worm_Spine names differ; requires separate mapping. |
| C1200 | 15 | 836 | 0/1/5/12 | Multiple parasite-related layers, including scrolling materials; defer until the standalone prototype works. |
| C1210 | 26 | 340 | 3/4/10/11/14/21/22/23/24 | Multiple layers and GroundWorm controls; not a simple one-mesh transplant. |

Node counts describe the complete source skeleton, not how many bones the replacement must use. C1013 explicitly includes a Worm1, Worm2, Worm3 body chain interleaved with R_WormLeg/L_WormLeg nodes. New tube geometry should follow body bones, not leg bones. Preserve the original skeleton and animation references. Inspect bone transforms and vertex weight/index conventions before generating or transferring weights; node names alone are not sufficient.

## Next implementation step

1. Work on an original C1013 copy in a separate prototype folder.
2. Resolve its body-bone chain and coordinate transforms; generate one simple rounded tube along that chain.
3. Bind only the replacement vertices to suitable body bones. Retain the existing skeleton, host-independent attachments and required metadata.
4. Hide the original mesh, add the replacement with a compatible simple material, and rebuild bounds/face sets as needed. Do not keep the original centipede surface texture.
5. Reopen the packed model and inspect deformation before a gameplay test of Hanbei's final sequence.
6. Only then adapt the successful design to the other targets. Keep scenery and particle behavior as currently configured.

Do not remove leg bones merely because the new geometry has no legs. There is no need to author a new animation for the proposed prototype, but compatibility must be verified. Long-arm C1030/C1040 remains untouched. The replacement profile stays disabled until actual assets pass review.
'''
(r/'reports/SIMPLE-REPLACEMENT-ASSESSMENT.md').write_text(text,encoding='utf-8')
p=r/'reports/REPLACEMENT-VARIANT-PLAN.md';s=p.read_text(encoding='utf-8');s+='\n## Simplified recommendation after source inspection\n\nThe user requested minimal complexity. Fresh inspection favors a smooth rounded tube without arms or legs, starting with separate parasite C1013. A rigid sphere is simpler but follows only one attachment point. Defer the detailed Rokurokubi and inflatable-man features. See [the asset assessment](SIMPLE-REPLACEMENT-ASSESSMENT.md). No replacement was generated or installed during this assessment.\n';p.write_text(s,encoding='utf-8')
