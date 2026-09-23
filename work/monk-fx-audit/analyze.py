import json,struct,xml.etree.ElementTree as ET
from pathlib import Path
root=Path(__file__).parent
fx=json.loads((root/'effects.json').read_text(encoding='utf-8-sig'))
actions={int(a.attrib['id']):a for a in ET.parse(root.parent/'senpou-effects/TAE.Template.SDT.xml').iter('action')}
graph={}
for f in fx: graph.setdefault(f['Effect'],set()).update(f['References'])
def closure(seeds):
 result=set(seeds)
 while True:
  more={i for i,refs in graph.items() if refs & result}-result
  if not more:return result
  result.update(more)
cent=closure({f['Effect'] for f in fx if set(f['Textures']) & {4092,4093}})
blood=closure({f['Effect'] for f in fx if 11606 in f['Textures']})
rows=[];total=0
for p in root.glob('*.tae'):
 b=p.read_bytes()
 def u(fmt,pos):return struct.unpack_from('<'+fmt,b,pos)[0]
 assert b[:4]==b'TAE ' and u('i',8)==0x1000d and b[7]==255
 for i in range(u('i',84)):
  off=u('q',88)+i*16;aid=u('q',off);ao=u('q',off+8)
  for j in range(u('i',ao+32)):
   total+=1;h=u('q',ao)+j*24;d=u('q',h+16);typ=u('i',d);a=actions.get(typ)
   if a is None or not len(a) or a[0].attrib.get('name')!='FFXID':continue
   fid=u('i',d+16)
   if fid in cent|blood:
    rows.append(dict(Character=p.name.split('-')[0],TAE=p.name,Animation=aid,Event=typ,Effect=fid,Centipede=fid in cent,Blood=fid in blood))
report=dict(EventsScanned=total,TAEFiles=len(list(root.glob('*.tae'))),CentipedeEffects=sorted(cent),BloodEffects=sorted(blood),Matches=rows)
(root/'animation-references.json').write_text(json.dumps(report,indent=2))
print('TAEs',report['TAEFiles'],'events',total,'centipede effect chain',sorted(cent))
for kind in ('Centipede','Blood'):
 print(kind)
 for c in sorted({r['Character'] for r in rows if r[kind]}):
  subset=[r for r in rows if r[kind] and r['Character']==c]
  print(c,'effects',sorted({r['Effect'] for r in subset}),'animations',sorted({r['Animation'] for r in subset}))
