param(
    [Parameter(Position = 0)]
    [ValidateSet('setup', 'check', 'test', 'up', 'down', 'reset')]
    [string]$Command = 'check'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$composeFile = Join-Path $root 'infrastructure\compose.yaml'
$envExample = Join-Path $root '.env.example'
$envFile = Join-Path $root '.env'

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' is not installed or not on PATH."
    }
}

function Assert-NativeSuccess([string]$Label) {
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed with exit code $LASTEXITCODE."
    }
}

function Invoke-PythonTests {
    Push-Location (Join-Path $root 'backend')
    try {
        py -3.12 -m unittest discover -s tests -v
        Assert-NativeSuccess 'Backend tests'
    } finally { Pop-Location }
    Push-Location (Join-Path $root 'realtime_agent')
    try {
        py -3.12 -m unittest discover -s tests -v
        Assert-NativeSuccess 'Realtime-agent tests'
    } finally { Pop-Location }
}

switch ($Command) {
    'setup' {
        if (-not (Test-Path $envFile)) {
            Copy-Item $envExample $envFile
            Write-Host 'Created .env. Replace every change-this value before starting Compose.'
        }
        Push-Location (Join-Path $root 'mobile_app')
        try {
            flutter pub get
            Assert-NativeSuccess 'Flutter dependency installation'
        } finally { Pop-Location }
    }
    'check' {
        Require-Command flutter
        py -3.12 --version
        Assert-NativeSuccess 'Python version check'
        flutter --version
        Assert-NativeSuccess 'Flutter version check'
        if (Get-Command docker -ErrorAction SilentlyContinue) {
            docker compose --env-file $envExample -f $composeFile config --quiet
            Assert-NativeSuccess 'Compose configuration validation'
        } else {
            Write-Warning 'Docker is unavailable; Compose runtime/config verification was skipped.'
        }
    }
    'test' {
        Invoke-PythonTests
        Push-Location (Join-Path $root 'mobile_app')
        try {
            dart format --output=none --set-exit-if-changed .
            Assert-NativeSuccess 'Dart format check'
            flutter analyze
            Assert-NativeSuccess 'Flutter analysis'
            flutter test
            Assert-NativeSuccess 'Flutter tests'
        } finally { Pop-Location }
    }
    'up' {
        Require-Command docker
        if (-not (Test-Path $envFile)) { throw 'Missing .env. Run .\scripts\dev.ps1 setup first.' }
        docker compose --env-file $envFile -f $composeFile up --build -d --wait
        Assert-NativeSuccess 'Compose startup'
    }
    'down' {
        Require-Command docker
        docker compose --env-file $envFile -f $composeFile down
        Assert-NativeSuccess 'Compose shutdown'
    }
    'reset' {
        Require-Command docker
        $resolvedRoot = [System.IO.Path]::GetFullPath($root)
        if (-not (Test-Path (Join-Path $resolvedRoot '.git'))) {
            throw "Refusing reset because repository root validation failed: $resolvedRoot"
        }
        docker compose --env-file $envFile -f $composeFile down --volumes --remove-orphans
        Assert-NativeSuccess 'Compose reset'
    }
}
