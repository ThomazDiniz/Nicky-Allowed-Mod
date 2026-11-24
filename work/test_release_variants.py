import unittest,tempfile,json,csv,sys,io,zipfile
from pathlib import Path
from unittest.mock import patch
from contextlib import redirect_stdout
import build_release as b

class VariantBuildTests(unittest.TestCase):
 def test_real_packaging_and_gates(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=Path(tmp);releases=root/'releases';base=releases/(b.PREFIX+'0.1.8');(base/'mods/chr').mkdir(parents=True)
   (base/'mods/chr/c1013.chrbnd.dcx').write_bytes(b'invisible fixture')
   (base/'mods/sfx').mkdir();(base/'mods/sfx/shared.dcx').write_bytes(b'shared fixture')
   with (base/'FILES-SHA256.csv').open('w',newline='') as f:
    w=csv.DictWriter(f,fieldnames=b.FIELDS);w.writeheader()
    for p in (base/'mods').rglob('*'):
     if p.is_file():w.writerow(dict(File=p.relative_to(base).as_posix(),Bytes=p.stat().st_size,SHA256=b.sha(p)))
   (root/'VERSION').write_text('0.1.8');(root/'README.md').write_text('## Current release\n\nold\n\n## Coverage\n')
   (root/'variants').mkdir();profiles=json.loads((b.ROOT/'variants/profiles.json').read_text())
   (root/'variants/profiles.json').write_text(json.dumps(profiles))
   for pr in profiles.values():
    d=root/pr['templates'];d.mkdir(parents=True,exist_ok=True)
    for name in ['README.md','CHANGES-AND-TESTS.md']:(d/name).write_text('{{VERSION}} {{PAYLOAD_COUNT}}')
   (root/'work/title-menu').mkdir(parents=True)
   def menu(version,output,quiet,display_name):
    output.parent.mkdir(parents=True,exist_ok=True);output.write_bytes(display_name.encode())
    return {'Label':display_name,'Output':str(output)}
   def run(*args):
    with patch.object(sys,'argv',['build_release',*args]),redirect_stdout(io.StringIO()) as out:b.main()
    return json.loads(out.getvalue())
   with patch.object(b,'ROOT',root),patch.object(b,'RELEASES',releases),patch.object(b,'build_menu',menu):
    with self.assertRaisesRegex(ValueError,'not ready'):run('--variant','replacement')
    self.assertFalse((root/'work/release-staging').exists())
    invisible=run('--variant','invisible','--bump','patch')
    self.assertEqual((root/'VERSION').read_text().strip(),'0.1.9')
    before=(root/'README.md').read_bytes()
    profiles['replacement']['ready']=True;(root/'variants/profiles.json').write_text(json.dumps(profiles))
    overlay=root/'overlay';(overlay/'mods/chr').mkdir(parents=True)
    model=overlay/'mods/chr/c1013.chrbnd.dcx';model.write_bytes(b'replacement fixture')
    review={'Variant':'replacement','Result':'PASS','Files':[{'File':'mods/chr/c1013.chrbnd.dcx','SHA256':'wrong','VisualReplacementVerified':True}]}
    (overlay/'replacement-validation.json').write_text(json.dumps(review))
    with self.assertRaisesRegex(ValueError,'hash'):run('--variant','replacement','--overlay',str(overlay))
    review['Files'][0]['SHA256']=b.sha(model);(overlay/'replacement-validation.json').write_text(json.dumps(review))
    replacement=run('--variant','replacement','--overlay',str(overlay))
    self.assertEqual(replacement['Version'],'0.1.9');self.assertEqual(replacement['BaseRelease'],invisible['Release'])
    self.assertEqual((root/'README.md').read_bytes(),before)
    with zipfile.ZipFile(replacement['Zip']) as z:
     self.assertEqual(z.read('mods/chr/c1013.chrbnd.dcx'),b'replacement fixture')
     self.assertEqual(z.read('mods/sfx/shared.dcx'),b'shared fixture')
     self.assertIn(b'Replaced Centipedes',z.read('mods/menu/05_000_title.gfx'))
    with self.assertRaises(FileExistsError):run('--variant','replacement','--overlay',str(overlay))
    self.assertTrue(Path(invisible['Zip']).exists())

if __name__=='__main__':unittest.main()

