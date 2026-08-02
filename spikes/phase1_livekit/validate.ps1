$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$liveKitExecutable = Join-Path $root 'infrastructure\bin\livekit-server.exe'
$runtimeConfigScript = Join-Path $root 'infrastructure\new_runtime_config.ps1'
$runtimeDirectory = Join-Path $root '.runtime'
Push-Location $root

function Assert-LastExitCode {
    param([Parameter(Mandatory = $true)][string]$Operation)

    if ($LASTEXITCODE -ne 0) {
        throw "$Operation failed with exit code $LASTEXITCODE."
    }
}

function Import-DotEnvValues {
    param([Parameter(Mandatory = $true)][string]$Path)

    $values = @{}
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

function Assert-FirewallRule {
    param(
        [Parameter(Mandatory = $true)][string]$DisplayName,
        [Parameter(Mandatory = $true)][string]$Protocol,
        [Parameter(Mandatory = $true)][string[]]$ExpectedPorts
    )

    $rules = @(Get-NetFirewallRule -DisplayName $DisplayName -ErrorAction SilentlyContinue)
    if ($rules.Count -ne 1) {
        throw "Expected exactly one enabled firewall rule named '$DisplayName', found $($rules.Count). Re-run setup as Administrator."
    }

    $rule = $rules[0]
    if ([string]$rule.Enabled -ne 'True' -or [string]$rule.Direction -ne 'Inbound' -or [string]$rule.Action -ne 'Allow') {
        throw "Firewall rule '$DisplayName' must be enabled, inbound and allow traffic."
    }

    $filters = @($rule | Get-NetFirewallPortFilter)
    if ($filters.Count -eq 0) {
        throw "Firewall rule '$DisplayName' has no port filter."
    }

    $filterProtocol = [string]$filters[0].Protocol
    if ($filterProtocol -ne $Protocol) {
        throw "Firewall rule '$DisplayName' must use $Protocol, found $filterProtocol."
    }

    $portText = (@($filters | ForEach-Object { $_.LocalPort }) -join ',')
    foreach ($expectedPort in $ExpectedPorts) {
        if ($portText -notmatch ('(^|,)' + [regex]::Escape($expectedPort) + '(,|$)')) {
            throw "Firewall rule '$DisplayName' is missing local port $expectedPort. Found: $portText"
        }
    }
}

try {
    Write-Host '1/9 PowerShell syntax checks'
    $parseFailures = @()
    $excludedPattern = '\\(\.venv|\.dart_tool|build|android|\.runtime|bin)\\'
    Get-ChildItem -Path $root -Filter '*.ps1' -File -Recurse |
        Where-Object { $_.FullName -notmatch $excludedPattern } |
        ForEach-Object {
            $tokens = $null
            $errors = $null
            [System.Management.Automation.Language.Parser]::ParseFile(
                $_.FullName,
                [ref]$tokens,
                [ref]$errors
            ) | Out-Null

            foreach ($parseError in $errors) {
                $parseFailures += ('{0}:{1}:{2} {3}' -f $_.FullName, $parseError.Extent.StartLineNumber, $parseError.Extent.StartColumnNumber, $parseError.Message)
            }
        }

    if ($parseFailures.Count -gt 0) {
        $parseFailures | ForEach-Object { Write-Host $_ -ForegroundColor Red }
        throw "PowerShell syntax validation failed with $($parseFailures.Count) error(s)."
    }

    Write-Host '2/9 Python 3.12 and source syntax checks'
    if (-not (Get-Command py -ErrorAction SilentlyContinue)) {
        throw "Python launcher 'py' was not found in PATH."
    }
    py -3.12 --version
    Assert-LastExitCode -Operation 'Python 3.12 check'
    py -3.12 -m py_compile token_service\server.py
    Assert-LastExitCode -Operation 'Token-service Python syntax check'
    py -3.12 -m py_compile python_participant\participant.py
    Assert-LastExitCode -Operation 'Python-participant syntax check'

    Write-Host '3/9 Python virtual-environment dependency and SDK checks'
    $tokenPython = Join-Path $root 'token_service\.venv\Scripts\python.exe'
    $participantPython = Join-Path $root 'python_participant\.venv\Scripts\python.exe'
    foreach ($pythonPath in @($tokenPython, $participantPython)) {
        if (-not (Test-Path $pythonPath)) {
            throw "Missing Python virtual environment executable: $pythonPath"
        }
    }

    & $tokenPython -c "from importlib.metadata import version; from livekit import api; assert version('livekit-api') == '1.2.0'; assert hasattr(api, 'AccessToken'); print('token SDK ok')"
    Assert-LastExitCode -Operation 'Token-service LiveKit SDK check'
    & $participantPython -c "from importlib.metadata import version; from livekit import api, rtc; assert version('livekit') == '1.1.13'; assert version('livekit-api') == '1.2.0'; assert hasattr(rtc, 'AudioSource') and hasattr(rtc, 'VideoSource') and hasattr(rtc, 'Room'); print('participant SDK ok')"
    Assert-LastExitCode -Operation 'Python-participant LiveKit SDK check'

    Write-Host '4/9 Native LiveKit and environment checks'
    if (-not (Test-Path .env)) {
        throw 'Missing .env. Run .\setup_phase1.ps1 first.'
    }
    if (-not (Test-Path $liveKitExecutable)) {
        throw 'Native LiveKit Server is not installed. Run .\setup_phase1.ps1 first.'
    }
    if (-not (Test-Path $runtimeConfigScript)) {
        throw 'Runtime LiveKit configuration generator is missing.'
    }
    & $liveKitExecutable --version
    Assert-LastExitCode -Operation 'LiveKit Server version check'

    $envValues = Import-DotEnvValues -Path '.env'
    foreach ($requiredName in @(
        'LIVEKIT_API_KEY',
        'LIVEKIT_API_SECRET',
        'LIVEKIT_NODE_IP',
        'LIVEKIT_PUBLIC_URL',
        'TOKEN_SERVICE_PUBLIC_URL',
        'ROOM_NAME',
        'PYTHON_PARTICIPANT_ID',
        'TOKEN_SERVICE_HOST',
        'TOKEN_SERVICE_PORT'
    )) {
        if (-not $envValues.ContainsKey($requiredName) -or -not $envValues[$requiredName]) {
            throw "Missing or empty $requiredName in .env."
        }
    }

    $nodeIp = [string]$envValues['LIVEKIT_NODE_IP']
    $parsedIp = $null
    if (-not [System.Net.IPAddress]::TryParse($nodeIp, [ref]$parsedIp)) {
        throw "LIVEKIT_NODE_IP is not a valid IP address: $nodeIp"
    }
    if ($nodeIp -like '127.*' -or $nodeIp -like '169.254.*') {
        throw "LIVEKIT_NODE_IP is not usable by a physical phone: $nodeIp"
    }

    $assignedAddress = Get-NetIPAddress -AddressFamily IPv4 -IPAddress $nodeIp -ErrorAction SilentlyContinue |
        Where-Object { -not $_.SkipAsSource } |
        Select-Object -First 1
    if (-not $assignedAddress) {
        throw "LIVEKIT_NODE_IP $nodeIp is not assigned to an active local interface. Re-run setup or use -LanIp."
    }

    try {
        $liveKitUri = [Uri]$envValues['LIVEKIT_PUBLIC_URL']
        $tokenUri = [Uri]$envValues['TOKEN_SERVICE_PUBLIC_URL']
    } catch {
        throw 'LIVEKIT_PUBLIC_URL or TOKEN_SERVICE_PUBLIC_URL is not a valid absolute URL.'
    }

    if (-not $liveKitUri.IsAbsoluteUri -or $liveKitUri.Scheme -notin @('ws', 'wss') -or $liveKitUri.Host -ne $nodeIp -or $liveKitUri.Port -ne 7880) {
        throw 'LIVEKIT_PUBLIC_URL must use LIVEKIT_NODE_IP and port 7880 with ws:// or wss://.'
    }
    if (-not $tokenUri.IsAbsoluteUri -or $tokenUri.Scheme -notin @('http', 'https') -or $tokenUri.Host -ne $nodeIp -or $tokenUri.Port -ne 8090) {
        throw 'TOKEN_SERVICE_PUBLIC_URL must use LIVEKIT_NODE_IP and port 8090.'
    }
    if ([string]$envValues['TOKEN_SERVICE_HOST'] -ne '0.0.0.0') {
        throw 'TOKEN_SERVICE_HOST must be 0.0.0.0 for physical-phone LAN access.'
    }
    if ([string]$envValues['TOKEN_SERVICE_PORT'] -ne '8090') {
        throw 'TOKEN_SERVICE_PORT must be 8090 for this Phase 1 spike.'
    }

    Write-Host '5/9 Windows Firewall rule checks'
    Assert-FirewallRule -DisplayName 'AI Teacher LiveKit Signaling' -Protocol 'TCP' -ExpectedPorts @('7880', '7881', '8090')
    Assert-FirewallRule -DisplayName 'AI Teacher LiveKit Media' -Protocol 'UDP' -ExpectedPorts @('50000-50020')

    Write-Host '6/9 Generated LiveKit credential synchronization check'
    New-Item -ItemType Directory -Path $runtimeDirectory -Force | Out-Null
    $validationConfigPath = Join-Path $runtimeDirectory 'validate-livekit.generated.yaml'
    $generatedConfigPath = & $runtimeConfigScript -EnvFile (Join-Path $root '.env') -OutputPath $validationConfigPath
    if (-not (Test-Path $generatedConfigPath)) {
        throw 'Runtime LiveKit configuration was not generated.'
    }
    $generatedConfig = Get-Content $generatedConfigPath -Raw
    $quotedApiKey = ConvertTo-Json -InputObject ([string]$envValues['LIVEKIT_API_KEY']) -Compress
    $quotedApiSecret = ConvertTo-Json -InputObject ([string]$envValues['LIVEKIT_API_SECRET']) -Compress
    if (-not $generatedConfig.Contains("${quotedApiKey}: ${quotedApiSecret}")) {
        throw 'Generated LiveKit config does not match LIVEKIT_API_KEY and LIVEKIT_API_SECRET.'
    }
    if (-not $generatedConfig.Contains('bind_addresses:') -or -not $generatedConfig.Contains('0.0.0.0')) {
        throw 'Generated LiveKit config is not bound for LAN access.'
    }
    Remove-Item $validationConfigPath -Force -ErrorAction SilentlyContinue

    Write-Host '7/9 Flutter Android manifest and SDK constraint checks'
    $manifestPath = Join-Path $root 'flutter_client\android\app\src\main\AndroidManifest.xml'
    if (-not (Test-Path $manifestPath)) {
        throw 'Flutter Android wrapper is missing. Run .\setup_phase1.ps1 first.'
    }
    $manifest = Get-Content $manifestPath -Raw
    foreach ($requiredManifestValue in @(
        'android.permission.INTERNET',
        'android.permission.ACCESS_NETWORK_STATE',
        'android.permission.CHANGE_NETWORK_STATE',
        'android.permission.CAMERA',
        'android.permission.RECORD_AUDIO',
        'android.permission.MODIFY_AUDIO_SETTINGS',
        'android.permission.BLUETOOTH_CONNECT',
        'android:usesCleartextTraffic="true"'
    )) {
        if (-not $manifest.Contains($requiredManifestValue)) {
            throw "AndroidManifest.xml is missing $requiredManifestValue. Re-run flutter_client\tool\bootstrap_android.ps1."
        }
    }

    $pubspec = Get-Content (Join-Path $root 'flutter_client\pubspec.yaml') -Raw
    if (-not $pubspec.Contains('sdk: ">=3.8.0 <4.0.0"')) {
        throw 'Flutter pubspec Dart SDK constraint must be >=3.8.0 for flutter_lints 6.0.0.'
    }

    Write-Host '8/9 Flutter dependency resolution and analysis'
    Push-Location flutter_client
    try {
        flutter pub get
        Assert-LastExitCode -Operation 'Flutter dependency resolution'
        flutter analyze
        Assert-LastExitCode -Operation 'Flutter static analysis'

        Write-Host '9/9 Flutter tests'
        flutter test
        Assert-LastExitCode -Operation 'Flutter tests'
    } finally {
        Pop-Location
    }

    Write-Host ''
    Write-Host 'Phase 1 pre-device validation passed.' -ForegroundColor Green
    Write-Host 'Docker is not required.'
    Write-Host 'This does not replace the physical Android media and reconnect tests.'
} finally {
    Pop-Location
}
