$ErrorActionPreference='Stop'
$base=Join-Path (Get-Location) 'tools_to_mod\FLVER_Editor_X2.6\Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $base 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $base 'SoulsFormats.dll')) | Out-Null
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$out=Join-Path (Get-Location) 'work\senpou-effects'
$ids=@(612000,612001,612010,612100,612101,612110,220505,220506)
foreach($file in Get-ChildItem "$game\sfx" -Filter '*.ffxbnd.dcx') {
 $b=[SoulsFormats.BND4]::Read($file.FullName)
 foreach($entry in $b.Files) {
  if($entry.Name -match 'f(\d+)\.fxr$' -and [int]$Matches[1] -in $ids) {
   $f=[SoulsFormats.FXR3]::Read([byte[]]$entry.Bytes)
   $xml=[SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML($f)
   $xml.Save((Join-Path $out (([IO.Path]::GetFileName($entry.Name))+'.xml')))
   [pscustomobject]@{Binder=$file.Name;Effect=$f.Id;Refs=($f.ReferenceList -join ',');Bytes=$entry.Bytes.Length}
  }
 }
}
