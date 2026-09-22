$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$outDir=Join-Path $root 'reports'
$null=New-Item -ItemType Directory -Path $outDir -Force
$pattern='(?i)worm|centipede|millipede|mukade|parasite|infest|cricket|spider|scorpion|insect|beetle|cockroach|caterpillar|butterfly|maggot|larva|mushi|gokiburi|mosquito|dragonfly|leech|(?:^|[_\s])(?:ant|moth|fly|flea|tick)(?:[_\s.]|$)|ムカデ|百足|寄生|蟲|コオロギ|蜘蛛|毛虫|幼虫|ムシ|虫|蛆|蝿|蠅|蝶|蚊|蟻|ゴキブリ|ゲジ'
$rows=[Collections.Generic.List[object]]::new()
$placements=Import-Csv (Join-Path $PSScriptRoot 'creature-inventory\map-placements.csv')
$sceneRefs=Import-Csv (Join-Path $PSScriptRoot 'creature-inventory\cutscene-resources.csv')
$regionNames=@{m10_00_00_00='Hirata';m11_00_00_00='Ashina Outskirts';m11_01_00_00='Ashina Castle';m11_02_00_00='Ashina Reservoir';m13_00_00_00='Abandoned Dungeon';m15_00_00_00='Mibu Village';m17_00_00_00='Sunken Valley';m20_00_00_00='Senpou Temple';m25_00_00_00='Fountainhead Palace'}
foreach($scope in @('creature-inventory','map-model-inventory','effect-model-inventory')){
 $models=Get-Content -LiteralPath (Join-Path $PSScriptRoot "$scope\models.json") -Raw | ConvertFrom-Json
 foreach($model in $models){
  if($model.Status -ne 'ok'){continue}
  $evidence=@(@($model.Alias)+@($model.Bones)+@($model.Materials.Name)+@($model.Materials.MTD)+@($model.Materials.Textures) | Where-Object {$_ -match $pattern} | Select-Object -Unique)
  if($evidence.Count -eq 0){continue}
  $id=$model.Id
  $classification='Review name; not proof of a creature'
  if($id -in @('c1030','c1040')){$classification='PROTECTED — Long-arm family'}
  elseif($id -in @('c1013','c1200','c1210','c5000','c5001','c5100')){$classification='Parasite — strong evidence'}
  elseif($id -eq 'c1211'){$classification='Insect — cricket'}
  elseif($id -eq 'c5005'){$classification='Inherited bones; parasite surface unconfirmed'}
  elseif($id -eq 'c5090'){$classification='Lady Butterfly name; preserve character'}
  elseif(($evidence -join ' ') -match 'worm_body|worm_0[1-9]|Mukade|ムカデ|虫の大群|芋虫|虫アルファ|虫単体'){$classification='Scenery/object — likely worms or centipedes'}
  elseif(($evidence -join ' ') -match '(?i)insect_Basket'){$classification='Insect container — visual inspection pending'}
  elseif(($evidence -join ' ') -match '(?i)insect|moth_'){$classification='Scenery insects — visual inspection pending'}
  elseif(($evidence -join ' ') -match '(?i)spiderweb|蜘蛛の巣'){$classification='Webs — no confirmed spider'}
  elseif(($evidence -join ' ') -match '(?i)worm_eaten|虫食|ムシロ|karamushi|蝶番'){$classification='Likely false positive: erosion/vegetation/object'}
  $materialIndices=@(for($i=0;$i -lt $model.Materials.Count;$i++){
   $mat=$model.Materials[$i]
   if((@($mat.Name,$mat.MTD)+@($mat.Textures) -join ' ') -match $pattern){$i}
  })
  $meshes=@($model.Meshes | Where-Object {$_.MaterialIndex -in $materialIndices} | Select-Object -ExpandProperty Index)
  $regions=@($placements | Where-Object {$_.Model -eq $id} | Select-Object -ExpandProperty Region -Unique)
  if($scope -eq 'map-model-inventory'){$mapId=($id -split '_')[0..3] -join '_';$regions=@($regionNames[$mapId])}
  $scenes=@($sceneRefs | Where-Object {$_.Resource -match ('^'+[regex]::Escape($id)+'(?:_|$)')} | Select-Object -ExpandProperty Scene -Unique)
  $rows.Add([pscustomobject]@{Id=$id;Alias=$model.Alias;Classification=$classification;Regions=($regions -join '; ');Archive=$model.Archive;Model=$model.Model;MaterialMeshes=($meshes -join ', ');Scenes=($scenes -join '; ');Evidence=($evidence -join ' | ')})
 }
}
$rows.ToArray() | Export-Csv -LiteralPath (Join-Path $outDir 'full-inventory.csv') -NoTypeInformation -Encoding utf8
$lines=[Collections.Generic.List[string]]::new()
$intro=@'
# Centipede, parasite and insect inventory

