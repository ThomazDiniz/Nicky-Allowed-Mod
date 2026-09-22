$ErrorActionPreference='Stop'
$root=(Get-Location).Path
$lib=Join-Path $root 'tools_to_mod\FLVER_Editor_X2.6\Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $lib 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $lib 'SoulsFormats.dll')) | Out-Null
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$out=Join-Path $root 'dist\blood-swap-test\mods\sfx'
New-Item -ItemType Directory -Path $out -Force | Out-Null
function FieldBytes($node){
 $list=[Collections.Generic.List[byte]]::new()
 foreach($field in $node.ChildNodes){
  if($field.Name -eq 'Int'){$list.AddRange([BitConverter]::GetBytes([int]::Parse($field.Value,[Globalization.CultureInfo]::InvariantCulture)))}
  elseif($field.Name -eq 'Float'){$list.AddRange([BitConverter]::GetBytes([float]::Parse($field.Value,[Globalization.CultureInfo]::InvariantCulture)))}
  else{throw 'Unknown field type'}
 }
 return ,$list.ToArray()
}
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
public static class BloodPatch {
 public static int[] Find(byte[] b, byte[] p, int start, int end) {
  var list=new List<int>();
  for(int i=start;i+p.Length<=end;i+=4){bool ok=true;for(int j=0;j<p.Length;j++){if(b[i+j]!=p[j]){ok=false;break;}}if(ok)list.Add(i);}
  return list.ToArray();
 }
 public static int Verify(byte[] a,byte[] b,int[] offsets,int length){
  if(a.Length!=b.Length)throw new Exception("File length changed");int changed=0;
  for(int i=0;i<a.Length;i++){if(a[i]==b[i])continue;changed++;bool allowed=false;foreach(int off in offsets){if(i>=off&&i<off+length){allowed=true;break;}}if(!allowed)throw new Exception("Unexpected byte change at "+i);}
  return changed;
 }
}
'@
$common=[SoulsFormats.BND4]::Read("$game\sfx\sfxbnd_commoneffects.ffxbnd.dcx")
$donorEntry=@($common.Files | Where-Object Name -Match 'f000220505\.fxr$')[0]
[xml]$donorXml=([SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML([SoulsFormats.FXR3]::Read([byte[]]$donorEntry.Bytes))).ToString()
$donor=$donorXml.SelectSingleNode('//Action[@Id="603"]/Fields1[Int[@Value="11606"]]')
if(!$donor -or $donor.ChildNodes.Count -ne 15){throw 'Donor renderer missing'}
$donorBytes=FieldBytes $donor
if($donor.ChildNodes[0].Value -ne '7' -or $donor.ChildNodes[6].Value -ne '8' -or $donor.ChildNodes[7].Value -ne '64'){throw 'Unexpected donor layout'}
if(!@($common.Files | Where-Object Name -Match 's11606\.tpf$').Count){throw 'Donor texture missing'}
$inventory=Get-Content work\senpou-effects\centipede-fx-inventory.json -Raw | ConvertFrom-Json
$report=foreach($group in $inventory | Group-Object Binder){
 $b=[SoulsFormats.BND4]::Read("$game\sfx\$($group.Name)")
 $original=[SoulsFormats.BND4]::Read("$game\sfx\$($group.Name)")
 $edits=@()
 foreach($target in $group.Group){
  $entry=@($b.Files | Where-Object Name -Match ('f{0:D9}\.fxr$' -f [int]$target.Effect))[0]
  [byte[]]$old=$entry.Bytes
  [byte[]]$bytes=$old.Clone()
  [xml]$xml=([SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML([SoulsFormats.FXR3]::Read($old))).ToString()
  $hits=@($xml.SelectNodes('//Action[@Id="603"]/Fields1[Int[@Value="4093"]]'))
  if($hits.Count -ne $target.CentipedeRenderers){throw 'Target count mismatch'}
  $fieldStart=[BitConverter]::ToInt32($old,96)
  $fieldEnd=$fieldStart+4*[BitConverter]::ToInt32($old,100)
  if($fieldStart -lt 160 -or $fieldEnd -gt $old.Length){throw 'Invalid field section'}
  $offsets=[Collections.Generic.HashSet[int]]::new()
  foreach($hit in $hits){
   [byte[]]$pattern=FieldBytes $hit
   if($pattern.Length -ne 60 -or $hit.ChildNodes[6].Value -ne '8' -or $hit.ChildNodes[7].Value -ne '64'){throw 'Incompatible target layout'}
   $matches=[BloodPatch]::Find($old,$pattern,$fieldStart,$fieldEnd)
   if(!$matches.Length){throw 'Original renderer byte sequence missing'}
   foreach($offset in $matches){[void]$offsets.Add($offset);[Array]::Copy($donorBytes,0,$bytes,$offset,60)}
   [void]$hit.ParentNode.ReplaceChild($xml.ImportNode($donor,$true),$hit)
  }
  if($offsets.Count -ne $hits.Count){throw 'Ambiguous byte matches'}
  $changed=[BloodPatch]::Verify($old,$bytes,[int[]]@($offsets),60)
  $expected=[Xml.Linq.XDocument]::Parse($xml.OuterXml)
  $actual=[Xml.Linq.XDocument]::Parse(([SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML([SoulsFormats.FXR3]::Read($bytes))).ToString())
  foreach($doc in @($expected,$actual)){foreach($el in @($doc.Descendants())){if(!$el.HasElements -and $el.Value -eq ''){$el.RemoveNodes()}}}
  if(![Xml.Linq.XNode]::DeepEquals($expected,$actual)){throw 'Parsed data differs beyond intended renderer fields'}
  $entry.Bytes=$bytes
  $edits+=[pscustomobject]@{Effect=$target.Effect;Renderers=$hits.Count;Offsets=@($offsets);ChangedBytes=$changed;LengthUnchanged=$true;AllOtherBytesIdentical=$true}
 }
 $dest=Join-Path $out $group.Name
 $b.Write($dest,$b.Compression)
 $verify=[SoulsFormats.BND4]::Read($dest)
 if($verify.Compression -ne $original.Compression -or $verify.Files.Count -ne $original.Files.Count){throw 'Binder mismatch'}
 for($i=0;$i -lt $b.Files.Count;$i++){
  $v=$verify.Files[$i];$e=$b.Files[$i];$o=$original.Files[$i]
  if($v.ID -ne $o.ID -or $v.Name -ne $o.Name -or $v.Flags -ne $o.Flags -or [Convert]::ToBase64String($v.Bytes) -cne [Convert]::ToBase64String($e.Bytes)){throw 'Packed entry mismatch'}
  if($e.Name -notmatch ('f000('+ (($group.Group.Effect) -join '|') +')\.fxr$') -and [Convert]::ToBase64String($v.Bytes) -cne [Convert]::ToBase64String($o.Bytes)){throw 'Unrelated entry changed'}
 }
 [pscustomobject]@{Binder=$group.Name;Result='PASS';DonorFXR=220505;DonorTexture=11606;Edits=$edits;SHA256=(Get-FileHash $dest).Hash;GameTested=$false}
}
$report | ConvertTo-Json -Depth 10 | Set-Content work\senpou-effects\blood-swap-validation.json
$report | Select-Object Binder,Result
