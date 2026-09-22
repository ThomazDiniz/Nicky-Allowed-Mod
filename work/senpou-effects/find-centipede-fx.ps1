$ErrorActionPreference='Stop'
$base=Join-Path (Get-Location) 'tools_to_mod\FLVER_Editor_X2.6\Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $base 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $base 'SoulsFormats.dll')) | Out-Null
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$out=Join-Path (Get-Location) 'work\senpou-effects'
$rows=foreach($file in Get-ChildItem "$game\sfx" -Filter '*.ffxbnd.dcx') {
 $b=[SoulsFormats.BND4]::Read($file.FullName)
 foreach($e in $b.Files | Where-Object Name -Match '\.fxr$') {
  $raw=[Text.Encoding]::Latin1.GetString($e.Bytes)
  if(!$raw.Contains([Text.Encoding]::Latin1.GetString([BitConverter]::GetBytes([int]4093)))) {continue}
  $f=[SoulsFormats.FXR3]::Read([byte[]]$e.Bytes)
  $xd=[SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML($f)
  [xml]$x=$xd.ToString()
  $hits=$x.SelectNodes('//Action[@Id="603"]/Fields1/Int[@Value="4093"]')
  if($hits.Count -gt 0) {
   $xd.Save((Join-Path $out (([IO.Path]::GetFileName($e.Name))+'.xml')))
   [pscustomobject]@{Binder=$file.Name;Effect=$f.Id;CentipedeRenderers=$hits.Count;Refs=@($f.ReferenceList)}
  }
 }
}
$rows | ConvertTo-Json -Depth 8 | Set-Content "$out\centipede-fx-inventory.json"
$rows | Format-Table
foreach($name in 'c0000_c1200','c0000_c1210') {
 $path="$game\chr\$name.anibnd.dcx"
 if(Test-Path $path){$b=[SoulsFormats.BND4]::Read($path);foreach($e in $b.Files | Where-Object Name -Match '\.tae$'){[IO.File]::WriteAllBytes("$out\$name.tae",$e.Bytes)}}
}
