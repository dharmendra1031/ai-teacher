param(
    [string]$LanIp
)

$ErrorActionPreference = 'Stop'

$phaseRoot = Split-Path -Parent $PSScriptRoot
$envExamplePath = Join-Path $phaseRoot '.env.example'
$envPath = Join-Path $phaseRoot '.env'
$signalingRuleName = 'AI Teacher LiveKit Signaling'
$mediaRuleName = 'AI Teacher LiveKit Media'

function Get-EnvironmentValue {
    param(
        [Parameter(Mandatory = $true)][string]$Content,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $match = [regex]::Match(
        $Content,
        '(?m)^' + [regex]::Escape($Name) + '=(.*)$'
    )
    if ($match.Success) {
        return $match.Groups[1].Value.Trim()
    }
    return $null
}

function Get-LanIpv4Candidates {
    $candidates = @()
    $physicalAdapters = @(
        Get-NetAdapter -Physical -ErrorAction SilentlyContinue |
            Where-Object { $_.Status -eq 'Up' }
    )

    foreach ($adapter in $physicalAdapters) {
        $interface = Get-NetIPInterface `
            -AddressFamily IPv4 `
            -InterfaceIndex $adapter.ifIndex `
            -ErrorAction SilentlyContinue |
            Select-Object -First 1
        $metric = if ($interface) { [int]$interface.InterfaceMetric } else { 9999 }

        $addresses = @(
            Get-NetIPAddress `
                -AddressFamily IPv4 `
                -InterfaceIndex $adapter.ifIndex `
                -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.IPAddress -notlike '127.*' -and
                    $_.IPAddress -notlike '169.254.*' -and
                    -not $_.SkipAsSource
                }
        )

        foreach ($address in $addresses) {
            $priority = if ($adapter.Name -match 'Wi-?Fi|Wireless|WLAN') {
                0
            } elseif ($adapter.Name -match 'Ethernet') {
                1
            } else {
                2
            }

            $candidates += [pscustomobject]@{
                IPAddress = $address.IPAddress
                InterfaceAlias = $adapter.Name
                Priority = $priority
                InterfaceMetric = $metric
            }
        }
    }

    if ($candidates.Count -eq 0) {
        $routes = Get-NetRoute `
            -AddressFamily IPv4 `
            -DestinationPrefix '0.0.0.0/0' `
            -ErrorAction SilentlyContinue |
            Sort-Object RouteMetric

        foreach ($route in $routes) {
            $address = Get-NetIPAddress `
                -AddressFamily IPv4 `
                -InterfaceIndex $route.InterfaceIndex `
                -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.IPAddress -notlike '127.*' -and
                    $_.IPAddress -notlike '169.254.*' -and
                    -not $_.SkipAsSource
                } |
                Select-Object -First 1

            if ($address) {
                $candidates += [pscustomobject]@{
                    IPAddress = $address.IPAddress
                    InterfaceAlias = $address.InterfaceAlias
                    Priority = 9
                    InterfaceMetric = [int]$route.RouteMetric
                }
            }
        }
    }

    return @(
        $candidates |
            Sort-Object Priority, InterfaceMetric, InterfaceAlias |
            Group-Object IPAddress |
            ForEach-Object { $_.Group | Select-Object -First 1 }
    )
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

function Test-UsableLanIp {
    param([Parameter(Mandatory = $true)][string]$Address)

    $parsed = $null
    if (-not [System.Net.IPAddress]::TryParse($Address, [ref]$parsed)) {
        return $false
    }
    return $Address -notlike '127.*' -and $Address -notlike '169.254.*'
}

Write-Host 'AI Teacher Phase 1 — Windows setup without Docker' -ForegroundColor Cyan
Write-Host ''

& (Join-Path $PSScriptRoot 'install_livekit.ps1')

$candidates = @(Get-LanIpv4Candidates)
$selectedCandidate = $null

if ($LanIp) {
    if (-not (Test-UsableLanIp -Address $LanIp)) {
        throw "-LanIp is not a usable IPv4 address: $LanIp"
    }
    $selectedCandidate = $candidates |
        Where-Object { $_.IPAddress -eq $LanIp } |
        Select-Object -First 1
} else {
    $existingIp = $null
    if (Test-Path $envPath) {
        $existingContent = Get-Content $envPath -Raw
        $existingIp = Get-EnvironmentValue -Content $existingContent -Name 'LIVEKIT_NODE_IP'
    }

    if ($existingIp) {
        $selectedCandidate = $candidates |
            Where-Object { $_.IPAddress -eq $existingIp } |
            Select-Object -First 1
    }

    if (-not $selectedCandidate -and $candidates.Count -gt 0) {
        $selectedCandidate = $candidates | Select-Object -First 1
    }
}

