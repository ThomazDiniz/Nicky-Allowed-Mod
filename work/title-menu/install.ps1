$ErrorActionPreference = 'Stop'
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$game = 'C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$version = (Get-Content (Join-Path $root 'VERSION') -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid VERSION' }
$release = Join-Path $root ("releases\Nicky-Allowed-Invisible-Centipedes-alpha-" + $version)
$source = Join-Path $release 'mods\menu\05_000_title.gfx'
$destination = Join-Path $game 'mods\menu\05_000_title.gfx'
$validation = Get-Content (Join-Path $PSScriptRoot 'validation.json') -Raw | ConvertFrom-Json
if (Get-Process sekiro -ErrorAction SilentlyContinue) { throw 'Close Sekiro before installing the menu label.' }
if ($validation.Result -ne 'PASS' -or (Get-FileHash -LiteralPath $source).Hash -ne $validation.OutputSHA256) { throw 'Menu label validation mismatch' }
$manifest = @(Import-Csv (Join-Path $release 'FILES-SHA256.csv'))
foreach ($row in $manifest) {
    $installedPath = [IO.Path]::GetFullPath((Join-Path $game $row.File))
    if (-not $installedPath.StartsWith((Join-Path $game 'mods\'),[StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid manifest path' }
    if ($row.File -eq 'mods/menu/05_000_title.gfx') { continue }
    if (-not (Test-Path -LiteralPath $installedPath) -or (Get-FileHash -LiteralPath $installedPath).Hash -ne $row.SHA256) { throw "Existing payload differs; install the complete release first: $($row.File)" }
}
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
$result = [pscustomobject]@{Date=(Get-Date -Format o);Version=$version;Destination=$destination;SHA256=$validation.OutputSHA256;Backup=$backup;ExistedBefore=$existed;Installed=$true;FullReleaseHashesMatch=$true;VerifiedFiles=$manifest.Count;BaseLabelUserValidated=$true;VersionSuffixGameTested=$false;AdditionalUserTestRequired=$false}
$result | ConvertTo-Json | Set-Content (Join-Path $PSScriptRoot 'installation.json') -Encoding utf8
$result | ConvertTo-Json | Set-Content (Join-Path $root ("work\alpha-" + $version + '-installation.json')) -Encoding utf8
$result | ConvertTo-Json
