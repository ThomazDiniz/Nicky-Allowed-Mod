$ErrorActionPreference='Stop'
$root=(Get-Location).Path
$lib=Join-Path $root 'tools_to_mod\FLVER_Editor_X2.6\Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $lib 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $lib 'SoulsFormats.dll')) | Out-Null
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$refs=Get-Content work\reference-audit\model-references.json -Raw | ConvertFrom-Json
$report=foreach($g in $refs | Where-Object Kind -eq direct | Group-Object Archive){
 $relative=[IO.Path]::GetRelativePath($game,$g.Name)
 $installed=Join-Path "$game\mods" $relative
 $hasOverride=Test-Path $installed
 $b=[SoulsFormats.BND4]::Read($(if($hasOverride){$installed}else{$g.Name}))
 foreach($mg in $g.Group | Group-Object Model){
  $entry=@($b.Files | Where-Object Name -eq $mg.Name)[0]
  $m=[SoulsFormats.FLVER2]::Read([byte[]]$entry.Bytes)
  foreach($r in $mg.Group){foreach($i in $r.Meshes){
   $visible=$false
   foreach($fs in $m.Meshes[$i].FaceSets){if(@($fs.Indices | Select-Object -Unique).Count -ge 3){$visible=$true}}
   [pscustomobject]@{Id=$r.Id;Model=[IO.Path]::GetFileName($mg.Name);Mesh=$i;Material=$r.Material;OverrideExists=$hasOverride;PotentiallyVisible=$visible;Evidence=$r.Evidence}
  }}
 }
}
$report | ConvertTo-Json -Depth 8 | Set-Content work\reference-audit\mesh-coverage.json
$report | Where-Object PotentiallyVisible | Select-Object Id,Model,Mesh,@{N='Evidence';E={$_.Evidence -join ' | '}} | Format-Table -Wrap
"Direct reference meshes: $($report.Count); potentially visible: $(@($report | Where-Object PotentiallyVisible).Count)"
$texRows=@();$fxRows=@();$indirect=@();$count=0;$errors=@()
$ids=@(612010,612100,612101,650010,650011,650012)
foreach($path in Get-ChildItem "$game\sfx" -Filter '*.ffxbnd.dcx'){
 $b=[SoulsFormats.BND4]::Read($path.FullName)
 foreach($e in $b.Files){
  if($e.Name -match '(?i)mukade|centipede|ムカデ|百足|s0409[23]\.tpf'){$texRows+=[pscustomobject]@{Binder=$path.Name;Name=$e.Name}}
  if($e.Name -notmatch '\.fxr$'){continue}
  $count++
  try{
   $fx=[SoulsFormats.FXR3]::Read([byte[]]$e.Bytes)
   if(@($fx.ReferenceList | Where-Object {$_ -in $ids}).Count){$indirect+=[pscustomobject]@{Binder=$path.Name;Effect=$fx.Id;Targets=@($fx.ReferenceList | Where-Object {$_ -in $ids})}}
   # Only serialize candidates that contain either texture id; then require a renderer field.
   $raw=[Text.Encoding]::Latin1.GetString($e.Bytes)
   if(!$raw.Contains([Text.Encoding]::Latin1.GetString([BitConverter]::GetBytes([int]4092))) -and !$raw.Contains([Text.Encoding]::Latin1.GetString([BitConverter]::GetBytes([int]4093)))){continue}
   [xml]$x=([SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML($fx)).ToString()
   foreach($a in $x.SelectNodes('//Action/Fields1/Int[@Value="4092" or @Value="4093"]')){
    $fxRows+=[pscustomobject]@{Binder=$path.Name;Effect=$fx.Id;Action=$a.ParentNode.ParentNode.Id;Value=$a.Value;KnownTarget=($fx.Id -in $ids)}
   }
  }catch{$errors+=[pscustomobject]@{Binder=$path.Name;Entry=$e.Name;Error=$_.Exception.Message}}
 }
}
[pscustomobject]@{OriginalFXRScanned=$count;Errors=$errors;TextureEntries=$texRows;DirectReferences=$fxRows;Referrers=$indirect} | ConvertTo-Json -Depth 10 | Set-Content work\reference-audit\effects-audit.json
"FXRs scanned: $count; Errors: $($errors.Count); Texture field matches: $($fxRows.Count)"
$fxRows | Group-Object Binder,Effect,Value | Select-Object Name,Count
$indirect | Format-Table
