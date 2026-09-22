$ErrorActionPreference='Stop'
$workspace=(Get-Location).Path
$old=Join-Path $workspace 'releases\Nicky-Allowed-Invisible-alpha-0.1.0'
$release=Join-Path $workspace 'releases\Nicky-Allowed-Invisible-alpha-0.1.1'
if(Test-Path $release){throw 'Release already exists'}
$floor=@(Get-Content work\verify-senpou-hotfix\validation.json -Raw | ConvertFrom-Json)
$fx=@(Get-Content work\senpou-effects\fx-hotfix-validation.json -Raw | ConvertFrom-Json)
if($floor.Count -ne 4 -or $fx.Count -ne 3 -or @(@($floor)+@($fx) | Where-Object Result -ne PASS).Count){throw 'Missing validations'}
Copy-Item -LiteralPath $old -Destination $release -Recurse
Copy-Item -Path dist\senpou-centipede-hotfix\mods\* -Destination "$release\mods" -Recurse -Force
$readme=(Get-Content "$old\README.md" -Raw).Replace('0.1.0','0.1.1').Replace('19 mod files (6 characters, 5 objects and 8 scenery packages)','26 mod files (6 characters, 5 objects, 12 scenery and 3 effect packages)').Replace('the 19 installed files','the 26 installed files').Replace('Sekiro\mods\chr, Sekiro\mods\obj and Sekiro\mods\map','Sekiro\mods\chr, Sekiro\mods\obj, Sekiro\mods\map and Sekiro\mods\sfx')
$notice=@'
## Changes in alpha 0.1.1

Includes all of 0.1.0 and adds animated Senpou floor layers and particles using the centipede atlas s04093. These references occur in monk effects and Monk variants, but the exact association with the photographed grab still requires gameplay confirmation.

New files passed parsing/data comparisons, not gameplay tests. Other floor surfaces and effect components were preserved. Animations, parameters, collisions and combat events were unchanged. Long-arm Centipede/C1030/C1040 remain preserved.

Upgrade by copying the full mods folder with the game closed. This adds mods/sfx; overlapping effect mods require a compatible merge.

Historical warning added later: this attempt was followed by a grab crash and was reverted. Do not distribute or install 0.1.1; use the current release.
'@
$readme=$readme.Replace('## Installation',($notice+"`n## Installation"))
$readme=$readme.Replace('Start with the Ape, Hanbei, infested monks and True Monk.','Prioritize the photographed Senpou floor and monk grab. Check other monk attacks and True Monk effects, then the Ape and Hanbei.')
Set-Content "$release\README.md" $readme -Encoding utf8
$changes=(Get-Content "$old\CHANGES-AND-TESTS.md" -Raw).Replace('alpha 0.1.0','alpha 0.1.1')
$changes=$changes.Replace('- All 19 final BND4 packages and their internal FLVER models were read successfully.','- The previous 19 packages remain byte-identical. Four new scenery and three effect packages reopened and passed checks; only the selected meshes and particles changed.')
$start=$changes.IndexOf('## Six models deferred for follow-up')
$end=$changes.IndexOf('## Known limitations',$start)
$changes=$changes.Substring(0,$start)+@'
## Additional Senpou and effect changes

| Package | Change |
| --- | --- |
| m20_00_00_00_450000 | Hide main meshes 2/3, Mukade_Scroll and Mukade_Scroll2. |
| m20_00_00_00_450001 | Hide equivalent meshes 3/4. |
| m20_00_00_00_450002 | Hide equivalent meshes 3/4. |
| m20_00_00_00_502003 | Hide equivalent meshes 2/3. |
| sfxbnd_commoneffects | Remove s04093 components from FXR 612010, 612100 and 612101. |
| sfxbnd_m15 and sfxbnd_m25 | Remove equivalents from FXR 650010, 650011 and 650012 in each. |

Removed 15 particle components in nine FXR files across three binders. The s04093 atlas was visually confirmed as animated centipedes. Only referencing components were removed; remaining parsed data were compared and other entries stayed identical. Original compression was retained. This method was subsequently reverted after a reported crash; structural validation was insufficient.

Other scenery meshes, _S variants and worm-named layers were unchanged. Matching pieces to the screenshot requires gameplay testing.

## Models still deferred

m13_00_00_00_001200 and m20_00_00_00_502001 remain unchanged in this historical version. Empty editor views do not establish absence of centipedes. Four of the six deferred models were treated; gameplay tests were still pending.

## Priority tests at the time

- [ ] Senpou floor nearby, at a distance and after reloading.
- [ ] Photographed monk grab and red particle shapes.
- [ ] Other monk attacks and normal combat behavior.
- [ ] True Monk parasite, transitions, attacks and finishing sequence.
- [ ] Long-arm Centipede appearance and behavior preserved.
'@+"`n"+$changes.Substring($end)
Set-Content "$release\CHANGES-AND-TESTS.md" $changes -Encoding utf8
$base=Join-Path $workspace 'tools_to_mod\FLVER_Editor_X2.6\Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $base 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $base 'SoulsFormats.dll')) | Out-Null
$manifest=foreach($file in Get-ChildItem "$release\mods" -File -Recurse | Sort-Object FullName){
 $b=[SoulsFormats.BND4]::Read($file.FullName)
 [pscustomobject]@{File=[IO.Path]::GetRelativePath($release,$file.FullName).Replace('\','/');Bytes=$file.Length;SHA256=(Get-FileHash $file.FullName).Hash;Compression=$b.Compression.ToString();Models=@($b.Files | Where-Object Name -Match '\.flver$').Count}
}
if($manifest.Count -ne 26){throw 'Package count mismatch'}
foreach($row in Import-Csv "$old\FILES-SHA256.csv"){
 if((Get-FileHash (Join-Path $release $row.File)).Hash -ne $row.SHA256){throw 'Alpha 0.1.0 payload changed'}
}
$manifest | Export-Csv "$release\FILES-SHA256.csv" -NoTypeInformation -Encoding utf8
$zip=$release+'.zip'
[IO.Compression.ZipFile]::CreateFromDirectory($release,$zip)
$archive=[IO.Compression.ZipFile]::OpenRead($zip)
try{
 foreach($entry in $archive.Entries){
  $local=Join-Path $release $entry.FullName
  $stream=$entry.Open()
  try{$hash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($stream))}finally{$stream.Dispose()}
  if($hash -ne (Get-FileHash $local).Hash){throw 'ZIP hash mismatch'}
 }
 if($archive.Entries.Count -ne @(Get-ChildItem $release -Recurse -File).Count){throw 'ZIP file count mismatch'}
}finally{$archive.Dispose()}
$zipHash=(Get-FileHash $zip).Hash
Set-Content ($zip+'.sha256') "$zipHash  $([IO.Path]::GetFileName($zip))" -Encoding ascii
[pscustomobject]@{Release=$release;Zip=$zip;SHA256=$zipHash;Packages=26;BasePayloadUnchanged=$true;ZipAllHashesMatch=$true;GameTested=$false;Date=(Get-Date -Format o)} | ConvertTo-Json | Set-Content work\alpha-011-release-validation.json
Get-Content work\alpha-011-release-validation.json
