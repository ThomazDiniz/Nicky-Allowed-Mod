$ErrorActionPreference='Stop'
$root=(Get-Location).Path
$lib=Join-Path $root 'tools_to_mod\FLVER_Editor_X2.6\Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $lib 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $lib 'SoulsFormats.dll')) | Out-Null
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$base=Join-Path $root 'releases\Nicky-Allowed-Invisible-Centipedes-alpha-0.1.7\mods\sfx'
$out=Join-Path $root 'dist\senpou-vomit-fix\mods\sfx'
New-Item -ItemType Directory -Path $out -Force | Out-Null
Add-Type @"
using System;
using System.Collections.Generic;
public static class TexturePatch {
 public static int[] Find(byte[] b, byte[] p,int start,int end) {
 var hits=new List<int>(); for(int i=start;i+p.Length<=end;i+=4){bool ok=true;for(int j=0;j<p.Length;j++)if(b[i+j]!=p[j]){ok=false;break;}if(ok)hits.Add(i);}return hits.ToArray();}
 public static void Verify(byte[] a,byte[] b,int[] offsets){if(a.Length!=b.Length)throw new Exception("Length changed");for(int i=0;i<a.Length;i++){if(a[i]==b[i])continue;bool ok=false;foreach(int o in offsets)if(i>=o&&i<o+4)ok=true;if(!ok)throw new Exception("Unexpected byte change");}}
}
"@
$common=[SoulsFormats.BND4]::Read("$game\sfx\sfxbnd_commoneffects.ffxbnd.dcx")
$donor=@($common.Files | Where-Object Name -Match 'f000220505\.fxr$')[0]
[xml]$dx=([SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML([SoulsFormats.FXR3]::Read([byte[]]$donor.Bytes))).ToString()
$donorField=$dx.SelectSingleNode('//Action[@Id="603"][Fields1/Int[@Value="11606"]]/Properties1/Property[1]/Fields/Float')
if(!$donorField -or $donorField.Value -ne '11606'){throw 'Unexpected donor texture property'}
$pattern=[BitConverter]::GetBytes([float]4092)
$replacement=[BitConverter]::GetBytes([float]11606)
$audit=@();$scanned=0
foreach($path in Get-ChildItem "$game\sfx" -Filter '*.ffxbnd.dcx'){
 $b=[SoulsFormats.BND4]::Read($path.FullName)
 foreach($e in $b.Files){
  if($e.Name -notmatch '\.fxr$'){continue};$scanned++
  $hits=[TexturePatch]::Find($e.Bytes,$pattern,0,$e.Bytes.Length)
  if(!$hits.Count){continue}
  [xml]$x=([SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML([SoulsFormats.FXR3]::Read([byte[]]$e.Bytes))).ToString()
  $fields=@($x.SelectNodes('//Action[@Id="603"]/Properties1/Property[1]/Fields/Float[@Value="4092"]'))
  if($fields.Count){$audit+=[pscustomobject]@{Binder=$path.Name;Entry=$e.Name;Renderers=$fields.Count}}
 }
}
[pscustomobject]@{FXRScanned=$scanned;References=$audit} | ConvertTo-Json -Depth 8 | Set-Content work/senpou-vomit/reference-audit.json
$report=foreach($group in $audit | Group-Object Binder){
 $source=Join-Path $base $group.Name
 if(!(Test-Path $source)){throw "New binder requires review: $source"}
 $b=[SoulsFormats.BND4]::Read($source)
 $original=[SoulsFormats.BND4]::Read($source)
 $edits=@()
 foreach($target in $group.Group){
  $e=@($b.Files | Where-Object Name -eq $target.Entry)[0]
  [byte[]]$old=$e.Bytes;[byte[]]$bytes=$old.Clone()
  [xml]$x=([SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML([SoulsFormats.FXR3]::Read($old))).ToString()
  $fields=@($x.SelectNodes('//Action[@Id="603"]/Properties1/Property[1]/Fields/Float[@Value="4092"]'))
  if($fields.Count -ne $target.Renderers){throw 'Unexpected target count'}
  foreach($field in $fields){if(!$field.ParentNode.ParentNode.ParentNode.ParentNode.SelectSingleNode('Fields1/Int[@Value="11606"]')){throw 'Prior blood renderer configuration missing'}}
  $start=[BitConverter]::ToInt32($old,96);$end=$start+4*[BitConverter]::ToInt32($old,100)
  if($start -lt 160 -or $end -gt $old.Length){throw 'Invalid field section'}
  $offsets=[TexturePatch]::Find($old,$pattern,$start,$end)
  if($offsets.Count -ne $fields.Count){throw 'Ambiguous texture offsets'}
  foreach($offset in $offsets){[Array]::Copy($replacement,0,$bytes,$offset,4)}
  foreach($field in $fields){$field.SetAttribute('Value','11606')}
  [TexturePatch]::Verify($old,$bytes,$offsets)
  $expected=[Xml.Linq.XDocument]::Parse($x.OuterXml)
  $actual=[Xml.Linq.XDocument]::Parse(([SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML([SoulsFormats.FXR3]::Read($bytes))).ToString())
  foreach($doc in @($expected,$actual)){foreach($el in @($doc.Descendants())){if(!$el.HasElements -and $el.Value -eq ''){$el.RemoveNodes()}}}
  if(![Xml.Linq.XNode]::DeepEquals($expected,$actual)){throw 'Unexpected semantic change'}
  $e.Bytes=$bytes
  $edits+=[pscustomobject]@{Entry=$e.Name;Properties=$fields.Count;Offsets=$offsets;OnlyTexturePropertiesChanged=$true;LengthUnchanged=$true}
 }
 $dest=Join-Path $out $group.Name;$b.Write($dest,$b.Compression)
 $verify=[SoulsFormats.BND4]::Read($dest)
 if($verify.Compression -ne $original.Compression -or $verify.Files.Count -ne $original.Files.Count){throw 'Binder metadata mismatch'}
 for($i=0;$i -lt $b.Files.Count;$i++){
  $v=$verify.Files[$i];$e=$b.Files[$i];$o=$original.Files[$i]
  if($v.ID -ne $o.ID -or $v.Name -ne $o.Name -or $v.Flags -ne $o.Flags -or [Convert]::ToBase64String($v.Bytes) -cne [Convert]::ToBase64String($e.Bytes)){throw 'Packed entry mismatch'}
  if($e.Name -notin $group.Group.Entry -and [Convert]::ToBase64String($v.Bytes) -cne [Convert]::ToBase64String($o.Bytes)){throw 'Unrelated entry changed'}
 }
 [pscustomobject]@{Binder=$group.Name;Result='PASS';Compression=$verify.Compression.ToString();Edits=$edits;SHA256=(Get-FileHash $dest).Hash;GameTested=$false}
}
$report | ConvertTo-Json -Depth 10 | Set-Content work/senpou-vomit/validation.json
$report | Select-Object Binder,Result
"Original FXR scanned: $scanned; references: $($audit.Count); renderers: $(($audit | Measure-Object Renderers -Sum).Sum)"
