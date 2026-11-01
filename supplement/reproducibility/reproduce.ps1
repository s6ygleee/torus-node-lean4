[CmdletBinding()]
param(
    [string]$ArchiveRoot = '',
    [switch]$SkipInstall,
    [switch]$SkipCalculations,
    [switch]$VerifyLean,
    [switch]$VerifyTex
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($ArchiveRoot)) {
    if (Test-Path -LiteralPath (Join-Path $PSScriptRoot '..\..\..\SHA256SUMS.txt')) {
        $ArchiveRoot = Join-Path $PSScriptRoot '..\..\..'
    } else {
        $ArchiveRoot = Join-Path $PSScriptRoot '..\..\..\..'
    }
}
$archive = (Resolve-Path -LiteralPath $ArchiveRoot).Path
$requirements = Join-Path $PSScriptRoot 'requirements-lock.txt'
$driver = Join-Path $PSScriptRoot 'reproduce.py'
$python = (Get-Command python -ErrorAction Stop).Source
$nodeVersion = (& node --version).Trim()
$pythonVersion = (& $python -c 'import platform; print(platform.python_version())').Trim()
if ($pythonVersion -ne '3.12.10') { throw "CPython 3.12.10 required, found $pythonVersion" }
if ($nodeVersion -ne 'v24.18.0') { throw "Node v24.18.0 required, found $nodeVersion" }

$tempRoot = $null
try {
    if (-not $SkipInstall) {
        $tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("torus-reproduction-repro-" + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $tempRoot | Out-Null
        & $python -m venv (Join-Path $tempRoot 'venv')
        if ($LASTEXITCODE -ne 0) { throw 'venv creation failed' }
        $python = Join-Path $tempRoot 'venv\Scripts\python.exe'
        & $python -m pip install --disable-pip-version-check --require-hashes -r $requirements
        if ($LASTEXITCODE -ne 0) { throw 'locked dependency installation failed' }
    }
    $arguments = @($driver, '--archive-root', $archive)
    if ($SkipCalculations) { $arguments += '--skip-calculations' }
    if ($VerifyLean) { $arguments += '--verify-lean' }
    if ($VerifyTex) { $arguments += '--verify-tex' }
    & $python @arguments
    exit $LASTEXITCODE
} finally {
    if ($tempRoot) {
        $resolvedTemp = [IO.Path]::GetFullPath($tempRoot)
        $systemTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
        if ($resolvedTemp.StartsWith($systemTemp, [StringComparison]::OrdinalIgnoreCase) -and
            [IO.Path]::GetFileName($resolvedTemp).StartsWith('torus-reproduction-repro-')) {
            Remove-Item -LiteralPath $resolvedTemp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
