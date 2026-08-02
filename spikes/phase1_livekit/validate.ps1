$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$liveKitExecutable = Join-Path $root 'infrastructure\bin\livekit-server.exe'
Push-Location $root

try {
    Write-Host '1/4 Python syntax checks'
    py -3.12 -m py_compile token_service\server.py
    py -3.12 -m py_compile python_participant\participant.py

    Write-Host '2/4 Native LiveKit and environment checks'
    if (-not (Test-Path .env)) {
        throw 'Missing .env. Run .\infrastructure\setup_windows.ps1 first.'
    }
    if (-not (Test-Path $liveKitExecutable)) {
        throw 'Native LiveKit Server is not installed. Run .\infrastructure\setup_windows.ps1 first.'
    }
    & $liveKitExecutable --version
    if ($LASTEXITCODE -ne 0) {
        throw 'LiveKit Server version check failed.'
    }

    $envContent = Get-Content .env -Raw
    foreach ($requiredName in @(
        'LIVEKIT_API_KEY',
        'LIVEKIT_API_SECRET',
        'LIVEKIT_NODE_IP',
        'LIVEKIT_PUBLIC_URL',
        'TOKEN_SERVICE_PUBLIC_URL'
    )) {
        if ($envContent -notmatch "(?m)^$requiredName=.+$") {
            throw "Missing or empty $requiredName in .env."
        }
    }

    Write-Host '3/4 Flutter dependency resolution'
    Push-Location flutter_client
    try {
        flutter pub get

        Write-Host '4/4 Flutter static analysis and tests'
        flutter analyze
        flutter test
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
