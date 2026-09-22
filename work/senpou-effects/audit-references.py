import json,re,pathlib,csv
root=pathlib.Path(__file__).resolve().parents[2]
out=root/'work/reference-audit';out.mkdir(exist_ok=True)
strong=re.compile(r'mukade|centipede|millipede|ムカデ|百足|s0?409[23]|m20_worm_0[34]',re.I)
weak=re.compile(r'worm|parasite|寄生',re.I)
rows=[];total=0
for folder in ['creature-inventory','map-model-inventory','effect-model-inventory']:
 data=json.loads((root/'work'/folder/'models.json').read_text(encoding='utf-8-sig'))
 for m in data:
  if m['Status']!='ok':continue
  total+=1
  for i,mat in enumerate(m.get('Materials',[])):
   texts=[mat['Name'],mat['MTD']]+mat['Textures']
   for kind,pat in [('direct',strong),('candidate',weak)]:
    hits=[t for t in texts if pat.search(t or '')]
    if hits:
     meshes=[x['Index'] for x in m['Meshes'] if x['MaterialIndex']==i]
     rows.append(dict(Id=m['Id'],Model=m['Model'],Archive=m['Archive'],Kind=kind,Material=i,Meshes=meshes,Evidence=hits))
  hits=[n for n in m.get('Bones',[]) if strong.search(n or '')]
  if hits:rows.append(dict(Id=m['Id'],Model=m['Model'],Archive=m['Archive'],Kind='bone-only-check',Material=-1,Meshes=[],Evidence=hits))
  if strong.search(m.get('Alias','')):rows.append(dict(Id=m['Id'],Model=m['Model'],Archive=m['Archive'],Kind='alias',Material=-1,Meshes=[],Evidence=[m['Alias']]))
(out/'model-references.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf-8')
print('Existing inventory models rechecked:',total)
for kind in ['direct','candidate','bone-only-check','alias']:
 ids=sorted(set(r['Id'] for r in rows if r['Kind']==kind));print(kind,len(ids),', '.join(ids))
