$ErrorActionPreference='Stop'
$base=Join-Path (Get-Location) 'tools_to_mod\FLVER_Editor_X2.6\Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $base 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $base 'SoulsFormats.dll')) | Out-Null
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$out=Join-Path (Get-Location) 'dist\senpou-centipede-hotfix\mods\sfx'
New-Item -ItemType Directory -Path $out -Force | Out-Null
$inventory=Get-Content work\senpou-effects\centipede-fx-inventory.json -Raw | ConvertFrom-Json
$report=foreach($group in $inventory | Group-Object Binder) {
 $path=Join-Path "$game\sfx" $group.Name
 $b=[SoulsFormats.BND4]::Read($path)
 $original=[SoulsFormats.BND4]::Read($path)
 $changed=@{}
 foreach($target in $group.Group) {
  $e=@($b.Files | Where-Object Name -Match ('f{0:D9}\.fxr$' -f [int]$target.Effect))
  if($e.Count -ne 1){throw 'Effect match not unique'}
  $e=$e[0]
  $fx=[SoulsFormats.FXR3]::Read([byte[]]$e.Bytes)
  [xml]$xml=([SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML($fx)).ToString()
  $hits=@($xml.SelectNodes('//Action[@Id="603"]/Fields1/Int[@Value="4093"]'))
  if($hits.Count -ne $target.CentipedeRenderers){throw 'Renderer count changed'}
  foreach($hit in $hits) {
   $effect=$hit.ParentNode.ParentNode.ParentNode.ParentNode
   if($effect.Name -ne 'Effect' -or $effect.Id -ne '1004' -or @($effect.SelectNodes('./Actions/Action[@Id="603"]')).Count -ne 1){throw 'Unexpected effect structure'}
   [void]$effect.ParentNode.RemoveChild($effect)
  }
  $expected=[Xml.Linq.XDocument]::Parse($xml.OuterXml)
  $edited=[SoulsFormats.FXR3EnhancedSerialization]::XMLToFXR3($expected)
  $bytes=$edited.Write()
  $check=[SoulsFormats.FXR3]::Read([byte[]]$bytes)
  $actual=[SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML($check)
  $actualClean=[Xml.Linq.XDocument]::Parse($actual.ToString())
  foreach($doc in @($expected,$actualClean)){foreach($el in @($doc.Descendants())){if(!$el.HasElements -and $el.Value -eq ''){$el.RemoveNodes()}}}
  if(![Xml.Linq.XNode]::DeepEquals($expected,$actualClean)){
   $expected.Save((Join-Path (Get-Location) 'work\senpou-effects\roundtrip-expected.xml'))
   $actual.Save((Join-Path (Get-Location) 'work\senpou-effects\roundtrip-actual.xml'))
   throw "FXR round-trip mismatch $($target.Effect)"
  }
  $e.Bytes=$bytes
  $changed[$e.ID]=[pscustomobject]@{Effect=$target.Effect;RemovedParticleEffects=$hits.Count;OtherParsedDataUnchanged=$true}
 }
 $dest=Join-Path $out $group.Name
 $b.Write($dest,$b.Compression)
 $check=[SoulsFormats.BND4]::Read($dest)
 if($check.Compression -ne $original.Compression -or $check.Files.Count -ne $original.Files.Count){throw 'Binder metadata mismatch'}
 for($i=0;$i -lt $check.Files.Count;$i++){
  $a=$check.Files[$i];$expected=$b.Files[$i];$o=$original.Files[$i]
  if($a.ID -ne $o.ID -or $a.Name -ne $o.Name -or $a.Flags -ne $o.Flags){throw 'Entry metadata changed'}
  if([Convert]::ToBase64String($a.Bytes) -cne [Convert]::ToBase64String($expected.Bytes)){throw 'Binder byte mismatch'}
  if(!$changed.ContainsKey($a.ID) -and [Convert]::ToBase64String($a.Bytes) -cne [Convert]::ToBase64String($o.Bytes)){throw 'Unrelated entry changed'}
 }
 [pscustomobject]@{Binder=$group.Name;Result='PASS';Compression=$check.Compression.ToString();Edits=@($changed.Values);UnrelatedEntriesByteIdentical=$true;SHA256=(Get-FileHash $dest).Hash;GameTested=$false}
}
$report | ConvertTo-Json -Depth 10 | Set-Content work\senpou-effects\fx-hotfix-validation.json
$report | Select-Object Binder,Result,Compression,@{N='EditedFXR';E={$_.Edits.Count}}
