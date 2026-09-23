from pathlib import Path
import json
root=Path.cwd();out=root/'work/monk-fx-audit'
r=json.loads((out/'animation-references.json').read_text())
a=json.loads((root/'tools_to_mod/DSMapStudio-1.11.1.hotfix3/Assets/Aliases/Models/SDT/Chr.json').read_text(encoding='utf-8-sig'))
names={x['id']:x['name'] for x in a['list']}
chars=sorted({x['Character'] for x in r['Matches'] if x['Blood']})
lines=['# Monk vomit and shared particle audit — September 22, 2026','','## Result','','True Monk C5000 directly invokes effect 650010 in animation 100003040. Alpha 0.1.8 already substitutes the identified centipede texture and renderer settings in that effect in both m15 and m25 packages. The installed packages match the release by SHA-256. No additional binary change or version bump was necessary. The exact vomit appearance still requires gameplay confirmation.','','## Scope','','Read 2,913 original FXR entries and 139 TAE files extracted from character animation binders. Parsed 336,787 animation events. Matched explicit first-parameter FFXID events using the Sekiro TAE template, following reverse FXR reference chains. Texture searches included the Action 603 first texture property for 4092, 4093 and donor 11606. Effect IDs duplicated across binders were conservatively merged for the reference graph, so indirect shared-texture results indicate candidates rather than definitive runtime resolution.','','## Centipede particle callers','','| Character | Animation | Effect |','| --- | --- | --- |']
for c in sorted({x['Character'] for x in r['Matches'] if x['Centipede']}):
 rows=[x for x in r['Matches'] if x['Centipede'] and x['Character']==c]
 lines.append(f"| {c} — {names.get(c,'')} | {', '.join(map(str,sorted({x['Animation'] for x in rows})))} | {', '.join(map(str,sorted({x['Effect'] for x in rows})))} |")
lines+=['','C1210 uses 612110, which calls 612100. C1200 uses 612010. C5000 uses 650010. Related effect entries 612101, 650011 and 650012 are also included in the existing substitution. All nine modified FXR entries were reopened from the current release: none retained a field value of 4092 or 4093, and all expected s11606 texture properties were present.','','## Characters using the same splash texture or a referring effect','',f'{len(chars)} character animation sets reference effects that directly or indirectly use s11606 in the original game. This is a texture-sharing inventory, not a list of enemies that vomit blood. The same sprite atlas may be recolored or used for ordinary impacts, wounds, executions or other liquids. No unrelated blood effects were changed.','','| Character alias | Referenced effect IDs |','| --- | --- |']
for c in chars:
 ids=sorted({x['Effect'] for x in r['Matches'] if x['Blood'] and x['Character']==c})
 lines.append(f"| {c} — {names.get(c,'')} | {', '.join(map(str,ids))} |")
lines+=['','## Limits and evidence','','No gameplay attack was reproduced during this audit. Event scripts, bullets, parameter-driven emitters, non-603 renderers, alternate textures and dynamic effect selection are outside this animation-to-texture search. No additional character caller of the identified centipede particle family was found within that scope; this is not proof of complete visual coverage. Long-arm C1030/C1040 remain unchanged.','','Evidence: `work/monk-fx-audit/effects.json`, `animation-references.json`, `tae-index.json` and `current-validation.json`. Reproduction scripts: `scan.ps1`, `analyze.py` and `verify.ps1`.']
(root/'reports/MONK-VOMIT-REFERENCE-AUDIT.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('Shared texture character sets:',len(chars))
for c in ['c1200','c1210','c5000','c5100','c5090','c5060','c5010','c5020']:print(c,names.get(c))
