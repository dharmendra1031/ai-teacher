$ErrorActionPreference = 'Stop'

$phaseRoot = Split-Path -Parent $PSScriptRoot
$envExamplePath = Join-Path $phaseRoot '.env.example'
$envPath = Join-Path $phaseRoot '.env'

function Get-LanIpv4Address {
    $routes = Get-NetRoute \
        -AddressFamily IPv4 \
        -DestinationPrefix '0.0.0.0/0' \
        -ErrorAction SilentlyContinue |
        Sort-Object RouteMetric

    foreach ($route in $routes) {
        $address = Get-NetIPAddress \
            -AddressFamily IPv4 \
            -InterfaceIndex $route.InterfaceIndex \
            -ErrorAction SilentlyContinue |
            Where-Object {
                $_.IPAddress -notlike '127.*' -and
                $_.IPAddress -notlike '169.254.*'
            } |
            Select-Object -First 1

        if ($address) {
            return $address.IPAddress
        }
    }

    return $null
}

Write-Host 'AI Teacher Phase 1 — Windows setup without Docker' -ForegroundColor Cyan
Write-Host ''

& (Join-Path $PSScriptRoot 'install_livekit.ps1')

if (-not (Test-Path $envPath)) {
    $lanIp = Get-LanIpv4Address
    if (-not $lanIp) {
        $lanIp = Read-Host 'Enter the laptop IPv4 address shown by ipconfig'
    }

    if (-not $lanIp) {
        throw 'A LAN IPv4 address is required.'
    }

    $content = Get-Content $envExamplePath -Raw
    $content = $content.Replace('192.168.1.20', $lanIp)
    Set-Content -Path $envPath -Value $content -Encoding UTF8

    Write-Host ''
    Write-Host "Created .env with LAN IP $lanIp" -ForegroundColor Green
} else {
    Write-Host ''
    Write-Host '.env already exists; it was not overwritten.' -ForegroundColor Yellow
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$isAdministrator = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdministrator) {
    if (-not (Get-NetFirewallRule -DisplayName 'AI Teacher LiveKit Signaling' -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule \
            -DisplayName 'AI Teacher LiveKit Signaling' \
            -Direction Inbound \
            -Protocol TCP \
            -LocalPort 7880,7881,8090 \
            -Action Allow | Out-Null
    }

    if (-not (Get-NetFirewallRule -DisplayName 'AI Teacher LiveKit Media' -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule \
            -DisplayName 'AI Teacher LiveKit Media' \
            -Direction Inbound \
            -Protocol UDP \
            -LocalPort 50000-50020 \
            -Action Allow | Out-Null
    }

    Write-Host 'Windows Firewall rules are ready.' -ForegroundColor Green
} else {
    Write-Host ''
    Write-Host 'Firewall rules were not added because PowerShell is not running as Administrator.' -ForegroundColor Yellow
    Write-Host 'Run this same setup script once from an Administrator PowerShell window.'
}

Write-Host ''
Write-Host 'Setup complete.' -ForegroundColor Green
Write-Host 'Start LiveKit with:'
Write-Host 'powershell -ExecutionPolicy Bypass -File .\infrastructure\start_livekit.ps1'
