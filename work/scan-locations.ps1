$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$gameRoot = 'C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$outDir = Join-Path $PSScriptRoot 'creature-inventory'
$null=[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $projectRoot 'tools_to_mod\FLVER_Editor_X2.6\Debug\oo2core_6_win64.dll'))
$null=[Reflection.Assembly]::LoadFrom((Join-Path $projectRoot 'tools_to_mod\FLVER_Editor_X2.6\Debug\SoulsFormats.dll'))
$mapNames=@{}
foreach($entry in (Get-Content -LiteralPath (Join-Path $projectRoot 'tools_to_mod\DSMapStudio-1.11.1.hotfix3\Assets\Aliases\Maps\SDT\Maps.json') -Raw | ConvertFrom-Json).list){$mapNames[$entry.id]=$entry.name}
$placements=[Collections.Generic.List[object]]::new()
$sceneRefs=[Collections.Generic.List[object]]::new()
$scanErrors=[Collections.Generic.List[object]]::new()
$mapCount=0
foreach($mapFile in Get-ChildItem -LiteralPath (Join-Path $gameRoot 'map\MapStudio') -Filter '*.msb.dcx'){
    try {
        $map=[SoulsFormats.MSBS]::Read($mapFile.FullName)
        $mapId=$mapFile.Name.Split('.')[0]
        foreach($group in @('Enemies','DummyEnemies','Objects','DummyObjects','MapPieces')){
            foreach($part in $map.Parts.$group){
                $placements.Add([pscustomobject]@{Map=$mapId;Region=$mapNames[$mapId];Type=$group;Model=$part.ModelName;Part=$part.Name;EntityID=$part.EntityID;NPCParamID=$part.NPCParamID;Position=$part.Position.ToString()})
            }
        }
        $mapCount++
    } catch {$scanErrors.Add([pscustomobject]@{Path=$mapFile.FullName;Error=$_.Exception.Message})}
}
$sceneCount=0
foreach($sceneFile in Get-ChildItem -LiteralPath (Join-Path $gameRoot 'cutscene') -Filter '*.cutscenebnd.dcx'){
    try {
        $binder=[SoulsFormats.BND4]::Read($sceneFile.FullName)
        foreach($entry in $binder.Files | Where-Object {$_.Name -match '\.mqb$'}){
            $scene=[SoulsFormats.MQB]::Read([byte[]]$entry.Bytes)
            foreach($resource in $scene.Resources){
                $sceneRefs.Add([pscustomobject]@{Scene=$sceneFile.Name;Resource=$resource.Name;Path=$resource.Path;Parent=$resource.ParentIndex})
            }
        }
        $sceneCount++
    } catch {$scanErrors.Add([pscustomobject]@{Path=$sceneFile.FullName;Error=$_.Exception.Message})}
}
$placements.ToArray() | Export-Csv -LiteralPath (Join-Path $outDir 'map-placements.csv') -NoTypeInformation -Encoding utf8
$sceneRefs.ToArray() | Export-Csv -LiteralPath (Join-Path $outDir 'cutscene-resources.csv') -NoTypeInformation -Encoding utf8
Set-Content -LiteralPath (Join-Path $outDir 'location-errors.json') -Value (ConvertTo-Json -InputObject @($scanErrors.ToArray()) -Depth 4) -Encoding utf8
[pscustomobject]@{Maps=$mapCount;Placements=$placements.Count;CutsceneArchives=$sceneCount;SceneResources=$sceneRefs.Count;Errors=$scanErrors.Count} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $outDir 'location-summary.json') -Encoding utf8
Get-Content -LiteralPath (Join-Path $outDir 'location-summary.json')
