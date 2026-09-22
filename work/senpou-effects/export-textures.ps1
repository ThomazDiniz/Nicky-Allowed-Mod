$ErrorActionPreference='Stop'
$base=Join-Path (Get-Location) 'tools_to_mod\FLVER_Editor_X2.6\Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $base 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $base 'SoulsFormats.dll')) | Out-Null
$b=[SoulsFormats.BND4]::Read('C:\Program Files (x86)\Steam\steamapps\common\Sekiro\sfx\sfxbnd_commoneffects.ffxbnd.dcx')
$out=Join-Path (Get-Location) 'work\senpou-effects\textures'
New-Item -ItemType Directory -Path $out -Force | Out-Null
$rows=foreach($e in $b.Files | Where-Object Name -Match '\.tpf$') {
 $t=[SoulsFormats.TPF]::Read([byte[]]$e.Bytes)
 foreach($tex in $t.Textures) {
  [IO.File]::WriteAllBytes((Join-Path $out ($tex.Name+'.dds')),$tex.Headerize())
  [pscustomobject]@{Entry=$e.Name;Texture=$tex.Name;Format=$tex.Format}
 }
}
$rows | Export-Csv (Join-Path $out 'inventory.csv') -NoTypeInformation
Write-Output "Exported $($rows.Count) textures"
