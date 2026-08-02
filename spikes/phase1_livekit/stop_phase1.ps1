$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$runtimeDirectory = Join-Path $root '.runtime'
$processFile = Join-Path $runtimeDirectory 'processes.json'

function Get-MatchingRecordedProcess {
    param([Parameter(Mandatory = $true)]$Record)

    $cimProcess = Get-CimInstance Win32_Process -Filter "ProcessId = $($Record.pid)" -ErrorAction SilentlyContinue
    if (-not $cimProcess) {
        return $null
    }

    if (-not $Record.executablePath -or -not $cimProcess.ExecutablePath) {
        return $null
    }

    $expectedPath = [System.IO.Path]::GetFullPath([string]$Record.executablePath)
    $actualPath = [System.IO.Path]::GetFullPath([string]$cimProcess.ExecutablePath)
    if ($actualPath -ine $expectedPath) {
        return $null
    }

    $marker = [string]$Record.commandMarker
    if ($marker) {
        $commandLine = [string]$cimProcess.CommandLine
        if ($commandLine.IndexOf($marker, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
            return $null
        }
    }

    return $cimProcess
}

$stopped = 0
$skipped = 0

if (Test-Path $processFile) {
    try {
        $records = Get-Content $processFile -Raw | ConvertFrom-Json
        foreach ($record in @($records)) {
            $process = Get-MatchingRecordedProcess -Record $record
            if ($process) {
                Stop-Process -Id $record.pid -Force -ErrorAction SilentlyContinue
                Write-Host "Stopped $($record.name) (PID $($record.pid))."
                $stopped++
            } else {
                Write-Host "Skipped stale or mismatched PID $($record.pid) ($($record.name))." -ForegroundColor Yellow
                $skipped++
            }
        }
    } finally {
        Remove-Item $processFile -Force -ErrorAction SilentlyContinue
    }
}

# Remove only the native LiveKit executable from this repository if it was left
# behind after a terminal or script crash.
& (Join-Path $root 'infrastructure\stop_livekit.ps1')

if ($stopped -eq 0) {
    Write-Host 'No verified Phase 1 token/Python processes were running.' -ForegroundColor Yellow
} else {
    Write-Host "Stopped $stopped verified Phase 1 process(es)." -ForegroundColor Green
}

if ($skipped -gt 0) {
    Write-Host "$skipped stale PID record(s) were ignored safely." -ForegroundColor Yellow
}

Write-Host 'Close any Flutter run terminal separately with Ctrl+C.'
