$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$lib=Join-Path $root 'tools_to_mod\FLVER_Editor_X2.6\Debug\SoulsFormats.dll'
$null=[Runtime.InteropServices.NativeLibrary]::Load((Join-Path (Split-Path $lib) 'oo2core_6_win64.dll'))
$null=[Reflection.Assembly]::LoadFrom($lib)
Add-Type -ReferencedAssemblies @($lib, (Join-Path $PSHOME 'ref\mscorlib.dll'), (Join-Path $PSHOME 'ref\System.Collections.dll'), (Join-Path $PSHOME 'ref\System.Runtime.dll')) -TypeDefinition @'
using System;
using SoulsFormats;
public static class ParasiteMeshAudit {
 public static int[,] Count(FLVER2 model) {
  bool[] targets=new bool[model.Nodes.Count];
  for(int i=0;i<targets.Length;i++) {
   string name=model.Nodes[i].Name.ToLowerInvariant();
   targets[i]=name.Contains("worm")||name.Contains("mukade")||name.Contains("centipede");
  }
  int[,] result=new int[model.Meshes.Count,3];
  for(int m=0;m<model.Meshes.Count;m++) {
   var mesh=model.Meshes[m];
   foreach(var vertex in mesh.Vertices) {
    bool parasite=false,other=false;
    if(mesh.UseBoneWeights) {
     for(int j=0;j<4;j++) {
      if(vertex.BoneWeights[j]<=0)continue;
      int index=vertex.BoneIndices[j];
      if(index>=0&&index<targets.Length&&targets[index])parasite=true;else other=true;
     }
    }
    if(parasite)result[m,0]++;
    if(other)result[m,1]++;
    if(parasite&&other)result[m,2]++;
   }
  }
  return result;
 }
}
'@
$records=[Collections.Generic.List[object]]::new()
foreach($id in @('c1013','c1200','c1210','c1211','c5000','c5001','c5005','c5100')) {
 $binder=[SoulsFormats.BND4]::Read("C:\Program Files (x86)\Steam\steamapps\common\Sekiro\chr\$id.chrbnd.dcx")
 foreach($entry in $binder.Files | Where-Object {$_.Name -match '\.flver$'}){
  $model=[SoulsFormats.FLVER2]::Read([byte[]]$entry.Bytes)
  $counts=[ParasiteMeshAudit]::Count($model)
  for($i=0;$i -lt $model.Meshes.Count;$i++){
   $mesh=$model.Meshes[$i];$material=$model.Materials[$mesh.MaterialIndex]
   $records.Add([pscustomobject]@{Id=$id;Mesh=$i;Vertices=$mesh.Vertices.Count;ParasiteWeighted=$counts[$i,0];OtherWeighted=$counts[$i,1];MixedWeighted=$counts[$i,2];UseBoneWeights=$mesh.UseBoneWeights;MaterialIndex=$mesh.MaterialIndex;Material=$material.Name;MTD=$material.MTD;Textures=(@($material.Textures | ForEach-Object {$_.Path}) -join ' | ')})
  }
 }
}
$records.ToArray() | Export-Csv -LiteralPath (Join-Path $PSScriptRoot 'creature-inventory\parasite-meshes.csv') -NoTypeInformation -Encoding utf8
$records | Where-Object {$_.ParasiteWeighted -gt 0 -or $_.MTD -match 'Mukade|centipede|insect'} | Select-Object Id,Mesh,Vertices,ParasiteWeighted,OtherWeighted,MixedWeighted,Material | Format-Table -AutoSize
