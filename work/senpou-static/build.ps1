$ErrorActionPreference='Stop'
$base=Join-Path (Get-Location) 'tools_to_mod\FLVER_Editor_X2.6\Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $base 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $base 'SoulsFormats.dll')) | Out-Null
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$release=Join-Path (Get-Location) 'releases\Nicky-Allowed-Invisible-alpha-0.1.2'
$out=Join-Path (Get-Location) 'dist\senpou-static-hotfix\mods\map\m20_00_00_00'
New-Item -ItemType Directory -Path $out -Force | Out-Null
$candidates=Import-Csv work\map-model-inventory\candidates.csv | Where-Object Evidence -Match 'm20_worm_0[34]' | Select-Object -ExpandProperty Id -Unique
$report=foreach($id in $candidates){
 if($id -notmatch '^m20_00_00_00_'){throw 'Unexpected map'}
 $file=$id+'.mapbnd.dcx'
 $source=Join-Path $release "mods\map\m20_00_00_00\$file"
 if(!(Test-Path $source)){$source="$game\map\m20_00_00_00\$file"}
 $b=[SoulsFormats.BND4]::Read($source)
 $edits=@()
 foreach($entry in $b.Files | Where-Object Name -Match '\.flver$'){
  $original=[SoulsFormats.FLVER2]::Read([byte[]]$entry.Bytes)
  $edited=[SoulsFormats.FLVER2]::Read([byte[]]$entry.Bytes)
  $targets=@()
  for($i=0;$i -lt $edited.Meshes.Count;$i++){
   $mesh=$edited.Meshes[$i];$mat=$edited.Materials[$mesh.MaterialIndex]
   if(@($mat.Textures | Where-Object Path -Match 'm20_worm_0[34]_[an]\.tif$').Count){
    $targets+= $i
    foreach($fs in $mesh.FaceSets){for($j=0;$j -lt $fs.Indices.Count;$j++){$fs.Indices[$j]=1}}
   }
  }
  if(!$targets.Count){continue}
  $bytes=$edited.Write()
  $check=[SoulsFormats.FLVER2]::Read([byte[]]$bytes)
  foreach($i in $targets){
   for($j=0;$j -lt $check.Meshes[$i].FaceSets.Count;$j++){
    $fs=$check.Meshes[$i].FaceSets[$j]
    if(@($fs.Indices | Where-Object {$_ -ne 1}).Count){throw 'Faces not hidden'}
    $fs.Indices=$original.Meshes[$i].FaceSets[$j].Indices
   }
  }
  if(($check | ConvertTo-Json -Depth 100 -Compress) -cne ($original | ConvertTo-Json -Depth 100 -Compress)){throw 'Unrelated FLVER data changed'}
  $entry.Bytes=$bytes
  $edits+= [pscustomobject]@{Model=[IO.Path]::GetFileName($entry.Name);HiddenMeshes=$targets;OtherParsedDataUnchanged=$true}
 }
 if(!$edits.Count){throw 'No matching meshes'}
 $dest=Join-Path $out $file
 $b.Write($dest,$b.Compression)
 $verify=[SoulsFormats.BND4]::Read($dest)
 if($verify.Compression -ne $b.Compression -or $verify.Files.Count -ne $b.Files.Count){throw 'Binder mismatch'}
 for($i=0;$i -lt $b.Files.Count;$i++){
  if($verify.Files[$i].Name -ne $b.Files[$i].Name -or $verify.Files[$i].ID -ne $b.Files[$i].ID -or [Convert]::ToBase64String($verify.Files[$i].Bytes) -cne [Convert]::ToBase64String($b.Files[$i].Bytes)){throw 'Entry mismatch'}
 }
 [pscustomobject]@{Asset=$id;Source=$source;Edits=$edits;Result='PASS';SHA256=(Get-FileHash $dest).Hash;GameTested=$false}
}
$report | ConvertTo-Json -Depth 10 | Set-Content work\senpou-static\validation.json
$report | Select-Object Asset,Result
