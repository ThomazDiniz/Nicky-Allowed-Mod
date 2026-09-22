$ErrorActionPreference = 'Stop'
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$game = 'C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$source = Join-Path $root 'dist\title-label-test\mods\menu\05_000_title.gfx'
$destination = Join-Path $game 'mods\menu\05_000_title.gfx'
$validation = Get-Content (Join-Path $PSScriptRoot 'validation.json') -Raw | ConvertFrom-Json
if (Get-Process sekiro -ErrorAction SilentlyContinue) { throw 'Close Sekiro before installing the menu label.' }
if ($validation.Result -ne 'PASS' -or (Get-FileHash -LiteralPath $source).Hash -ne $validation.OutputSHA256) { throw 'Menu label validation mismatch' }
$ini = Get-Content (Join-Path $game 'modengine.ini') -Raw
if ($ini -notmatch '(?m)^useModOverrideDirectory=1\s*$' -or $ini -notmatch '(?m)^modOverrideDirectory="\\mods"\s*$') { throw 'Unexpected Mod Engine override directory' }
$backup = Join-Path $root ('work\backups\before-title-label-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $backup -Force | Out-Null
$existed = Test-Path -LiteralPath $destination
if ($existed) {
    Copy-Item -LiteralPath $destination -Destination (Join-Path $backup '05_000_title.gfx')
    if ((Get-FileHash -LiteralPath $destination).Hash -ne (Get-FileHash -LiteralPath (Join-Path $backup '05_000_title.gfx')).Hash) { throw 'Backup mismatch' }
}
[pscustomobject]@{Destination=$destination;ExistedBefore=$existed} | ConvertTo-Json | Set-Content (Join-Path $backup 'manifest.json') -Encoding utf8
New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null
Copy-Item -LiteralPath $source -Destination $destination -Force
if ((Get-FileHash -LiteralPath $destination).Hash -ne $validation.OutputSHA256) { throw 'Installed file hash mismatch' }
$result = [pscustomobject]@{Date=(Get-Date -Format o);Destination=$destination;SHA256=$validation.OutputSHA256;Backup=$backup;ExistedBefore=$existed;Installed=$true;GameTested=$false;MainReleaseChanged=$false}
$result | ConvertTo-Json | Set-Content (Join-Path $PSScriptRoot 'installation.json') -Encoding utf8
$result | ConvertTo-Json
