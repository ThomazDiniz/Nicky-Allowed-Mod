$ErrorActionPreference='Stop'
$workspace=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$release=Join-Path $workspace 'releases\Nicky-Allowed-Invisible-alpha-0.1.3'
if(Get-Process sekiro -ErrorAction SilentlyContinue){throw 'Sekiro is running. Close it before installation.'}
$ini=Get-Content "$game\modengine.ini" -Raw
if($ini -notmatch '(?m)^useModOverrideDirectory=1\s*$' -or $ini -notmatch '(?m)^modOverrideDirectory="\\mods"\s*$' -or !(Test-Path "$game\dinput8.dll")){throw 'Mod Engine configuration differs from expected'}
$manifest=@(Import-Csv "$release\FILES-SHA256.csv")
if($manifest.Count -ne 27){throw 'Unexpected manifest count'}
$allowed=@('chr','obj','map','sfx')
foreach($row in $manifest){
 $full=[IO.Path]::GetFullPath((Join-Path $game $row.File))
 if(!$full.StartsWith((Join-Path $game 'mods\'),[StringComparison]::OrdinalIgnoreCase) -or $row.File.Split('/')[1] -notin $allowed){throw 'Invalid installation path'}
 if((Get-FileHash (Join-Path $release $row.File)).Hash -ne $row.SHA256){throw 'Source hash mismatch'}
}
$backup=Join-Path $workspace ('work\backups\before-alpha-013-install-'+(Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $backup | Out-Null
Copy-Item "$game\modengine.ini" $backup
$records=foreach($row in $manifest){
 $dest=Join-Path $game $row.File
 $existed=Test-Path -LiteralPath $dest
 $hash=$null
 if($existed){
  $hash=(Get-FileHash $dest).Hash
  $save=Join-Path $backup $row.File
  New-Item -ItemType Directory -Path (Split-Path $save) -Force | Out-Null
  Copy-Item -LiteralPath $dest -Destination $save
  if((Get-FileHash $save).Hash -ne $hash){throw 'Backup verification failed'}
 }
 [pscustomobject]@{File=$row.File;ExistedBefore=$existed;OldSHA256=$hash;NewSHA256=$row.SHA256}
}
$records | ConvertTo-Json | Set-Content "$backup\installation-manifest.json"
if(Get-Process sekiro -ErrorAction SilentlyContinue){throw 'Sekiro was opened; nothing installed'}
foreach($row in $manifest){
 $dest=Join-Path $game $row.File
 New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null
 Copy-Item -LiteralPath (Join-Path $release $row.File) -Destination $dest -Force
 if((Get-FileHash $dest).Hash -ne $row.SHA256){throw "Installed hash mismatch: $($row.File)"}
}
[pscustomobject]@{Version='0.1.3';Installed=$true;Packages=27;AllHashesMatch=$true;Backup=$backup;GameClosed=$true;GameTested=$false;Date=(Get-Date -Format o)} | ConvertTo-Json | Set-Content (Join-Path $workspace 'work\alpha-013-installation.json')
Get-Content (Join-Path $workspace 'work\alpha-013-installation.json')
