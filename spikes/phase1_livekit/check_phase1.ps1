$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$runtimeDirectory = Join-Path $root '.runtime'
$processFile = Join-Path $runtimeDirectory 'processes.json'
$envFile = Join-Path $root '.env'

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

function Import-DotEnvValues {
    param([Parameter(Mandatory = $true)][string]$Path)

    $values = @{}
    if (-not (Test-Path $Path)) {
        return $values
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
        $values[$name] = $value
    }
    return $values
}

function Test-RecordedProcess {
    param([Parameter(Mandatory = $true)]$Record)

    $cimProcess = Get-CimInstance Win32_Process -Filter "ProcessId = $($Record.pid)" -ErrorAction SilentlyContinue
    if (-not $cimProcess -or -not $Record.executablePath -or -not $cimProcess.ExecutablePath) {
        return $false
    }

    $expectedPath = [System.IO.Path]::GetFullPath([string]$Record.executablePath)
    $actualPath = [System.IO.Path]::GetFullPath([string]$cimProcess.ExecutablePath)
    if ($actualPath -ine $expectedPath) {
        return $false
    }

    $marker = [string]$Record.commandMarker
    if ($marker) {
        $commandLine = [string]$cimProcess.CommandLine
        if ($commandLine.IndexOf($marker, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
            return $false
        }
    }

    return $true
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

$envValues = Import-DotEnvValues -Path $envFile
$lanIp = if ($envValues.ContainsKey('LIVEKIT_NODE_IP')) {
    [string]$envValues['LIVEKIT_NODE_IP']
} else {
    ''
}
$expectedPublicUrl = if ($envValues.ContainsKey('LIVEKIT_PUBLIC_URL')) {
    [string]$envValues['LIVEKIT_PUBLIC_URL']
} else {
    ''
}
$roomName = if ($envValues.ContainsKey('ROOM_NAME') -and $envValues['ROOM_NAME']) {
    [string]$envValues['ROOM_NAME']
} else {
    'phase1-room'
}

$livekitExe = Join-Path $root 'infrastructure\bin\livekit-server.exe'
$tokenPython = Join-Path $root 'token_service\.venv\Scripts\python.exe'
$participantPython = Join-Path $root 'python_participant\.venv\Scripts\python.exe'
$flutterAndroid = Join-Path $root 'flutter_client\android'
$participantErrorLog = Join-Path $runtimeDirectory 'python-participant.err.log'
$participantOutputLog = Join-Path $runtimeDirectory 'python-participant.out.log'

Write-Host 'AI Teacher Phase 1 status' -ForegroundColor Cyan
Write-Host ''

Write-Check 'Environment file exists' (Test-Path $envFile)
Write-Check 'Native LiveKit binary installed' (Test-Path $livekitExe)
Write-Check 'Token-service Python environment installed' (Test-Path $tokenPython)
Write-Check 'Python-participant environment installed' (Test-Path $participantPython)
Write-Check 'Flutter Android client generated' (Test-Path $flutterAndroid)

$livekitLocalPort = Test-TcpPort -HostName '127.0.0.1' -Port 7880
$tokenLocalPort = Test-TcpPort -HostName '127.0.0.1' -Port 8090
$livekitLanPort = $false
$tokenLanPort = $false
if ($lanIp) {
    $livekitLanPort = Test-TcpPort -HostName $lanIp -Port 7880
    $tokenLanPort = Test-TcpPort -HostName $lanIp -Port 8090
}

Write-Check 'LiveKit localhost signaling port 7880 reachable' $livekitLocalPort
Write-Check 'Token service localhost port 8090 reachable' $tokenLocalPort
Write-Check "LiveKit LAN port $lanIp`:7880 reachable" $livekitLanPort
Write-Check "Token service LAN port $lanIp`:8090 reachable" $tokenLanPort

$healthPassed = $false
$lanHealthPassed = $false
$tokenGenerationPassed = $false
if ($tokenLocalPort) {
    try {
        $health = Invoke-RestMethod -Uri 'http://127.0.0.1:8090/health' -TimeoutSec 5
        $healthPassed = $health.status -eq 'ok'
    } catch {
        $healthPassed = $false
    }

    if ($healthPassed) {
        try {
            $smokeIdentity = 'phase1-check-' + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
            $tokenUri = 'http://127.0.0.1:8090/token?room=' + [Uri]::EscapeDataString($roomName) + '&identity=' + [Uri]::EscapeDataString($smokeIdentity) + '&name=Phase1%20Checker'
            $tokenResponse = Invoke-RestMethod -Uri $tokenUri -TimeoutSec 5
            $tokenGenerationPassed =
                [bool]$tokenResponse.token -and
                $tokenResponse.url -eq $expectedPublicUrl -and
                $tokenResponse.room -eq $roomName -and
                $tokenResponse.identity -eq $smokeIdentity
        } catch {
            $tokenGenerationPassed = $false
        }
    }
}

if ($tokenLanPort -and $lanIp) {
    try {
        $lanHealth = Invoke-RestMethod -Uri "http://$lanIp`:8090/health" -TimeoutSec 5
        $lanHealthPassed = $lanHealth.status -eq 'ok'
    } catch {
        $lanHealthPassed = $false
    }
}

Write-Check 'Token service localhost health returns status=ok' $healthPassed
Write-Check 'Token service LAN health returns status=ok' $lanHealthPassed
Write-Check 'Token service generates credentials with the expected public URL' $tokenGenerationPassed

$recordedProcessesAlive = $false
if (Test-Path $processFile) {
    try {
        # Windows PowerShell 5.1 already returns a collection for a top-level
        # JSON array. Wrapping the pipeline in @() can collapse it into one
        # object whose properties are arrays, which makes every PID check fail.
        $records = Get-Content $processFile -Raw | ConvertFrom-Json
        $expectedNames = @('livekit', 'token-service', 'python-participant')
        $recordedProcessesAlive = $records.Count -eq $expectedNames.Count

        foreach ($expectedName in $expectedNames) {
            $record = $records | Where-Object { $_.name -eq $expectedName } | Select-Object -First 1
            if (-not $record -or -not (Test-RecordedProcess -Record $record)) {
                $recordedProcessesAlive = $false
            }
        }
    } catch {
        $recordedProcessesAlive = $false
    }
}
Write-Check 'Verified LiveKit, token service and Python participant processes alive' $recordedProcessesAlive

$log = ''
foreach ($logPath in @($participantErrorLog, $participantOutputLog)) {
    if (Test-Path $logPath) {
        $log += "`n" + (Get-Content $logPath -Raw)
    }
}

$publishedAudio = $log -match 'Published generated test audio'
$publishedVideo = $log -match 'Published generated test video'
$receivedClientAudio = $log -match 'Received user audio identity=flutter-'
$flutterParticipantSeen = $log -match 'Participant connected identity=flutter-'

Write-Check 'Python participant published generated audio' $publishedAudio
Write-Check 'Python participant published generated video' $publishedVideo
Write-Check 'Flutter client participant joined the room' $flutterParticipantSeen
Write-Check 'Python participant received Flutter microphone frames' $receivedClientAudio

Write-Host ''
$coreEvidence =
    $livekitLocalPort -and
    $tokenLocalPort -and
    $livekitLanPort -and
    $tokenLanPort -and
    $healthPassed -and
    $lanHealthPassed -and
    $tokenGenerationPassed -and
    $recordedProcessesAlive -and
    $publishedAudio -and
    $publishedVideo -and
    $flutterParticipantSeen -and
    $receivedClientAudio

if ($coreEvidence) {
    Write-Host 'Core same-Wi-Fi transport evidence is present.' -ForegroundColor Green
    Write-Host 'Manual confirmation is still required that this was a physical phone, remote video was visible, the test tone was audible, controls worked, reconnect succeeded and leave was clean.'
} else {
    Write-Host 'Phase 1 implementation is ready, but current-run device evidence is incomplete.' -ForegroundColor Yellow
    Write-Host 'Start services, join from the phone and run this checker again.'
}
