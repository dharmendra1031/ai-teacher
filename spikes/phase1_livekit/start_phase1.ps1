param(
    [switch]$RunFlutter
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$runtimeDirectory = Join-Path $root '.runtime'
$processFile = Join-Path $runtimeDirectory 'processes.json'
$envFile = Join-Path $root '.env'

function Import-DotEnv {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Missing $Path. Run .\setup_phase1.ps1 first."
    }

    foreach ($line in Get-Content $Path) {
        $trimmed = $line.Trim()
        if (-not $trimmed -or $trimmed.StartsWith('#')) {
            continue
        }

        $separatorIndex = $trimmed.IndexOf('=')
        if ($separatorIndex -lt 1) {
            continue
        }

        $name = $trimmed.Substring(0, $separatorIndex).Trim()
        $value = $trimmed.Substring($separatorIndex + 1).Trim()
        [Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
}

function Wait-TcpPort {
    param(
        [Parameter(Mandatory = $true)][string]$HostName,
        [Parameter(Mandatory = $true)][int]$Port,
        [int]$TimeoutSeconds = 25
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    do {
        try {
            $client = [System.Net.Sockets.TcpClient]::new()
            $task = $client.ConnectAsync($HostName, $Port)
            if ($task.Wait(1000) -and $client.Connected) {
                $client.Dispose()
                return
            }
            $client.Dispose()
        } catch {
            Start-Sleep -Milliseconds 500
        }
        Start-Sleep -Milliseconds 500
    } while ((Get-Date) -lt $deadline)

    throw "Timed out waiting for $HostName`:$Port."
}

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

function Stop-RecordedProcesses {
    if (-not (Test-Path $processFile)) {
        return
    }

    try {
        $records = Get-Content $processFile -Raw | ConvertFrom-Json
        foreach ($record in @($records)) {
            $process = Get-MatchingRecordedProcess -Record $record
            if ($process) {
                Stop-Process -Id $record.pid -Force -ErrorAction SilentlyContinue
            } else {
                Write-Host "Skipped stale or mismatched PID $($record.pid) ($($record.name))." -ForegroundColor Yellow
            }
        }
    } finally {
        Remove-Item $processFile -Force -ErrorAction SilentlyContinue
    }
}

New-Item -ItemType Directory -Path $runtimeDirectory -Force | Out-Null
Import-DotEnv -Path $envFile
Stop-RecordedProcesses

$livekitExecutable = [System.IO.Path]::GetFullPath((Join-Path $root 'infrastructure\bin\livekit-server.exe'))
$livekitConfig = [System.IO.Path]::GetFullPath((Join-Path $root 'infrastructure\livekit.yaml'))
$tokenPython = [System.IO.Path]::GetFullPath((Join-Path $root 'token_service\.venv\Scripts\python.exe'))
$tokenScript = [System.IO.Path]::GetFullPath((Join-Path $root 'token_service\server.py'))
$participantPython = [System.IO.Path]::GetFullPath((Join-Path $root 'python_participant\.venv\Scripts\python.exe'))
$participantScript = [System.IO.Path]::GetFullPath((Join-Path $root 'python_participant\participant.py'))

foreach ($requiredPath in @(
    $livekitExecutable,
    $livekitConfig,
    $tokenPython,
    $tokenScript,
    $participantPython,
    $participantScript
)) {
    if (-not (Test-Path $requiredPath)) {
        throw "Missing required file: $requiredPath. Run .\setup_phase1.ps1 first."
    }
}

$quotedLivekitConfig = '"'.Replace('\', '') + $livekitConfig + '"'.Replace('\', '')
$quotedTokenScript = '"'.Replace('\', '') + $tokenScript + '"'.Replace('\', '')
$quotedParticipantScript = '"'.Replace('\', '') + $participantScript + '"'.Replace('\', '')
$processRecords = @()

try {
    Write-Host 'Starting native LiveKit Server...' -ForegroundColor Cyan
    $livekitStart = @{
        FilePath                = $livekitExecutable
        ArgumentList            = @('--config', $quotedLivekitConfig, '--bind', '0.0.0.0', '--node-ip', $env:LIVEKIT_NODE_IP)
        WorkingDirectory        = $root
        RedirectStandardOutput = (Join-Path $runtimeDirectory 'livekit.out.log')
        RedirectStandardError  = (Join-Path $runtimeDirectory 'livekit.err.log')
        PassThru                = $true
    }
    $livekitProcess = Start-Process @livekitStart
    $processRecords += [pscustomobject]@{
        name = 'livekit'
        pid = $livekitProcess.Id
        executablePath = $livekitExecutable
        commandMarker = $livekitConfig
    }
    Wait-TcpPort -HostName '127.0.0.1' -Port 7880

    Write-Host 'Starting development token service...' -ForegroundColor Cyan
    $tokenStart = @{
        FilePath                = $tokenPython
        ArgumentList            = @($quotedTokenScript)
        WorkingDirectory        = $root
        RedirectStandardOutput = (Join-Path $runtimeDirectory 'token-service.out.log')
        RedirectStandardError  = (Join-Path $runtimeDirectory 'token-service.err.log')
        PassThru                = $true
    }
    $tokenProcess = Start-Process @tokenStart
    $processRecords += [pscustomobject]@{
        name = 'token-service'
        pid = $tokenProcess.Id
        executablePath = $tokenPython
        commandMarker = $tokenScript
    }
    Wait-TcpPort -HostName '127.0.0.1' -Port 8090

    $health = Invoke-RestMethod -Uri 'http://127.0.0.1:8090/health' -TimeoutSec 5
    if ($health.status -ne 'ok') {
        throw 'Token service health check did not return status=ok.'
    }

    Write-Host 'Starting Python test participant...' -ForegroundColor Cyan
    $participantStart = @{
        FilePath                = $participantPython
        ArgumentList            = @($quotedParticipantScript)
        WorkingDirectory        = $root
        RedirectStandardOutput = (Join-Path $runtimeDirectory 'python-participant.out.log')
        RedirectStandardError  = (Join-Path $runtimeDirectory 'python-participant.err.log')
        PassThru                = $true
    }
    $participantProcess = Start-Process @participantStart
    $processRecords += [pscustomobject]@{
        name = 'python-participant'
        pid = $participantProcess.Id
        executablePath = $participantPython
        commandMarker = $participantScript
    }

    $processRecords | ConvertTo-Json -Depth 3 | Set-Content -Path $processFile -Encoding UTF8
    Start-Sleep -Seconds 3

    foreach ($record in $processRecords) {
        if (-not (Get-MatchingRecordedProcess -Record $record)) {
            throw "$($record.name) stopped immediately. Check .runtime log files."
        }
    }

    Write-Host ''
    Write-Host 'Phase 1 services are running.' -ForegroundColor Green
    Write-Host "LiveKit: $($env:LIVEKIT_PUBLIC_URL)"
    Write-Host "Token service: $($env:TOKEN_SERVICE_PUBLIC_URL)"
    Write-Host 'Logs: .\.runtime\'

    if ($RunFlutter) {
        $flutterRoot = Join-Path $root 'flutter_client'
        $escapedFlutterRoot = $flutterRoot.Replace("'", "''")
        $flutterCommand = "Set-Location '$escapedFlutterRoot'; flutter run --dart-define=TOKEN_SERVICE_URL=$($env:TOKEN_SERVICE_PUBLIC_URL)"
        Start-Process powershell.exe -ArgumentList @('-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', $flutterCommand)
        Write-Host 'Flutter run window opened.' -ForegroundColor Green
    } else {
        Write-Host ''
        Write-Host 'Connect the physical Android phone, then run:'
        Write-Host 'powershell -ExecutionPolicy Bypass -File .\start_phase1.ps1 -RunFlutter'
    }
} catch {
    if ($processRecords.Count -gt 0) {
        $processRecords | ConvertTo-Json -Depth 3 | Set-Content -Path $processFile -Encoding UTF8
    }
    & (Join-Path $root 'stop_phase1.ps1')
    throw
}