**Scan completed September 19, 2026. This inventories local file references; it does not guarantee that every visual appearance has been identified or removed.** The scan itself changed no game or installed mod package.

This is the initial candidate inventory. Its proposed interventions and classifications are historical, not the final removal list. See [the action plan](ACTION-PLAN.md) for current scope, preserved candidates and alpha 0.1.6 status. In particular, crickets and moths were subsequently excluded by the user.

## Scope and results

| Group | Packages read | FLVER models read | Final errors |
| --- | ---: | ---: | ---: |
| Characters, objects and parts | 1,658 | 4,114 | 0 |
| Scenery | 5,094 | 10,166 | 0 |
| Visual effects, internal FLVER models only | 8 | 144 | 0 |
| **Total** | **6,760** | **14,424** | **0** |

Also cross-referenced 10 maps, 53,396 part records (including objects and auxiliary parts, not just enemies), and 54 cutscene packages containing 4,658 resource references. Packages may contain repeated models, distance or destruction variants; these are not counts of different creatures.

The search inspected bones, materials, texture paths and English/Japanese aliases, including worm, centipede, mukade, parasite, infested, cricket, spider, insect, moth, millipede, larva, ムカデ and 虫. A second pass checked parasite-bone vertex weights in eight characters.

## Main candidates

Mesh indices are zero-based, as in FLVER Editor. These are inspection leads, not authorization to hide entire meshes. Some meshes combine unrelated elements and require visual identification.

| ID | Identity | Evidence | Initial investigation |
| --- | --- | --- | --- |
| `c5100` | Guardian Ape | WormRoot, WormHead, leg bones and Insectebody material; weighted vertices in meshes **32/33**. User confirmed the appearance. | Isolate the parasite while preserving the Ape; highest initial priority. |
| `c1013` | Alternate Hanbei | Worm/Leg bones and `c1013_centipede_Decal`; weights in mesh **0**. | Check the variant and associated sequence; hide only the parasite. |
| `c1200` | Infested monk with parasite | Mukade materials and hundreds of bone references; weighted meshes **1/3/5/12**, plus suspicious material in **0**. | Inspect separate parts, surfaces and animated materials. |
| `c1210` | Infested monk | GroundWorm and Mukade/Scroll/Cloth materials; weights in **1/14**, suspicious materials elsewhere. | Include centipedes represented by textures/materials. |
| `c5000` | Corrupted / True Monk | Worm bones and weighted geometry in mesh **25**. | Inspect the embedded parasite while preserving the Monk. |
| `c5001` | Immortal Centipede | Standalone centipede, visually inspected. | Existing prototype does not cover parasites embedded in other characters. |
| `c1211` | Cricket | Cricket alias and `c1200_cricket` bone; placements in Senpou and the Dungeon. | Initial broad many-legged candidate; subsequently preserved by user decision. |

**Protected exception:** `c1030` and `c1040`, the Centipede / Long-arm family. Similar names must not cause automatic removal.

### Avoiding incorrect removals

- `c5005`, Illusory Monk: 130 Worm skeleton references, but no positively weighted vertices on those bones and no parasite materials found. Likely a shared skeleton; do not hide the entire Monk.
- `c5090`, Lady Butterfly: matched only by name. This does not establish centipedes on the character. Her effects would require separate investigation if butterflies were in scope.

## Relevant scenery objects

| IDs | Evidence | Recorded location / notes |
| --- | --- | --- |
| `o205900`, `o205910` | Decorative monks with ムカデ materials and Mukade textures | Senpou; o205900 also referenced in cutscene `s20_00_0000`. |
| `o134290`, `o134390` | Containers/surfaces with `worm_body` and `worm_01` | Abandoned Dungeon; inspect intact/broken variants and every internal FLVER. |
| `o124290` | `worm_body`, `worm_01`, and 虫の大群 nodes (insect swarm) | Not located in searched map parts; possibly unused or activated by another mechanism. |
| `o157000`, `o157001`, `o157002` | `m15_moth_01` textures | Broad moth/insect candidates, not confirmed centipedes; later preserved. |
| `o253100`, `o253110` | `insect_Basket` textures | Fountainhead Palace; the name may describe the container. Inspect before editing. |

## Insects and worms embedded in map models

Editing `chr/` alone is insufficient: map packages also contain relevant materials.

