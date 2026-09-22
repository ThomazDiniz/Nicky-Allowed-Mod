param(
    [ValidateSet('patch','minor','major')][string]$Bump,
    [string]$Version,
    [string]$Overlay,
    [switch]$Preview,
    [switch]$KeepPrevious
)
$ErrorActionPreference = 'Stop'
if ($Bump -and $Version) { throw 'Use either -Bump or -Version.' }
$bundled = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$python = if (Test-Path -LiteralPath $bundled) { $bundled } else { (Get-Command python -ErrorAction Stop).Source }
$buildArgs = @((Join-Path $PSScriptRoot 'work\build_release.py'))
if ($Bump) { $buildArgs += @('--bump',$Bump) }
if ($Version) { $buildArgs += @('--version',$Version) }
if ($Overlay) { $buildArgs += @('--overlay',[IO.Path]::GetFullPath($Overlay)) }
if ($Preview) { $buildArgs += '--preview' }
$output = & $python @buildArgs
if ($LASTEXITCODE -ne 0) { throw 'Release build failed; previous releases were preserved.' }
$result = ($output -join "`n") | ConvertFrom-Json
if ($Preview) { $result; return }
if (-not $result.AllZipHashesMatch -or (Get-FileHash -LiteralPath $result.Zip).Hash -ne $result.ZipSHA256) { throw 'Release verification failed; cleanup cancelled.' }
$releaseRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'releases'))
if (-not $KeepPrevious) {
    foreach ($item in Get-ChildItem -LiteralPath $releaseRoot) {
        if ($item.Name -notmatch '^Nicky-Allowed-Invisible(?:-Centipedes)?-alpha-\d+\.\d+\.\d+(?:\.zip(?:\.sha256)?)?$') { continue }
        if ($item.FullName -in @($result.Release,$result.Zip,($result.Zip + '.sha256'))) { continue }
        $resolved = [IO.Path]::GetFullPath($item.FullName)
        if ([IO.Path]::GetDirectoryName($resolved) -ne $releaseRoot -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Unsafe release cleanup path' }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
$stagingRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'work\release-staging'))
foreach ($path in @($result.Staging,$result.StagingZip)) {
    $resolved = [IO.Path]::GetFullPath($path)
    if ([IO.Path]::GetDirectoryName($resolved) -ne $stagingRoot) { throw 'Unsafe staging cleanup path' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
$result
