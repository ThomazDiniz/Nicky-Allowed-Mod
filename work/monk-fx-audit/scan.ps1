$ErrorActionPreference='Stop'
$lib=Join-Path (Get-Location) 'tools_to_mod/FLVER_Editor_X2.6/Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $lib 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $lib 'SoulsFormats.dll')) | Out-Null
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$out=Join-Path (Get-Location) 'work/monk-fx-audit'
$taes=@()
foreach($p in Get-ChildItem "$game/chr" -Filter '*.anibnd.dcx'){
 $b=[SoulsFormats.BND4]::Read($p.FullName)
 foreach($e in $b.Files){if($e.Name -match '\.tae$'){
 $name=$p.Name.Replace('.anibnd.dcx','')+'-'+[IO.Path]::GetFileName($e.Name)
 [IO.File]::WriteAllBytes((Join-Path $out $name),$e.Bytes)
 $taes+=[pscustomobject]@{Archive=$p.Name;File=$name}
 }}
}
$taes | ConvertTo-Json | Set-Content "$out/tae-index.json"
$rows=@()
foreach($p in Get-ChildItem "$game/sfx" -Filter '*.ffxbnd.dcx'){
 $b=[SoulsFormats.BND4]::Read($p.FullName)
 foreach($e in $b.Files){if($e.Name -notmatch '\.fxr$'){continue}
 $fx=[SoulsFormats.FXR3]::Read([byte[]]$e.Bytes)
 $raw=[Text.Encoding]::Latin1.GetString($e.Bytes)
 $candidate=$false
 foreach($id in @(4092,4093,11606)){
 foreach($v in @([BitConverter]::GetBytes([int]$id),[BitConverter]::GetBytes([float]$id))){if($raw.Contains([Text.Encoding]::Latin1.GetString($v))){$candidate=$true}}
 }
 $refs=@()
 if($candidate){
 [xml]$x=([SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML($fx)).ToString()
 foreach($f in $x.SelectNodes('//Action[@Id="603"]/Properties1/Property[1]/Fields/*[@Value="4092" or @Value="4093" or @Value="11606"]')){$refs+=[int]$f.Value}
 }
 $rows+=[pscustomobject]@{Binder=$p.Name;Effect=$fx.Id;References=@($fx.ReferenceList);Textures=$refs}
 }
}
$rows | ConvertTo-Json -Depth 6 | Set-Content "$out/effects.json"
"Exported $($taes.Count) TAE files; scanned $($rows.Count) effects."
