$ErrorActionPreference = 'Stop'
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$game = 'C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$lib = Join-Path $root 'tools_to_mod\FLVER_Editor_X2.6\Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $lib 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $lib 'SoulsFormats.dll')) | Out-Null
$version = (Get-Content (Join-Path $root 'VERSION') -Raw).Trim()
$release = Join-Path $root ("releases\Nicky-Allowed-Invisible-Centipedes-alpha-" + $version)
$records = @()
foreach ($id in @('c1012','c1013','c5001')) {
    foreach ($location in @('Original','Release','Installed')) {
        $path = switch ($location) {
            'Original' { Join-Path $game "chr\$id.chrbnd.dcx" }
            'Release' { Join-Path $release "mods\chr\$id.chrbnd.dcx" }
            'Installed' { Join-Path $game "mods\chr\$id.chrbnd.dcx" }
        }
        if (-not (Test-Path -LiteralPath $path)) { continue }
        $binder = [SoulsFormats.BND4]::Read($path)
        foreach ($entry in $binder.Files | Where-Object Name -Match '\.flver$') {
            $model = [SoulsFormats.FLVER2]::Read([byte[]]$entry.Bytes)
            $meshes = @(for ($i=0; $i -lt $model.Meshes.Count; $i++) {
                $mesh = $model.Meshes[$i]
                $counts = @($mesh.FaceSets | ForEach-Object { [Collections.Generic.HashSet[int]]::new($_.Indices).Count })
                $material = $model.Materials[$mesh.MaterialIndex]
                [pscustomobject]@{Index=$i;Material=$material.Name;MTD=$material.MTD;UniqueIndicesPerFaceSet=$counts;AllFaceSetsDegenerate=(@($counts | Where-Object { $_ -ge 3 }).Count -eq 0)}
            })
            $records += [pscustomobject]@{Id=$id;Location=$location;Path=$path;SHA256=(Get-FileHash $path).Hash;Meshes=$meshes;ParasiteBoneNames=@($model.Nodes.Name | Where-Object {$_ -match 'worm|centipede|mukade'})}
        }
    }
}
$map = [SoulsFormats.MSBS]::Read((Join-Path $game 'map\MapStudio\m11_00_00_00.msb.dcx'))
$placements = @($map.Parts.Enemies | Where-Object ModelName -in @('c1012','c1013') | Select-Object Name,ModelName,EntityID,NPCParamID,Position)
$events = [SoulsFormats.EMEVD]::Read((Join-Path $game 'event\m11_00_00_00.emevd.dcx'))
$references = @(foreach ($event in $events.Events) {
    for ($i=0; $i -lt $event.Instructions.Count; $i++) {
        $instruction=$event.Instructions[$i]
        $args=[byte[]]$instruction.ArgData
        $matches=@(for ($offset=0; $offset -le $args.Length-4; $offset++) {
            $value=[BitConverter]::ToInt32($args,$offset)
            if ($value -in @(1100270,1100706)) { [pscustomobject]@{Offset=$offset;Entity=$value} }
        })
        if ($matches.Count) { [pscustomobject]@{Event=$event.ID;Instruction=$i;Bank=$instruction.Bank;ID=$instruction.ID;Matches=$matches;ArgHex=[Convert]::ToHexString($args)} }
    }
})
$report = [pscustomobject]@{Date=(Get-Date -Format o);Version=$version;Models=$records;FreshMapPlacements=$placements;EventReferences=$references}
$report | ConvertTo-Json -Depth 12 | Set-Content (Join-Path $PSScriptRoot 'hanbei-audit.json') -Encoding utf8
$records | Select-Object Id,Location,@{n='Meshes';e={$_.Meshes.Count}},@{n='AllHidden';e={@($_.Meshes | Where-Object { -not $_.AllFaceSetsDegenerate }).Count -eq 0}},@{n='ParasiteBones';e={$_.ParasiteBoneNames.Count}} | Format-Table -AutoSize
$placements | Format-Table -AutoSize
$references | Select-Object Event,Instruction,Bank,ID,ArgHex | Format-Table -AutoSize
