$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$runtimeDirectory = Join-Path $root '.runtime'
$processFile = Join-Path $runtimeDirectory 'processes.json'

$stopped = 0

if (Test-Path $processFile) {
    try {
        $records = Get-Content $processFile -Raw | ConvertFrom-Json
        foreach ($record in $records) {
            $process = Get-Process -Id $record.pid -ErrorAction SilentlyContinue
            if ($process) {
                Stop-Process -Id $record.pid -Force -ErrorAction SilentlyContinue
                Write-Host "Stopped $($record.name) (PID $($record.pid))."
                $stopped++
            }
        }
    } finally {
        Remove-Item $processFile -Force -ErrorAction SilentlyContinue
    }
}

# Remove a native LiveKit process left behind after a terminal or script crash.
& (Join-Path $root 'infrastructure\stop_livekit.ps1')

if ($stopped -eq 0) {
    Write-Host 'No recorded Phase 1 token/Python processes were running.' -ForegroundColor Yellow
} else {
    Write-Host "Stopped $stopped recorded Phase 1 process(es)." -ForegroundColor Green
}

Write-Host 'Close any Flutter run terminal separately with Ctrl+C.'
