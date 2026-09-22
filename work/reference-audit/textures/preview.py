from PIL import Image
from pathlib import Path
import io,struct
r=Path(__file__).parent
for p in r.glob('*_a.dds'):
 b=bytearray(p.read_bytes())
 if b[84:88]==b'DX10':
  f=struct.unpack_from('<I',b,128)[0]
  if f in (72,75,78,99): struct.pack_into('<I',b,128,f-1)
 im=Image.open(io.BytesIO(b)); im.thumbnail((1200,1200)); im.save(p.with_suffix('.png'))
