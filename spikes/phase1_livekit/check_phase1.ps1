$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$runtimeDirectory = Join-Path $root '.runtime'
$processFile = Join-Path $runtimeDirectory 'processes.json'

function Test-TcpPort {
    param(
        [Parameter(Mandatory = $true)][string]$HostName,
        [Parameter(Mandatory = $true)][int]$Port
    )

    try {
        $client = [System.Net.Sockets.TcpClient]::new()
        $task = $client.ConnectAsync($HostName, $Port)
        $connected = $task.Wait(1500) -and $client.Connected
        $client.Dispose()
        return $connected
    } catch {
        return $false
    }
}

function Write-Check {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][bool]$Passed,
        [string]$PendingText = 'PENDING'
    )

    if ($Passed) {
        Write-Host ("[PASS]    {0}" -f $Label) -ForegroundColor Green
    } else {
        Write-Host ("[{0}] {1}" -f $PendingText.PadRight(7), $Label) -ForegroundColor Yellow
    }
}

$livekitExe = Join-Path $root 'infrastructure\bin\livekit-server.exe'
$tokenPython = Join-Path $root 'token_service\.venv\Scripts\python.exe'
$participantPython = Join-Path $root 'python_participant\.venv\Scripts\python.exe'
$flutterAndroid = Join-Path $root 'flutter_client\android'
$participantLog = Join-Path $runtimeDirectory 'python-participant.err.log'
if (-not (Test-Path $participantLog)) {
    $participantLog = Join-Path $runtimeDirectory 'python-participant.out.log'
}

Write-Host 'AI Teacher Phase 1 status' -ForegroundColor Cyan
Write-Host ''

Write-Check 'Native LiveKit binary installed' (Test-Path $livekitExe)
Write-Check 'Token-service Python environment installed' (Test-Path $tokenPython)
Write-Check 'Python-participant environment installed' (Test-Path $participantPython)
Write-Check 'Flutter Android client generated' (Test-Path $flutterAndroid)

$livekitPort = Test-TcpPort -HostName '127.0.0.1' -Port 7880
$tokenPort = Test-TcpPort -HostName '127.0.0.1' -Port 8090
Write-Check 'LiveKit signaling port 7880 reachable' $livekitPort
Write-Check 'Token service port 8090 reachable' $tokenPort

$healthPassed = $false
if ($tokenPort) {
    try {
        $health = Invoke-RestMethod -Uri 'http://127.0.0.1:8090/health' -TimeoutSec 5
        $healthPassed = $health.status -eq 'ok'
    } catch {
        $healthPassed = $false
    }
}
Write-Check 'Token service health endpoint returns status=ok' $healthPassed

$recordedProcessesAlive = $false
if (Test-Path $processFile) {
    try {
        $records = Get-Content $processFile -Raw | ConvertFrom-Json
        $recordedProcessesAlive = @($records).Count -ge 3
        foreach ($record in $records) {
            if (-not (Get-Process -Id $record.pid -ErrorAction SilentlyContinue)) {
                $recordedProcessesAlive = $false
            }
        }
    } catch {
        $recordedProcessesAlive = $false
    }
}
Write-Check 'LiveKit, token service and Python participant processes alive' $recordedProcessesAlive

$publishedAudio = $false
$publishedVideo = $false
$receivedPhoneAudio = $false
$flutterParticipantSeen = $false

if (Test-Path $participantLog) {
    $log = Get-Content $participantLog -Raw
    $publishedAudio = $log -match 'Published generated test audio'
    $publishedVideo = $log -match 'Published generated test video'
    $receivedPhoneAudio = $log -match 'Received user audio'
    $flutterParticipantSeen = $log -match 'Participant connected identity=flutter-'
}

Write-Check 'Python participant published generated audio' $publishedAudio
Write-Check 'Python participant published generated video' $publishedVideo
Write-Check 'Physical Flutter participant joined the room' $flutterParticipantSeen
Write-Check 'Python participant received phone microphone frames' $receivedPhoneAudio

Write-Host ''
if ($livekitPort -and $healthPassed -and $publishedAudio -and $publishedVideo -and $flutterParticipantSeen -and $receivedPhoneAudio) {
    Write-Host 'Core same-Wi-Fi transport evidence is present.' -ForegroundColor Green
    Write-Host 'Manual checks still required: remote video visible, test tone audible, controls, reconnect and clean leave.'
} else {
    Write-Host 'Phase 1 implementation is ready, but physical-device evidence is still incomplete.' -ForegroundColor Yellow
    Write-Host 'Start services, join from the phone and run this checker again.'
}
