[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$ArchiveRoot,
    [switch]$SkipInstall
)

$ErrorActionPreference = 'Stop'
$archive = (Resolve-Path -LiteralPath $ArchiveRoot).Path
$python = (Get-Command python -ErrorAction Stop).Source
$version = (& $python -c 'import platform; print(platform.python_version())').Trim()
if ($version -ne '3.12.10') { throw "CPython 3.12.10 required, found $version" }
if ((& node --version).Trim() -ne 'v24.18.0') { throw 'Node v24.18.0 required' }

$tempRoot = $null
try {
    if (-not $SkipInstall) {
        $tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("torus-reproduction-interval-" + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $tempRoot | Out-Null
        & $python -m venv (Join-Path $tempRoot 'venv')
        if ($LASTEXITCODE -ne 0) { throw 'interval venv creation failed' }
        $python = Join-Path $tempRoot 'venv\Scripts\python.exe'
        & $python -m pip install --disable-pip-version-check --require-hashes `
            -r (Join-Path $PSScriptRoot 'interval-requirements-lock.txt')
        if ($LASTEXITCODE -ne 0) { throw 'locked python-flint installation failed' }
    }
    & $python (Join-Path $PSScriptRoot 'run_interval_certificates.py') --archive-root $archive
    exit $LASTEXITCODE
} finally {
    if ($tempRoot) {
        $resolved = [IO.Path]::GetFullPath($tempRoot)
        $systemTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
        if ($resolved.StartsWith($systemTemp, [StringComparison]::OrdinalIgnoreCase) -and
            [IO.Path]::GetFileName($resolved).StartsWith('torus-reproduction-interval-')) {
            Remove-Item -LiteralPath $resolved -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
