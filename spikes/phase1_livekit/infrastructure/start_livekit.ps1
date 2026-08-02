param(
    [string]$EnvFile = (Join-Path (Split-Path -Parent $PSScriptRoot) '.env')
)

$ErrorActionPreference = 'Stop'

function Import-DotEnv {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Missing environment file: $Path. Run setup_windows.ps1 first."
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

Import-DotEnv -Path $EnvFile

$executablePath = Join-Path $PSScriptRoot 'bin\livekit-server.exe'
$configPath = Join-Path $PSScriptRoot 'livekit.yaml'
$nodeIp = $env:LIVEKIT_NODE_IP

if (-not (Test-Path $executablePath)) {
    throw 'LiveKit Server is not installed. Run .\infrastructure\setup_windows.ps1 first.'
}

if (-not $nodeIp) {
    throw 'LIVEKIT_NODE_IP is missing from .env.'
}

Write-Host ''
Write-Host 'Starting native LiveKit Server — no Docker required.' -ForegroundColor Green
Write-Host "LAN address: ws://$nodeIp`:7880"
Write-Host 'Press Ctrl+C in this window to stop LiveKit.'
Write-Host ''

& $executablePath --config $configPath --bind 0.0.0.0 --node-ip $nodeIp

if ($LASTEXITCODE -ne 0) {
    throw "LiveKit Server exited with code $LASTEXITCODE."
}
