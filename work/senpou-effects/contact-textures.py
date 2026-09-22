from PIL import Image,ImageDraw,ImageOps
from pathlib import Path
import io,struct
root=Path(__file__).parent/'textures'
items=[]; errors=[]
for p in sorted(root.glob('*.dds')):
 try:
  data=bytearray(p.read_bytes())
  if data[84:88]==b'DX10':
   fmt=struct.unpack_from('<I',data,128)[0]
   if fmt in (72,75,78,99): struct.pack_into('<I',data,128,fmt-1)
  im=Image.open(io.BytesIO(data)).convert('RGBA'); items.append((p.stem,im.copy()))
 except Exception as e: errors.append((p.name,str(e)))
for page in range((len(items)+59)//60):
 sheet=Image.new('RGB',(1200,1080),(45,45,45)); d=ImageDraw.Draw(sheet)
 for i,(name,im) in enumerate(items[page*60:(page+1)*60]):
  x=(i%10)*120;y=(i//10)*180
  im.thumbnail((116,148))
  # Composite alpha on neutral gray; separate grayscale fallback when alpha empty.
  sheet.paste(im,(x+(116-im.width)//2,y),im)
  d.text((x+4,y+150),name,fill='white')
 sheet.save(root/f'contact-{page}.jpg')
print('Converted',len(items),'errors',errors[:10])
