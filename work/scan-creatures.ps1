param(
    [string]$GameRoot = 'C:\Program Files (x86)\Steam\steamapps\common\Sekiro',
    [switch]$MapModels,
    [switch]$Effects
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3
$projectRoot = Split-Path $PSScriptRoot -Parent
$outDir = Join-Path $PSScriptRoot 'creature-inventory'
if ($MapModels) { $outDir = Join-Path $PSScriptRoot 'map-model-inventory' }
if ($Effects) { $outDir = Join-Path $PSScriptRoot 'effect-model-inventory' }
$null = New-Item -ItemType Directory -Path $outDir -Force
$null = [Runtime.InteropServices.NativeLibrary]::Load((Join-Path $projectRoot 'tools_to_mod\FLVER_Editor_X2.6\Debug\oo2core_6_win64.dll'))
$null = [Reflection.Assembly]::LoadFrom((Join-Path $projectRoot 'tools_to_mod\FLVER_Editor_X2.6\Debug\SoulsFormats.dll'))
$aliasDir = Join-Path $projectRoot 'tools_to_mod\DSMapStudio-1.11.1.hotfix3\Assets\Aliases\Models\SDT'
$aliases = @{}
foreach ($aliasFile in Get-ChildItem -LiteralPath $aliasDir -Filter '*.json') {
    $aliasData = Get-Content -LiteralPath $aliasFile.FullName -Raw | ConvertFrom-Json
    foreach ($entry in $aliasData.list) { $aliases[$entry.id] = $entry.name }
}
$pattern = '(?i)worm|centipede|millipede|mukade|parasite|infest|cricket|spider|scorpion|insect|beetle|cockroach|caterpillar|butterfly|maggot|larva|ムカデ|百足|寄生|蟲|コオロギ|蜘蛛|毛虫|幼虫'
$records = [Collections.Generic.List[object]]::new()
$errors = [Collections.Generic.List[object]]::new()
$files = @(foreach ($folder in @('chr','obj','parts')) {
    Get-ChildItem -LiteralPath (Join-Path $GameRoot $folder) -File | Where-Object { $_.Name -match '\.(chr|obj|part|parts)bnd\.dcx$' }
})
if ($MapModels) { $files = @(Get-ChildItem -LiteralPath (Join-Path $GameRoot 'map') -Recurse -Filter '*.mapbnd.dcx' -File) }
if ($Effects) { $files = @(Get-ChildItem -LiteralPath (Join-Path $GameRoot 'sfx') -Filter '*.ffxbnd.dcx' -File) }
$index = 0
foreach ($file in $files) {
    $index++
    $id = $file.Name.Split('.')[0]
    $alias = if ($aliases.ContainsKey($id)) { $aliases[$id] } else { '' }
    try {
        $binder = [SoulsFormats.BND4]::Read($file.FullName)
        $models = @($binder.Files | Where-Object { $_.Name -match '\.flver$' })
        if ($models.Count -eq 0) {
            $records.Add([pscustomobject]@{Id=$id;Alias=$alias;Archive=$file.FullName;Model='';Status='no-flver';Matches=@();Meshes=@();Bones=@()})
        }
        foreach ($modelFile in $models) {
            $model = [SoulsFormats.FLVER2]::Read([byte[]]$modelFile.Bytes)
            $hits = [Collections.Generic.List[object]]::new()
            if ($alias -match $pattern) { $hits.Add([pscustomobject]@{Kind='alias';Index=-1;Text=$alias}) }
            foreach ($innerFile in $binder.Files) { if ($innerFile.Name -match $pattern) { $hits.Add([pscustomobject]@{Kind='archive-entry';Index=$innerFile.ID;Text=$innerFile.Name}) } }
            for ($i=0; $i -lt $model.Nodes.Count; $i++) {
                if ($model.Nodes[$i].Name -match $pattern) { $hits.Add([pscustomobject]@{Kind='bone';Index=$i;Text=$model.Nodes[$i].Name}) }
            }
            for ($i=0; $i -lt $model.Materials.Count; $i++) {
                $material = $model.Materials[$i]
                foreach ($text in @($material.Name,$material.MTD)) {
                    if ($text -match $pattern) { $hits.Add([pscustomobject]@{Kind='material';Index=$i;Text=$text}) }
                }
                foreach ($texture in $material.Textures) {
                    if ($texture.Path -match $pattern) { $hits.Add([pscustomobject]@{Kind='texture';Index=$i;Text=$texture.Path}) }
                }
            }
            $meshSummary = @(for($i=0;$i -lt $model.Meshes.Count;$i++) {
                $mesh=$model.Meshes[$i]
                [pscustomobject]@{Index=$i;MaterialIndex=$mesh.MaterialIndex;MaterialName=$model.Materials[$mesh.MaterialIndex].Name;Vertices=$mesh.Vertices.Count;FaceSets=$mesh.FaceSets.Count;BoneIndices=@($mesh.BoneIndices);DefaultBoneIndex=$mesh.NodeIndex}
            })
            $records.Add([pscustomobject]@{
                Id=$id;Alias=$alias;Archive=$file.FullName;Model=$modelFile.Name;Status='ok';
                Matches=@($hits.ToArray());Meshes=$meshSummary;
                Bones=@($model.Nodes | ForEach-Object {$_.Name});
                Materials=@($model.Materials | ForEach-Object {[pscustomobject]@{Name=$_.Name;MTD=$_.MTD;Textures=@($_.Textures | ForEach-Object {$_.Path})}})
            })
        }
    } catch {
        $errors.Add([pscustomobject]@{Archive=$file.FullName;Error=$_.Exception.Message})
    }
    if ($index % 100 -eq 0) { Write-Output ('Scanned {0}/{1}; errors {2}' -f $index,$files.Count,$errors.Count); [GC]::Collect() }
}
$records.ToArray() | ConvertTo-Json -Depth 14 | Set-Content -LiteralPath (Join-Path $outDir 'models.json') -Encoding utf8
Set-Content -LiteralPath (Join-Path $outDir 'errors.json') -Value (ConvertTo-Json -InputObject @($errors.ToArray()) -Depth 5) -Encoding utf8
$candidateRows = @($records | Where-Object {$_.Matches.Count -gt 0} | ForEach-Object {
    [pscustomobject]@{Id=$_.Id;Alias=$_.Alias;Archive=$_.Archive;Model=$_.Model;MatchCount=$_.Matches.Count;Evidence=(($_.Matches | Select-Object -First 12 | ForEach-Object {$_.Kind+': '+$_.Text}) -join ' | ')}
})
$candidateRows | Export-Csv -LiteralPath (Join-Path $outDir 'candidates.csv') -NoTypeInformation -Encoding utf8
[pscustomobject]@{ScannedAt=(Get-Date).ToString('o');Archives=$files.Count;ParsedModels=@($records | Where-Object {$_.Status -eq 'ok'}).Count;NoFlver=@($records | Where-Object {$_.Status -eq 'no-flver'}).Count;Errors=$errors.Count;Candidates=$candidateRows.Count;Pattern=$pattern;Scope=$(if($MapModels){'Recursive map/*.mapbnd.dcx; FLVER metadata only'}elseif($Effects){'sfx/*.ffxbnd.dcx; FLVER metadata only'}else{'Top-level chr/*.chrbnd.dcx, obj/*.objbnd.dcx, parts/*part(s)bnd.dcx; FLVER metadata only'})} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $outDir 'summary.json') -Encoding utf8
$candidateRows | Select-Object Id,Alias,MatchCount | Format-Table -AutoSize
Get-Content -LiteralPath (Join-Path $outDir 'summary.json')
