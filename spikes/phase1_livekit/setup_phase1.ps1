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

Write-Host 'AI Teacher Phase 1 setup — native Windows, no Docker' -ForegroundColor Cyan
Write-Host ''

Assert-Command -Name 'py'
if (-not $SkipFlutter) {
    Assert-Command -Name 'flutter'
    Assert-Command -Name 'git'
}

Write-Host '1/4 Preparing native LiveKit Server and local environment...'
& (Join-Path $root 'infrastructure\setup_windows.ps1')

Write-Host ''
Write-Host '2/4 Preparing development token service...'
$tokenPython = Join-Path $root 'token_service\.venv\Scripts\python.exe'
if (-not (Test-Path $tokenPython)) {
    py -3.12 -m venv (Join-Path $root 'token_service\.venv')
}
& $tokenPython -m pip install --upgrade pip
& $tokenPython -m pip install -r (Join-Path $root 'token_service\requirements.txt')

Write-Host ''
Write-Host '3/4 Preparing Python test participant...'
$participantPython = Join-Path $root 'python_participant\.venv\Scripts\python.exe'
if (-not (Test-Path $participantPython)) {
    py -3.12 -m venv (Join-Path $root 'python_participant\.venv')
}
& $participantPython -m pip install --upgrade pip
& $participantPython -m pip install -r (Join-Path $root 'python_participant\requirements.txt')

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
        } finally {
            Pop-Location
        }
    }
}

Write-Host ''
Write-Host 'Phase 1 setup completed.' -ForegroundColor Green
Write-Host 'Next command:'
Write-Host 'powershell -ExecutionPolicy Bypass -File .\start_phase1.ps1'
