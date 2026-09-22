$ErrorActionPreference='Stop'
$root=(Get-Location).Path
$old=Join-Path $root 'releases\Nicky-Allowed-Invisible-alpha-0.1.5'
$release=Join-Path $root 'releases\Nicky-Allowed-Invisible-Centipedes-alpha-0.1.6'
$v=Get-Content work\senpou-502001-final\validation.json -Raw | ConvertFrom-Json
if($v.Result -ne 'PASS'){throw 'Validation failed'}
if(Test-Path $release){throw 'Release exists'}
Copy-Item -LiteralPath $old -Destination $release -Recurse
$relative='mods/map/m20_00_00_00/m20_00_00_00_502001.mapbnd.dcx'
$source=Join-Path $root 'dist\senpou-502001-final\mods\map\m20_00_00_00\m20_00_00_00_502001.mapbnd.dcx'
if((Get-FileHash $source).Hash -ne $v.SHA256){throw 'Source hash mismatch'}
Copy-Item -LiteralPath $source -Destination (Join-Path $release $relative) -Force
$readme=@'
# Nicky Allowed — Invisible Centipedes — alpha 0.1.6

A visual accessibility mod for Sekiro: Shadows Die Twice on PC, made for a friend who is afraid of centipedes. This complete release hides selected models and scenery layers and replaces identified centipede particles with splash rendering from the game.

**Long-arm Centipede and its C1030/C1040 variants are intentionally preserved.** Some worm and other insect layers were also removed by explicit request. This alpha does not guarantee that every centipede appearance has been covered.

## Installation and upgrading

1. Close Sekiro completely.
2. Back up your existing mod folder and `modengine.ini`, if present.
3. Install [Sekiro Mod Engine](https://www.nexusmods.com/sekiro/mods/6) if needed, following its author's instructions. The loader is not included in this ZIP. Its files belong beside `sekiro.exe`.
4. Check these options in the `[files]` section of `modengine.ini`:

   ```ini
   loadUXMFiles=0
   useModOverrideDirectory=1
   modOverrideDirectory="\mods"
   ```

5. Extract this ZIP, then copy its entire `mods` folder into the game directory, beside `sekiro.exe`. Replace this mod's older files when upgrading. Do not create `mods/mods`.
6. If Mod Engine uses a different override directory, copy the contents of `mods` into that directory instead.
7. Launch Sekiro normally through Steam. You do not need Yabber, FLVER Editor or DSMapStudio to play with the mod. Restart the game after changing mod files.

Expected folder layout:

```text
Sekiro/
  sekiro.exe
  dinput8.dll
  modengine.ini
  mods/
    chr/
    obj/
    map/
    sfx/
```

Alpha 0.1.6 is a complete package; no earlier release is required. Other mods that replace the same files need a compatible merge. Copying one mod over another does not combine their changes.

## What is included

- 28 mod packages: six character packages, five object packages, fourteen scenery packages and three effect packages.
- `CHANGES-AND-TESTS.md`: coverage, changes and test status.
- `FILES-SHA256.csv`: relative paths, sizes, SHA-256 checksums, compression and model counts for the 28 mod packages.

## Latest changes

- Worm layers on the Dungeon bodies in `m13_00_00_00_001200` are hidden while the bodies, clothing and hair are preserved.
- The additional individual insect/worm layer in Senpou scenery `m20_00_00_00_502001` and its distance variant is hidden. Wood and the previously completed changes are preserved.
- Earlier animated/static floor corrections and the centipede-to-splash particle substitution remain included.
- Objects `o116050` and `o116051` remain unchanged: the user inspected them and found no centipedes. Their generic material name `Material #337` refers to charcoal textures.

## Credits

Tools used: FLVER Editor, SoulsFormats, Yabber and DSMapStudio. Loading through Sekiro Mod Engine by Katalash. Original game assets belong to their respective rights holders. This is an unofficial fan project.

Distribute the complete ZIP so that the instructions and limitations accompany the mod.
'@
Set-Content "$release\README.md" $readme -Encoding utf8
$history=Get-Content "$old\CHANGES-AND-TESTS.md" -Raw
$changes=@'
# Current state — alpha 0.1.6

Compared with 0.1.5, only m20…502001 changes: main mesh 2 and _S mesh 0, both associated with m20_worm_02, are hidden. Remaining parsed data were compared and preserved. Wood stays intact; main mesh 3/_S mesh 1 remain hidden as before.

The other 27 files remain byte-identical to 0.1.5, including new m13…001200 and all earlier floor/particle fixes. Old editor copies did not overwrite previous corrections.

The user confirmed no centipedes in o116050/o116051; they remain outside the mod. Generic #337/#341 labels are not automatic removal criteria.

Both post-0.1.4 additions still need in-game tests. The user validated the floor and particle substitution only in the observed encounter.

## Earlier coverage history
'@+"`n"+$history
Set-Content "$release\CHANGES-AND-TESTS.md" $changes -Encoding utf8
$manifest=@(Import-Csv "$old\FILES-SHA256.csv")
foreach($r in $manifest){
 $p=Join-Path $release $r.File;$hash=(Get-FileHash $p).Hash
 if($r.File -ne $relative -and $hash -ne $r.SHA256){throw 'Unrelated package changed'}
 $r.SHA256=$hash;$r.Bytes=(Get-Item $p).Length
}
if($manifest.Count -ne 28){throw 'Wrong package count'}
$manifest | Export-Csv "$release\FILES-SHA256.csv" -NoTypeInformation -Encoding utf8
$zip=$release+'.zip'
[IO.Compression.ZipFile]::CreateFromDirectory($release,$zip)
$archive=[IO.Compression.ZipFile]::OpenRead($zip)
try{
 foreach($e in $archive.Entries){$s=$e.Open();try{$h=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($s))}finally{$s.Dispose()};if($h -ne (Get-FileHash (Join-Path $release $e.FullName)).Hash){throw 'ZIP mismatch'}}
 if($archive.Entries.Count -ne @(Get-ChildItem $release -File -Recurse).Count){throw 'ZIP file count mismatch'}
}finally{$archive.Dispose()}
$hash=(Get-FileHash $zip).Hash
Set-Content ($zip+'.sha256') "$hash  $([IO.Path]::GetFileName($zip))" -Encoding ascii
[pscustomobject]@{Version='0.1.6';Packages=28;UnchangedFrom015=27;ZipAllHashesMatch=$true;ZipSHA256=$hash;Installed=$false;NewEditsGameTested=$false} | ConvertTo-Json | Set-Content work\alpha-016-release-validation.json
Get-Content work\alpha-016-release-validation.json
