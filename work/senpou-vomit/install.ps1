$ErrorActionPreference='Stop'
$root=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$version=(Get-Content (Join-Path $root 'VERSION') -Raw).Trim()
if($version -ne '0.1.8'){throw 'This installer is specific to alpha 0.1.8'}
if(Get-Process sekiro -ErrorAction SilentlyContinue){throw 'Close Sekiro before installing'}
$release=Join-Path $root "releases\Nicky-Allowed-Invisible-Centipedes-alpha-$version"
$manifest=@(Import-Csv (Join-Path $release 'FILES-SHA256.csv'))
$allowed=@('mods/menu/05_000_title.gfx','mods/sfx/sfxbnd_commoneffects.ffxbnd.dcx','mods/sfx/sfxbnd_m15.ffxbnd.dcx','mods/sfx/sfxbnd_m25.ffxbnd.dcx')
$ini=Get-Content (Join-Path $game 'modengine.ini') -Raw
if($ini -notmatch '(?m)^useModOverrideDirectory=1\s*$' -or $ini -notmatch '(?m)^modOverrideDirectory="\\mods"\s*$'){throw 'Unexpected loader configuration'}
$pending=@()
foreach($row in $manifest){
 $source=[IO.Path]::GetFullPath((Join-Path $release $row.File))
 $dest=[IO.Path]::GetFullPath((Join-Path $game $row.File))
 if(!$source.StartsWith((Join-Path $release 'mods\'),[StringComparison]::OrdinalIgnoreCase) -or !$dest.StartsWith((Join-Path $game 'mods\'),[StringComparison]::OrdinalIgnoreCase)){throw 'Unsafe manifest path'}
 if((Get-FileHash -LiteralPath $source).Hash -ne $row.SHA256){throw 'Release hash mismatch'}
 $exists=Test-Path -LiteralPath $dest
 $oldHash=if($exists){(Get-FileHash -LiteralPath $dest).Hash}else{$null}
 if($oldHash -eq $row.SHA256){continue}
 if($row.File -notin $allowed){throw "Unrelated installed file differs: $($row.File)"}
 $pending+=[pscustomobject]@{File=$row.File;Source=$source;Destination=$dest;ExistedBefore=$exists;OldSHA256=$oldHash;NewSHA256=$row.SHA256}
}
$backup=Join-Path $root ('work\backups\before-alpha-018-'+(Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $backup -Force | Out-Null
foreach($item in $pending){
 if($item.ExistedBefore){
  $copy=Join-Path $backup $item.File
  New-Item -ItemType Directory -Path (Split-Path $copy -Parent) -Force | Out-Null
  Copy-Item -LiteralPath $item.Destination -Destination $copy
  if((Get-FileHash -LiteralPath $copy).Hash -ne $item.OldSHA256){throw 'Backup mismatch'}
 }
}
$pending | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $backup 'manifest.json')
if(Get-Process sekiro -ErrorAction SilentlyContinue){throw 'Sekiro restarted; installation cancelled'}
foreach($item in $pending){
 New-Item -ItemType Directory -Path (Split-Path $item.Destination -Parent) -Force | Out-Null
 Copy-Item -LiteralPath $item.Source -Destination $item.Destination -Force
}
foreach($row in $manifest){if((Get-FileHash -LiteralPath (Join-Path $game $row.File)).Hash -ne $row.SHA256){throw 'Installed hash mismatch'}}
$result=[pscustomobject]@{Date=(Get-Date -Format o);Version=$version;Installed=$true;Backup=$backup;ChangedFiles=@($pending.File);VerifiedFiles=$manifest.Count;FullReleaseHashesMatch=$true;GameTested=$false}
$result | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $root "work\alpha-$version-installation.json")
$result | ConvertTo-Json -Depth 6
