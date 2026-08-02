param(
    [switch]$SkipFlutter
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

function Assert-Command {
    param([Parameter(Mandatory = $true)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found in PATH."
    }
}

function Assert-LastExitCode {
    param([Parameter(Mandatory = $true)][string]$Operation)

    if ($LASTEXITCODE -ne 0) {
        throw "$Operation failed with exit code $LASTEXITCODE."
    }
}

Write-Host 'AI Teacher Phase 1 setup — native Windows, no Docker' -ForegroundColor Cyan
Write-Host ''

Assert-Command -Name 'py'
py -3.12 --version
Assert-LastExitCode -Operation 'Python 3.12 check'

if (-not $SkipFlutter) {
    Assert-Command -Name 'flutter'
    Assert-Command -Name 'git'
    flutter --version
    Assert-LastExitCode -Operation 'Flutter check'
}

Write-Host '1/4 Preparing native LiveKit Server and local environment...'
& (Join-Path $root 'infrastructure\setup_windows.ps1')

Write-Host ''
Write-Host '2/4 Preparing development token service...'
$tokenVenv = Join-Path $root 'token_service\.venv'
$tokenPython = Join-Path $tokenVenv 'Scripts\python.exe'
if (-not (Test-Path $tokenPython)) {
    py -3.12 -m venv $tokenVenv
    Assert-LastExitCode -Operation 'Token-service virtual environment creation'
}
& $tokenPython -m pip install --upgrade pip
Assert-LastExitCode -Operation 'Token-service pip upgrade'
& $tokenPython -m pip install -r (Join-Path $root 'token_service\requirements.txt')
Assert-LastExitCode -Operation 'Token-service dependency installation'

Write-Host ''
Write-Host '3/4 Preparing Python test participant...'
$participantVenv = Join-Path $root 'python_participant\.venv'
$participantPython = Join-Path $participantVenv 'Scripts\python.exe'
if (-not (Test-Path $participantPython)) {
    py -3.12 -m venv $participantVenv
    Assert-LastExitCode -Operation 'Python-participant virtual environment creation'
}
& $participantPython -m pip install --upgrade pip
Assert-LastExitCode -Operation 'Python-participant pip upgrade'
& $participantPython -m pip install -r (Join-Path $root 'python_participant\requirements.txt')
Assert-LastExitCode -Operation 'Python-participant dependency installation'

Write-Host ''
if ($SkipFlutter) {
    Write-Host '4/4 Flutter setup skipped by request.' -ForegroundColor Yellow
} else {
    Write-Host '4/4 Preparing Flutter physical-device client...'
    $flutterRoot = Join-Path $root 'flutter_client'
    $androidDirectory = Join-Path $flutterRoot 'android'
    if (-not (Test-Path $androidDirectory)) {
        & (Join-Path $flutterRoot 'tool\bootstrap_android.ps1')
    } else {
        Push-Location $flutterRoot
        try {
            flutter pub get
            Assert-LastExitCode -Operation 'Flutter dependency installation'
        } finally {
            Pop-Location
        }
    }
}

Write-Host ''
Write-Host 'Phase 1 setup completed.' -ForegroundColor Green
Write-Host 'Next command:'
Write-Host 'powershell -ExecutionPolicy Bypass -File .\validate.ps1'
