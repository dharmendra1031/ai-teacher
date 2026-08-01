$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $root

try {
    Write-Host '1/4 Python syntax checks'
    py -3.12 -m py_compile token_service\server.py
    py -3.12 -m py_compile python_participant\participant.py

    Write-Host '2/4 Docker Compose validation'
    if (-not (Test-Path .env)) {
        throw 'Missing .env. Copy .env.example to .env and set the laptop LAN IP.'
    }
    docker compose --env-file .env -f infrastructure\docker-compose.yml config | Out-Null

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
    Write-Host 'This does not replace the physical Android media and reconnect tests.'
} finally {
    Pop-Location
}
