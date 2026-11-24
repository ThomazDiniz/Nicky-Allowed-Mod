$ErrorActionPreference='Stop'
$lib=Join-Path (Get-Location) 'tools_to_mod/FLVER_Editor_X2.6/Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $lib 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $lib 'SoulsFormats.dll')) | Out-Null
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$targets=@{c1013=@(0);c5001=@(0,1,2,3);c5000=@(25);c5100=@(32,33);c1200=@(0,1,5,12);c1210=@(3,4,10,11,14,21,22,23,24)}
$rows=foreach($id in $targets.Keys | Sort-Object){
 $b=[SoulsFormats.BND4]::Read("$game/chr/$id.chrbnd.dcx")
 foreach($e in $b.Files | Where-Object Name -Match '\.flver$'){
 $m=[SoulsFormats.FLVER2]::Read([byte[]]$e.Bytes)
 $meshes=foreach($i in $targets[$id]){
 $mesh=$m.Meshes[$i];$mat=$m.Materials[$mesh.MaterialIndex]
 [pscustomobject]@{Index=$i;Vertices=$mesh.Vertices.Count;FaceSets=$mesh.FaceSets.Count;Material=$mat.Name;MTD=$mat.MTD;BonePalette=@($mesh.BoneIndices);Textures=@($mat.Textures | Select-Object Type,Path)}
 }
 [pscustomobject]@{Id=$id;TotalMeshes=$m.Meshes.Count;TotalBones=$m.Nodes.Count;SelectedMeshes=$meshes;Bones=@(for($i=0;$i -lt $m.Nodes.Count;$i++){[pscustomobject]@{Index=$i;Name=$m.Nodes[$i].Name;Parent=$m.Nodes[$i].ParentIndex}})}
 }
}
$rows | ConvertTo-Json -Depth 10 | Set-Content work/replacement-analysis/models.json
foreach($r in $rows){"$($r.Id): $($r.TotalMeshes) meshes, $($r.TotalBones) bones";$r.SelectedMeshes | Select-Object Index,Vertices,Material | Format-Table; $r.Bones | Where-Object Name -Match 'worm|mukade|centipede' | Select-Object -First 9 | Format-Table}
