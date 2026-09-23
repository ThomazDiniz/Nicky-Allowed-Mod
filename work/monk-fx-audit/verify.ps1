$ErrorActionPreference='Stop'
$lib=Join-Path (Get-Location) 'tools_to_mod/FLVER_Editor_X2.6/Debug'
[Runtime.InteropServices.NativeLibrary]::Load((Join-Path $lib 'oo2core_6_win64.dll')) | Out-Null
[Reflection.Assembly]::LoadFrom((Join-Path $lib 'SoulsFormats.dll')) | Out-Null
$game='C:\Program Files (x86)\Steam\steamapps\common\Sekiro'
$release=Join-Path (Get-Location) 'releases/Nicky-Allowed-Invisible-Centipedes-alpha-0.1.8'
$rows=foreach($name in @('sfxbnd_commoneffects.ffxbnd.dcx','sfxbnd_m15.ffxbnd.dcx','sfxbnd_m25.ffxbnd.dcx')){
 $p=Join-Path $release "mods/sfx/$name";$installed=Join-Path $game "mods/sfx/$name"
 if((Get-FileHash $p).Hash -ne (Get-FileHash $installed).Hash){throw 'Installed package differs'}
 $b=[SoulsFormats.BND4]::Read($p)
 foreach($e in $b.Files){if($e.Name -notmatch 'f000(612010|612100|612101|650010|650011|650012)\.fxr$'){continue}
 [xml]$x=([SoulsFormats.FXR3EnhancedSerialization]::FXR3ToXML([SoulsFormats.FXR3]::Read([byte[]]$e.Bytes))).ToString()
 $remaining=@($x.SelectNodes('//*[@Value="4092" or @Value="4093"]')).Count
 if($remaining){throw 'Centipede reference remains'}
 [pscustomobject]@{Binder=$name;Effect=[IO.Path]::GetFileName($e.Name);RemainingCentipedeFields=$remaining;BloodTextureProperties=@($x.SelectNodes('//Action[@Id="603"]/Properties1/Property[1]/Fields/Float[@Value="11606"]')).Count;InstalledHashMatches=$true}
 }
}
$rows | ConvertTo-Json | Set-Content work/monk-fx-audit/current-validation.json
$rows | Format-Table
