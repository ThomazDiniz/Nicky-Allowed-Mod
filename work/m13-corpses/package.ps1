$ErrorActionPreference='Stop'
$root=(Get-Location).Path
$old=Join-Path $root 'releases\Nicky-Allowed-Invisible-alpha-0.1.4'
$release=Join-Path $root 'releases\Nicky-Allowed-Invisible-alpha-0.1.5'
$validation=@(Get-Content work\m13-corpses\validation.json -Raw | ConvertFrom-Json)
if($validation.Count -ne 1 -or $validation[0].Result -ne 'PASS'){throw 'Validation missing'}
if(Test-Path $release){throw 'Release exists'}
Copy-Item -LiteralPath $old -Destination $release -Recurse
$relative='mods/map/m13_00_00_00/m13_00_00_00_001200.mapbnd.dcx'
$src=Join-Path $root 'dist\m13-corpses-hotfix\mods\map\m13_00_00_00\m13_00_00_00_001200.mapbnd.dcx'
Copy-Item -LiteralPath $src -Destination (Join-Path $release $relative)
if((Get-FileHash $src).Hash -ne $validation[0].SHA256){throw 'Source validation hash mismatch'}
$notice=@'
# Nicky Allowed — Invisible Centipedes — alpha 0.1.5

## New: worms on Dungeon bodies

The user inspected m13_00_00_00_001200 and authorized removing body worms. Main meshes 1/4 and _S meshes 0/2 were hidden, preserving bodies, clothes, hair and other meshes. This is an explicit worm-removal exception, not confirmed centipede identification.

There are 28 files; all previous 27 files from 0.1.4 are unchanged, including splash particles. The user confirmed the particle substitution worked without a crash in the tested encounter and the static Senpou floor removal worked. The new bodies need an in-game test.

Check the bodies nearby and at a distance: hidden worms, intact bodies/clothes/hair. The earlier grab result does not validate every monk attack or True Monk effect.

To revert only this addition, close the game and restore any previous mods/map/m13_00_00_00/m13_00_00_00_001200.mapbnd.dcx. If none existed, remove only that new file; 0.1.4 did not include it.

## Installation and upgrade

1. Close Sekiro completely and back up your current mods folder.
2. Extract the ZIP and copy its complete mods folder beside sekiro.exe, replacing this mod's previous files. Do not create mods/mods.
3. Use Sekiro Mod Engine with useModOverrideDirectory=1 and modOverrideDirectory="\mods". The loader is not included: https://www.nexusmods.com/sekiro/mods/6 .
4. Launch normally through Steam. Yabber, FLVER Editor and DSMapStudio are not needed to play.

Other mods replacing the same files require a compatible merge. Long-arm Centipede/C1030/C1040 are preserved. The future smiley model-replacement variant is separate.

## Rollback and credits

With the game closed, use FILES-SHA256.csv and your verified backup to restore replaced files and remove only newly added files. Do not delete unrelated mods. A particle-only rollback requires the three appropriate original SFX files from a verified backup. Do not restore the failed 0.1.1 particle edits.

Distribute the complete ZIP with its instructions and limitations. Tools: FLVER Editor, SoulsFormats, Yabber and DSMapStudio. Loader: Katalash's Sekiro Mod Engine. Original game content belongs to its respective rights holders.
'@
Set-Content "$release\README.md" $notice -Encoding utf8
$history=Get-Content "$old\CHANGES-AND-TESTS.md" -Raw
$changes=@'
# Current state — alpha 0.1.5

Added m13_00_00_00_001200.mapbnd.dcx: hide body-worm main meshes 1/4 and _S meshes 0/2 at the user's explicit request. Other parsed model data were compared and preserved. The binder reopened; internal files and compression passed checks. The other 27 files match 0.1.4.

The user confirmed the 0.1.4 particle substitution worked without a crash in the tested encounter. Pending-test statements in the older history predate that confirmation. Do not extend that result to every attack/variant. The new bodies require gameplay testing.

## Earlier coverage history
'@+"`n"+$history
Set-Content "$release\CHANGES-AND-TESTS.md" $changes -Encoding utf8
$manifest=@(Import-Csv "$old\FILES-SHA256.csv")
foreach($r in $manifest){if((Get-FileHash (Join-Path $release $r.File)).Hash -ne $r.SHA256){throw 'Previous payload changed'}}
$manifest += [pscustomobject]@{File=$relative;Bytes=(Get-Item $src).Length;SHA256=(Get-FileHash $src).Hash;Compression='DCX_KRAK';Models=2}
$manifest | Export-Csv "$release\FILES-SHA256.csv" -NoTypeInformation -Encoding utf8
$zip=$release+'.zip'
[IO.Compression.ZipFile]::CreateFromDirectory($release,$zip)
$archive=[IO.Compression.ZipFile]::OpenRead($zip)
try{foreach($e in $archive.Entries){$s=$e.Open();try{$h=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($s))}finally{$s.Dispose()};if($h -ne (Get-FileHash (Join-Path $release $e.FullName)).Hash){throw 'ZIP mismatch'}}}finally{$archive.Dispose()}
$hash=(Get-FileHash $zip).Hash
Set-Content ($zip+'.sha256') "$hash  $([IO.Path]::GetFileName($zip))" -Encoding ascii
[pscustomobject]@{Version='0.1.5';Packages=28;Previous27Unchanged=$true;ZipAllHashesMatch=$true;ZipSHA256=$hash;NewSceneGameTested=$false} | ConvertTo-Json | Set-Content work\alpha-015-release-validation.json
Get-Content work\alpha-015-release-validation.json
