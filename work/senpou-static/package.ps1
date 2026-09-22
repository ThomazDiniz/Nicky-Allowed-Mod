$ErrorActionPreference='Stop'
$root=(Get-Location).Path
$release=Join-Path $root 'releases\Nicky-Allowed-Invisible-alpha-0.1.3'
$old=Join-Path $root 'releases\Nicky-Allowed-Invisible-alpha-0.1.2'
$checks=@(Get-Content work\senpou-static\validation.json -Raw | ConvertFrom-Json)
if($checks.Count -ne 5 -or @($checks | Where-Object Result -ne PASS).Count){throw 'Validation incomplete'}
if(Test-Path $release){throw 'Release already exists'}
Copy-Item -LiteralPath $old -Destination $release -Recurse
Copy-Item -Path dist\senpou-static-hotfix\mods\map\m20_00_00_00\* -Destination "$release\mods\map\m20_00_00_00" -Force
$readme=(Get-Content "$old\README.md" -Raw).Replace('alpha 0.1.2 (recovery)','alpha 0.1.3').Replace('version 0.1.2','version 0.1.3').Replace('26 packages: 23','27 packages: 24')
$new=@'
## New in 0.1.3 — dead centipedes on the floor

Hidden static layers using m20_worm_03_a/m20_worm_04_a in five Senpou pieces: 450000, 450001, 450002, 502001 and 502003, including _S variants. Texture inspection confirmed centipedes mixed with other insects; entire insect layers were hidden. Stone, wood and other meshes remain. Previous animated-layer fixes are included, and the user reported the animated floor was resolved before this update.

Revisit the photographed floor nearby and at a distance to check stationary centipedes are absent and the floor remains intact. The new static edit is file-validated but not gameplay-tested at this historical stage. No new attack-particle edit is included; the three original SFX binders from recovery 0.1.2 remain.
'@
$readme=$readme.Replace('## Recovery after the 0.1.1 crash',($new+"`n## 0.1.1 crash recovery retained"))
Set-Content "$release\README.md" $readme -Encoding utf8
$changes=(Get-Content releases\Nicky-Allowed-Invisible-alpha-0.1.0\CHANGES-AND-TESTS.md -Raw)
$changes=$changes.Substring(0,$changes.IndexOf('## Six models deferred for follow-up')).Replace('alpha 0.1.0','alpha 0.1.3')
$changes+=@'
## Senpou animated and static layers

| Piece in m20_00_00_00 | Hidden animated meshes | Hidden static meshes | Hidden static _S meshes |
| --- | --- | --- | --- |
| 450000 | 2/3 | 0/1 | 0 |
| 450001 | 3/4 | 1/2 | 1 |
| 450002 | 3/4 | 1/2 | 1 |
| 502001 | None | 3 | 1 |
| 502003 | 2/3 | 0/1 | 0 |

Static textures m20_worm_03_a/m20_worm_04_a were visually confirmed as centipedes and other insects. Their face indices were made degenerate; other parsed data and internal files remained unchanged. All five binders reopened and passed checks. Previous animated-layer edits remain.

The user confirmed the animated floor result but reported stationary insects remained. Static changes still require gameplay testing at this stage. The worm name alone was not the basis for removal: images were inspected.

## Grab effects: recovery retained

The user reported a grab crash in 0.1.1. These sfxbnd_commoneffects, sfxbnd_m15 and sfxbnd_m25 files match game originals, as in recovery 0.1.2. Particle removal was reverted and remains pending here. The user had not yet confirmed grab recovery.

Total: 27 files, including 24 model/scenery packages and three original effect packages. Files outside the five edited scenery packages remain byte-identical to 0.1.2.

## Next tests

- [ ] Static floor centipedes absent nearby, at a distance and after reload.
- [ ] Floor and wood intact.
- [ ] Repeat grab to assess crash recovery.
- [ ] Other encounters, including True Monk, and Long-arm preservation.

m13_00_00_00_001200 remains deferred at this stage. The worm_02 layer in 502001 was not removed here. The smiley replacement variant is future work.
'@
Set-Content "$release\CHANGES-AND-TESTS.md" $changes -Encoding utf8
$lib=Join-Path $root 'tools_to_mod\FLVER_Editor_X2.6\Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $lib 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $lib 'SoulsFormats.dll')) | Out-Null
$manifest=foreach($f in Get-ChildItem "$release\mods" -Recurse -File | Sort-Object FullName){
 $b=[SoulsFormats.BND4]::Read($f.FullName)
 [pscustomobject]@{File=[IO.Path]::GetRelativePath($release,$f.FullName).Replace('\','/');Bytes=$f.Length;SHA256=(Get-FileHash $f.FullName).Hash;Compression=$b.Compression.ToString();Models=@($b.Files | Where-Object Name -Match '\.flver$').Count}
}
if($manifest.Count -ne 27){throw 'Wrong package count'}
foreach($row in Import-Csv "$old\FILES-SHA256.csv"){
 if($row.File -notmatch '/m20_00_00_00_' -and (Get-FileHash (Join-Path $release $row.File)).Hash -ne $row.SHA256){throw 'Unrelated package changed'}
}
$manifest | Export-Csv "$release\FILES-SHA256.csv" -NoTypeInformation -Encoding utf8
$zip=$release+'.zip'
[IO.Compression.ZipFile]::CreateFromDirectory($release,$zip)
$archive=[IO.Compression.ZipFile]::OpenRead($zip)
try{
 foreach($e in $archive.Entries){$s=$e.Open();try{$h=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($s))}finally{$s.Dispose()};if($h -ne (Get-FileHash (Join-Path $release $e.FullName)).Hash){throw 'ZIP mismatch'}}
}finally{$archive.Dispose()}
$hash=(Get-FileHash $zip).Hash
Set-Content ($zip+'.sha256') "$hash  $([IO.Path]::GetFileName($zip))" -Encoding ascii
[pscustomobject]@{Version='0.1.3';Packages=27;ZipSHA256=$hash;ZipAllHashesMatch=$true;StaticFloorGameTested=$false;AnimatedFloorUserValidated=$true} | ConvertTo-Json | Set-Content work\alpha-013-release-validation.json
Get-Content work\alpha-013-release-validation.json