if ($LanIp) {
    $resolvedLanIp = $LanIp
    $interfaceName = if ($selectedCandidate) {
        $selectedCandidate.InterfaceAlias
    } else {
        'manually supplied address'
    }
} elseif ($selectedCandidate) {
    $resolvedLanIp = $selectedCandidate.IPAddress
    $interfaceName = $selectedCandidate.InterfaceAlias
} else {
    $resolvedLanIp = Read-Host 'Enter the laptop IPv4 address shown by ipconfig'
    $interfaceName = 'manual input'
}

if (-not $resolvedLanIp -or -not (Test-UsableLanIp -Address $resolvedLanIp)) {
    throw 'A usable LAN IPv4 address is required.'
}

if (Test-Path $envPath) {
    $content = Get-Content $envPath -Raw
    $content = Set-EnvironmentValue -Content $content -Name 'LIVEKIT_NODE_IP' -Value $resolvedLanIp
    $content = Set-EnvironmentValue -Content $content -Name 'LIVEKIT_PUBLIC_URL' -Value "ws://$resolvedLanIp`:7880"
    $content = Set-EnvironmentValue -Content $content -Name 'TOKEN_SERVICE_PUBLIC_URL' -Value "http://$resolvedLanIp`:8090"
    Write-Utf8WithoutBom -Path $envPath -Content $content

    Write-Host ''
    Write-Host "Refreshed LAN URLs in .env with IP $resolvedLanIp" -ForegroundColor Green
    Write-Host 'API key, secret and other settings were preserved.'
} else {
    $content = Get-Content $envExamplePath -Raw
    $content = $content.Replace('192.168.1.20', $resolvedLanIp)
    Write-Utf8WithoutBom -Path $envPath -Content $content

    Write-Host ''
    Write-Host "Created .env with LAN IP $resolvedLanIp" -ForegroundColor Green
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$isAdministrator = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$existingSignalingRule = Get-NetFirewallRule -DisplayName $signalingRuleName -ErrorAction SilentlyContinue
$existingMediaRule = Get-NetFirewallRule -DisplayName $mediaRuleName -ErrorAction SilentlyContinue

if ($isAdministrator) {
    @($existingSignalingRule) | Remove-NetFirewallRule -ErrorAction SilentlyContinue
    @($existingMediaRule) | Remove-NetFirewallRule -ErrorAction SilentlyContinue

    $signalingRule = @{
        DisplayName = $signalingRuleName
        Direction   = 'Inbound'
        Protocol    = 'TCP'
        LocalPort   = 7880, 7881, 8090
        Action      = 'Allow'
        Enabled     = 'True'
        Profile     = 'Any'
    }
    New-NetFirewallRule @signalingRule | Out-Null

    $mediaRule = @{
        DisplayName = $mediaRuleName
        Direction   = 'Inbound'
        Protocol    = 'UDP'
        LocalPort   = '50000-50020'
        Action      = 'Allow'
        Enabled     = 'True'
        Profile     = 'Any'
    }
    New-NetFirewallRule @mediaRule | Out-Null

    Write-Host 'Windows Firewall rules were recreated with the exact Phase 1 ports.' -ForegroundColor Green
} elseif (-not $existingSignalingRule -or -not $existingMediaRule) {
    throw 'Required Windows Firewall rules are missing. Run setup_phase1.ps1 once from an Administrator PowerShell window.'
} else {
    Write-Host ''
    Write-Host 'Existing Phase 1 firewall rules were found. Run as Administrator to recreate and refresh them.' -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Setup complete.' -ForegroundColor Green
Write-Host "Selected LAN IP: $resolvedLanIp"
Write-Host "Selected interface: $interfaceName"
Write-Host 'Confirm the phone and this interface are on the same local network.'
Write-Host 'To override detection: .\setup_phase1.ps1 -LanIp 192.168.x.x'
Write-Host 'Next: powershell -ExecutionPolicy Bypass -File .\validate.ps1'
