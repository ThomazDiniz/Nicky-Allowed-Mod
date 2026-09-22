import struct,json,pathlib,xml.etree.ElementTree as ET
root=pathlib.Path(__file__).parent
actions={int(x.attrib['id']): x.attrib.get('name','') for x in ET.parse(root/'TAE.Template.SDT.xml').iter('action')}
for path in root.glob('*.tae'):
 b=path.read_bytes()
 def u(fmt,pos): return struct.unpack_from('<'+fmt,b,pos)[0]
 assert b[:4]==b'TAE ' and u('i',8)==0x1000d and b[7]==255
 count=u('i',84); off=u('q',88); rows=[]
 for i in range(count):
  aid=u('q',off+i*16); ao=u('q',off+i*16+8)
  eo=u('q',ao); ec=u('i',ao+32)
  assert 0<=ec<10000
  for j in range(ec):
   h=eo+j*24; st=u('q',h); en=u('q',h+8); d=u('q',h+16)
   typ=u('i',d); po=u('q',d+8); assert po in (0,d+16)
   rows.append(dict(Animation=aid,Type=typ,Name=actions.get(typ,''),Start=round(u('f',st),4),End=round(u('f',en),4),ParamOffset=d+16,Ints=[u('i',d+16+k*4) for k in range(4)]))
 (root/(path.stem+'-events.json')).write_text(json.dumps(rows,indent=2))
 fx=[r for r in rows if 'FFX' in r['Name']]
 print(path.stem,count,'animations;',len(rows),'events; FFX IDs:',sorted(set(r['Ints'][0] for r in fx)))
 for r in fx:
  if 612000<=r['Ints'][0]<613000: print(r)