| Area | Candidate prefix and suffixes | Evidence |
| --- | --- | --- |
| Dungeon | `m13_00_00_00_` + `000800`, `000810`, `001200`, `201300`, `206500`, `206510`, `206600` | worm_body/worm_01 textures; some models also contain rock and need selective edits. |
| Senpou | `m20_00_00_00_` + `450000`, `450001`, `450002`, `502001`, `502003` | Worm, Mukade_Scroll materials and insect names. |
| Fountainhead Palace | `m25_00_00_00_` + `000710`, `000711`, `000712`, `000750`, `311050` | insect textures; some materials named 芋虫_発光, consistent with glowing larvae/caterpillars. Visual identity initially pending. |

## Matches that do not establish a many-legged creature

- `spiderweb` and 蜘蛛の巣: webs in Hirata, Senpou, Ashina, the Valley and Palace, not evidence of living spiders. Objects o108100, o109910, o109920 and o109930 also contain webs.
- `worm_eaten_rock` and 虫食 describe erosion in rock/wood. Do not remove terrain based on those names.
- `karamushi`, ムシロ and 蝶番 occur in vegetation, mats and hardware: textual coincidences, not automatic targets.
- Parameter aliases such as “sandworm” or “spider thread” may be old/reused labels. They remain in raw evidence but were not treated as proof of an enemy present in the game.

## Limits

The 14,424 models were not all manually viewed. Generic names can escape the search, and not every texture was opened as an image. Effect-package FLVER models were parsed, but this initial scan did not reconstruct FXR particle logic, events or animations. The game's two BK2 videos were not watched. No keyword match does not prove no visible insects.

Locations below come from map references, not gameplay. Some parts may be disabled, belong to another phase or be activated by events. An appearance absent from the cutscene table may still occur in a finishing animation outside cutscene packages.

## Initial implementation order

1. Guardian Ape and the reported extraction sequence.
2. Hanbei, infested monks and True Monk, alongside C5001.
3. Visually inspect broad insect/object candidates; apply subsequent user exclusions for crickets and moths.
4. Selectively treat Senpou, Dungeon and Palace materials while preserving floors, walls and hosts.
5. Test appearances, finishers, transitions, shadows and Long-arm preservation; record untested coverage.

## Evidence

- `reports/full-inventory.csv`: one row per matching internal model, including archive, classification, regions, scenes, evidence and material-matched meshes.
- `work/creature-inventory/parasite-meshes.csv`: priority character weights/materials. Worm bone weights alone do not delimit the full parasite surface.
- `work/creature-inventory/models.json`, `work/map-model-inventory/models.json`, `work/effect-model-inventory/models.json`: metadata for every parsed model, including nonmatches.
- `work/creature-inventory/map-placements.csv` and `cutscene-resources.csv`: map/cutscene cross-references.
- `work/creature-inventory/parameter-references.txt`: parameter alias text, not a list of executed events.
- `work/scan-creatures.ps1`, `scan-locations.ps1`, `inspect-parasite-meshes.ps1`, `build-creature-report.ps1`: repeatable inspection scripts.

## Complete matching-package catalog

Includes candidates, protected exceptions and false positives. Full internal variants and evidence are retained in the CSV. “Material meshes” is the material-name filter, not the bone-weight analysis. Raw asset identifiers remain in their source language.

| ID | Name/alias | Classification | Recorded region | Matching models | Material meshes |
| --- | --- | --- | --- | ---: | --- |
'@
$lines.Add($intro)
foreach($group in $rows | Group-Object Id | Sort-Object Name){
 $first=$group.Group[0]
 $classes=(@($group.Group.Classification | Select-Object -Unique) -join '; ')
 $regions=(@($group.Group.Regions | Where-Object {$_} | Select-Object -Unique) -join '; ')
 if(-not $regions){$regions='Not located'}
 $meshList=(@($group.Group.MaterialMeshes | Where-Object {$_} | Select-Object -Unique) -join '; ')
 $lines.Add(('| `{0}` | {1} | {2} | {3} | {4} | {5} |' -f $group.Name,$first.Alias,$classes,$regions,$group.Count,$meshList))
}
$lines.Add('')
$lines.Add(('Total matching rows: **{0}**; distinct matching packages: **{1}**. These totals include false positives and variants; they are not counts of distinct creatures.' -f $rows.Count,@($rows | Group-Object Archive).Count))
Set-Content -LiteralPath (Join-Path $outDir 'CENTIPEDE-INVENTORY.md') -Value $lines -Encoding utf8
$rows | Group-Object Classification | Select-Object Count,Name | Format-Table -AutoSize
'Report: '+(Join-Path $outDir 'CENTIPEDE-INVENTORY.md')
