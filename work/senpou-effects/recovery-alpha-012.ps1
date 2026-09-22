$ErrorActionPreference='Stop'
$workspace=(Get-Location).Path
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$old=Join-Path $workspace 'releases\Nicky-Allowed-Invisible-alpha-0.1.1'
$release=Join-Path $workspace 'releases\Nicky-Allowed-Invisible-alpha-0.1.2'
if(Test-Path $release){throw 'Release already exists'}
Copy-Item -LiteralPath $old -Destination $release -Recurse
Copy-Item -LiteralPath "$game\modenginecrash.log" -Destination (Join-Path $workspace 'work\senpou-effects\alpha-011-grab-crash.log')
$names=@('sfxbnd_commoneffects.ffxbnd.dcx','sfxbnd_m15.ffxbnd.dcx','sfxbnd_m25.ffxbnd.dcx')
foreach($name in $names){
 Copy-Item -LiteralPath "$game\sfx\$name" -Destination "$release\mods\sfx\$name" -Force
 if((Get-FileHash "$game\sfx\$name").Hash -ne (Get-FileHash "$release\mods\sfx\$name").Hash){throw 'Original SFX mismatch'}
}
$notice=@'
# Nicky Allowed — Invisible Centipedes — alpha 0.1.2 (recovery)

## Recovery after the 0.1.1 crash

The user reported 0xC0000005 during a monk grab in 0.1.1. The effect edit is the main suspect; the log did not prove the exact cause. Do not distribute 0.1.1.

This version retains model edits and four animated Senpou floor fixes. It restores all three SFX packages byte-for-byte from game originals, included under mods/sfx to overwrite suspect effects when upgrading. Replacing all three files is essential.

Centipede particles may reappear on monks and the True Monk. Particle removal remains pending at this historical stage; repeat the grab to assess recovery. File validation does not guarantee no centipedes or crashes.

There are 26 packages: 23 edited model/scenery packages and three original effect packages. Prioritize the previously failing grab and Senpou floor. Record version, enemy, location and result; preserve modenginecrash.log before restarting after a failure.

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
$changes=(Get-Content "$old\CHANGES-AND-TESTS.md" -Raw).Replace('alpha 0.1.1','alpha 0.1.2 — 0.1.1 history below')
$changes=@'
# Current state — alpha 0.1.2 recovery

Restored all three SFX binders to the game originals after the 0.1.1 grab crash report. The other 23 character, object and scenery files remain byte-identical. Particle removals in the historical notes below are NOT active here.

- [ ] Repeat the failing grab to assess recovery.
- [ ] Validate the Senpou floor.
- [ ] Develop a particle approach preserving original effect structure.

Earlier structural validation did not detect the runtime failure. The assistant performed no gameplay test of this version.

## Previous technical history — superseded state
'@+"`n"+$changes
Set-Content "$release\CHANGES-AND-TESTS.md" $changes -Encoding utf8
$manifest=@(Import-Csv "$old\FILES-SHA256.csv")
foreach($row in $manifest){
 $path=Join-Path $release $row.File
 $hash=(Get-FileHash $path).Hash
 if($row.File -notmatch '^mods/sfx/' -and $hash -ne $row.SHA256){throw 'Non-SFX payload changed'}
 $row.SHA256=$hash;$row.Bytes=(Get-Item $path).Length
}
$manifest | Export-Csv "$release\FILES-SHA256.csv" -NoTypeInformation -Encoding utf8
$zip=$release+'.zip'
[IO.Compression.ZipFile]::CreateFromDirectory($release,$zip)
$archive=[IO.Compression.ZipFile]::OpenRead($zip)
try{
 foreach($entry in $archive.Entries){
  $stream=$entry.Open()
  try{$hash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($stream))}finally{$stream.Dispose()}
  if($hash -ne (Get-FileHash (Join-Path $release $entry.FullName)).Hash){throw 'ZIP mismatch'}
 }
}finally{$archive.Dispose()}
$zipHash=(Get-FileHash $zip).Hash
Set-Content ($zip+'.sha256') "$zipHash  $([IO.Path]::GetFileName($zip))" -Encoding ascii
[pscustomobject]@{Version='0.1.2';Packages=26;UnchangedModelMapPackages=23;OriginalSfxPackages=3;ZipAllHashesMatch=$true;ZipSHA256=$zipHash;GameTested=$false} | ConvertTo-Json | Set-Content work\alpha-012-release-validation.json
Get-Content work\alpha-012-release-validation.json
