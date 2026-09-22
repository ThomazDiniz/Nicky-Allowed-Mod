$ErrorActionPreference='Stop'
$root=(Get-Location).Path
$old=Join-Path $root 'releases\Nicky-Allowed-Invisible-alpha-0.1.3'
$release=Join-Path $root 'releases\Nicky-Allowed-Invisible-alpha-0.1.4'
$validation=@(Get-Content work\senpou-effects\blood-swap-validation.json -Raw | ConvertFrom-Json)
if($validation.Count -ne 3 -or @($validation | Where-Object Result -ne PASS).Count){throw 'Validation missing'}
if(Test-Path $release){throw 'Release exists'}
Copy-Item -LiteralPath $old -Destination $release -Recurse
Copy-Item dist\blood-swap-test\mods\sfx\* "$release\mods\sfx" -Force
$readme=@'
# Nicky Allowed — Invisible Centipedes — alpha 0.1.4 (blood particle trial)

Retains all model/scenery changes from 0.1.3 and replaces centipede particle rendering with an original splash configuration. The user confirmed the static Senpou floor removal in 0.1.3.

## Changes and test limits

Replaced visual fields in 15 renderers across nine FXR files in the common, m15 and m25 packages. The configuration comes from original FXR 220505's s11606 renderer, used by finishing events. The inspected texture shows liquid splashes without centipedes. Final appearance and grab behavior require gameplay testing at build time.

No component was deleted. Only fixed 60-byte blocks of original FXR data were patched: file sizes, internal positions, nodes, emitters, timing, trajectories and all other bytes remain. No FXR serialization rebuilt the files. Outer binders retain original compression and passed comparisons.

At initial packaging this was experimental and untested in game. File checks cannot guarantee no crash; repeat the failing grab before sharing. The 0.1.1 crash cause was not conclusively proven, and its suspect component deletion was not reused. Subsequent user test results belong in the current release notes.

The 27 packages include 24 model/scenery files and three effects. First check the grab for absent centipedes, suitable splashes, no squares/flashes and normal attack behavior. Then test other monk attacks and True Monk effects. Timing and paths remain those of the original centipede effects; this is not an entire blood-attack transplant. Preserve modenginecrash.log after a failure.

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
Set-Content "$release\README.md" $readme -Encoding utf8
$history=Get-Content "$old\CHANGES-AND-TESTS.md" -Raw
$changes=@'
# Current state — alpha 0.1.4 experimental

All 24 model/scenery packages from 0.1.3 remain byte-identical. The user confirmed static floor removal. Three effect packages now use splash rendering, as described in README.md. Historical original/restored-effect statements below refer to 0.1.3, not 0.1.4.

Replacements: common FXR 612010/612100/612101; FXR 650010/650011/650012 in both m15 and m25. Fifteen Action 603 Fields1 blocks receive the original FXR 220505/s11606 renderer configuration. Each block is 60 bytes with a 64-frame layout. All other FXR bytes, components and offsets remain; other binder entries match originals byte-for-byte.

- [x] Validate file sizes, unchanged bytes, FXR parsing and binder contents.
- [x] User confirmed the static 0.1.3 floor fix.
- [ ] Grab without crash/centipedes and with suitable splashes.
- [ ] Other monk attacks and True Monk effects.
- [ ] Approve sharing after the gameplay trial.

## Model and scenery history — 0.1.3
'@+"`n"+$history
Set-Content "$release\CHANGES-AND-TESTS.md" $changes -Encoding utf8
$manifest=@(Import-Csv "$old\FILES-SHA256.csv")
foreach($row in $manifest){
 $p=Join-Path $release $row.File;$hash=(Get-FileHash $p).Hash
 if($row.File -notmatch '^mods/sfx/' -and $hash -ne $row.SHA256){throw 'Non-SFX payload changed'}
 if($row.File -match '^mods/sfx/'){
  $v=@($validation | Where-Object Binder -eq ([IO.Path]::GetFileName($row.File)))[0]
  if(!$v -or $v.SHA256 -ne $hash){throw 'SFX validation hash mismatch'}
 }
 $row.SHA256=$hash;$row.Bytes=(Get-Item $p).Length
}
$manifest | Export-Csv "$release\FILES-SHA256.csv" -NoTypeInformation -Encoding utf8
$zip=$release+'.zip'
[IO.Compression.ZipFile]::CreateFromDirectory($release,$zip)
$archive=[IO.Compression.ZipFile]::OpenRead($zip)
try{foreach($e in $archive.Entries){$s=$e.Open();try{$h=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($s))}finally{$s.Dispose()};if($h -ne (Get-FileHash (Join-Path $release $e.FullName)).Hash){throw 'ZIP mismatch'}}}finally{$archive.Dispose()}
$hash=(Get-FileHash $zip).Hash
Set-Content ($zip+'.sha256') "$hash  $([IO.Path]::GetFileName($zip))" -Encoding ascii
[pscustomobject]@{Version='0.1.4';Packages=27;UnchangedModelMapPackages=24;ChangedSfxPackages=3;ZipAllHashesMatch=$true;ZipSHA256=$hash;GameTested=$false;Experimental=$true} | ConvertTo-Json | Set-Content work\alpha-014-release-validation.json
Get-Content work\alpha-014-release-validation.json
