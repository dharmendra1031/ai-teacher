$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$liveKitExecutable = Join-Path $root 'infrastructure\bin\livekit-server.exe'
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

try {
    Write-Host '1/6 PowerShell syntax checks'
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

    Write-Host '2/6 Python 3.12 and syntax checks'
    if (-not (Get-Command py -ErrorAction SilentlyContinue)) {
        throw "Python launcher 'py' was not found in PATH."
    }
    py -3.12 --version
    Assert-LastExitCode -Operation 'Python 3.12 check'
    py -3.12 -m py_compile token_service\server.py
    Assert-LastExitCode -Operation 'Token-service Python syntax check'
    py -3.12 -m py_compile python_participant\participant.py
    Assert-LastExitCode -Operation 'Python-participant syntax check'

    Write-Host '3/6 Native LiveKit and environment checks'
    if (-not (Test-Path .env)) {
        throw 'Missing .env. Run .\setup_phase1.ps1 first.'
    }
    if (-not (Test-Path $liveKitExecutable)) {
        throw 'Native LiveKit Server is not installed. Run .\setup_phase1.ps1 first.'
    }
    & $liveKitExecutable --version
    Assert-LastExitCode -Operation 'LiveKit Server version check'

    $envValues = Import-DotEnvValues -Path '.env'
    foreach ($requiredName in @(
        'LIVEKIT_API_KEY',
        'LIVEKIT_API_SECRET',
        'LIVEKIT_NODE_IP',
        'LIVEKIT_PUBLIC_URL',
        'TOKEN_SERVICE_PUBLIC_URL'
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

    Write-Host '4/6 Flutter Android manifest checks'
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

    Write-Host '5/6 Flutter dependency resolution and analysis'
    Push-Location flutter_client
    try {
        flutter pub get
        Assert-LastExitCode -Operation 'Flutter dependency resolution'
        flutter analyze
        Assert-LastExitCode -Operation 'Flutter static analysis'

        Write-Host '6/6 Flutter tests'
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
