[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$ArchiveRoot,
    [switch]$SkipInstall,
    [switch]$VerifyLean,
    [switch]$VerifyTex
)

$ErrorActionPreference = 'Stop'
$archive = (Resolve-Path -LiteralPath $ArchiveRoot).Path
$shell = (Get-Command powershell -ErrorAction SilentlyContinue).Source
if (-not $shell) { $shell = (Get-Command pwsh -ErrorAction Stop).Source }

$retainedArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
    (Join-Path $PSScriptRoot 'reproduce.ps1'), '-ArchiveRoot', $archive)
if ($SkipInstall) { $retainedArgs += '-SkipInstall' }
if ($VerifyLean) { $retainedArgs += '-VerifyLean' }
if ($VerifyTex) { $retainedArgs += '-VerifyTex' }
& $shell @retainedArgs
$retainedCode = $LASTEXITCODE

$intervalArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
    (Join-Path $PSScriptRoot 'run_interval_certificates.ps1'), '-ArchiveRoot', $archive)
if ($SkipInstall) { $intervalArgs += '-SkipInstall' }
& $shell @intervalArgs
$intervalCode = $LASTEXITCODE

$reproduced = Join-Path $archive 'numerics\reproduced'
$retainedReport = Get-ChildItem -LiteralPath $reproduced -Recurse -File -Filter 'aggregate.json' |
    Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
$intervalReport = Get-ChildItem -LiteralPath $reproduced -Recurse -File -Filter 'interval_aggregate.json' |
    Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
$combinedRoot = Join-Path $reproduced (([DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ')) + '_combined')
New-Item -ItemType Directory -Path $combinedRoot | Out-Null
$combined = [ordered]@{
    generated_at_utc = [DateTime]::UtcNow.ToString('o')
    archive_root = $archive
    retained_exit_code = $retainedCode
    interval_exit_code = $intervalCode
    retained_report = if ($retainedReport) { $retainedReport.FullName } else { $null }
    retained_report_sha256 = if ($retainedReport) { (Get-FileHash -Algorithm SHA256 $retainedReport.FullName).Hash.ToLowerInvariant() } else { $null }
    interval_report = if ($intervalReport) { $intervalReport.FullName } else { $null }
    interval_report_sha256 = if ($intervalReport) { (Get-FileHash -Algorithm SHA256 $intervalReport.FullName).Hash.ToLowerInvariant() } else { $null }
    pass = ($retainedCode -eq 0 -and $intervalCode -eq 0 -and $retainedReport -and $intervalReport)
}
$combined | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $combinedRoot 'combined_aggregate.json') -Encoding UTF8
if (-not $combined.pass) { exit 1 }
exit 0
