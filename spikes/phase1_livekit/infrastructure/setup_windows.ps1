$ErrorActionPreference = 'Stop'

$phaseRoot = Split-Path -Parent $PSScriptRoot
$envExamplePath = Join-Path $phaseRoot '.env.example'
$envPath = Join-Path $phaseRoot '.env'

function Get-LanIpv4Address {
    $routes = Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
        Sort-Object RouteMetric

    foreach ($route in $routes) {
        $address = Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $route.InterfaceIndex -ErrorAction SilentlyContinue |
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

function Set-EnvironmentValue {
    param(
        [Parameter(Mandatory = $true)][string]$Content,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $pattern = '(?m)^' + [regex]::Escape($Name) + '=.*$'
    if ($Content -match $pattern) {
        return [regex]::Replace($Content, $pattern, "$Name=$Value")
    }

    return $Content.TrimEnd() + "`r`n$Name=$Value`r`n"
}

function Write-Utf8WithoutBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

Write-Host 'AI Teacher Phase 1 — Windows setup without Docker' -ForegroundColor Cyan
Write-Host ''

& (Join-Path $PSScriptRoot 'install_livekit.ps1')

$lanIp = Get-LanIpv4Address
if (-not $lanIp) {
    $lanIp = Read-Host 'Enter the laptop IPv4 address shown by ipconfig'
}
if (-not $lanIp) {
    throw 'A LAN IPv4 address is required.'
}

if (Test-Path $envPath) {
    $content = Get-Content $envPath -Raw
    $content = Set-EnvironmentValue -Content $content -Name 'LIVEKIT_NODE_IP' -Value $lanIp
    $content = Set-EnvironmentValue -Content $content -Name 'LIVEKIT_PUBLIC_URL' -Value "ws://$lanIp`:7880"
    $content = Set-EnvironmentValue -Content $content -Name 'TOKEN_SERVICE_PUBLIC_URL' -Value "http://$lanIp`:8090"
    Write-Utf8WithoutBom -Path $envPath -Content $content

    Write-Host ''
    Write-Host "Refreshed LAN URLs in .env with IP $lanIp" -ForegroundColor Green
    Write-Host 'API key, secret and other settings were preserved.'
} else {
    $content = Get-Content $envExamplePath -Raw
    $content = $content.Replace('192.168.1.20', $lanIp)
    Write-Utf8WithoutBom -Path $envPath -Content $content

    Write-Host ''
    Write-Host "Created .env with LAN IP $lanIp" -ForegroundColor Green
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$isAdministrator = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdministrator) {
    if (-not (Get-NetFirewallRule -DisplayName 'AI Teacher LiveKit Signaling' -ErrorAction SilentlyContinue)) {
        $signalingRule = @{
            DisplayName = 'AI Teacher LiveKit Signaling'
            Direction   = 'Inbound'
            Protocol    = 'TCP'
            LocalPort   = 7880, 7881, 8090
            Action      = 'Allow'
        }
        New-NetFirewallRule @signalingRule | Out-Null
    }

    if (-not (Get-NetFirewallRule -DisplayName 'AI Teacher LiveKit Media' -ErrorAction SilentlyContinue)) {
        $mediaRule = @{
            DisplayName = 'AI Teacher LiveKit Media'
            Direction   = 'Inbound'
            Protocol    = 'UDP'
            LocalPort   = '50000-50020'
            Action      = 'Allow'
        }
        New-NetFirewallRule @mediaRule | Out-Null
    }

    Write-Host 'Windows Firewall rules are ready.' -ForegroundColor Green
} else {
    Write-Host ''
    Write-Host 'Firewall rules were not added because PowerShell is not running as Administrator.' -ForegroundColor Yellow
    Write-Host 'Run this same setup script once from an Administrator PowerShell window.'
}

Write-Host ''
Write-Host 'Setup complete.' -ForegroundColor Green
Write-Host "Detected LAN IP: $lanIp"
Write-Host 'Confirm this matches the active Wi-Fi IPv4 shown by ipconfig.'
Write-Host 'Next: powershell -ExecutionPolicy Bypass -File .\validate.ps1'
