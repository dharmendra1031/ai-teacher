$ErrorActionPreference = 'Stop'

$expectedExecutable = (Join-Path $PSScriptRoot 'bin\livekit-server.exe')
$expectedExecutable = [System.IO.Path]::GetFullPath($expectedExecutable)

$processes = Get-CimInstance Win32_Process -Filter "Name = 'livekit-server.exe'"
$stopped = 0

foreach ($process in $processes) {
    $processPath = $process.ExecutablePath
    if (-not $processPath) {
        continue
    }

    $fullProcessPath = [System.IO.Path]::GetFullPath($processPath)
    if ($fullProcessPath -ieq $expectedExecutable) {
        Stop-Process -Id $process.ProcessId -Force
        $stopped++
    }
}

if ($stopped -eq 0) {
    Write-Host 'The Phase 1 LiveKit process is not running.' -ForegroundColor Yellow
} else {
    Write-Host "Stopped $stopped Phase 1 LiveKit process(es)." -ForegroundColor Green
}
