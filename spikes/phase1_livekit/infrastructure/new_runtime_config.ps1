param(
    [string]$EnvFile = (Join-Path (Split-Path -Parent $PSScriptRoot) '.env'),
    [string]$OutputPath = (Join-Path (Split-Path -Parent $PSScriptRoot) '.runtime\livekit.generated.yaml')
)

$ErrorActionPreference = 'Stop'

function Import-DotEnv {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Missing environment file: $Path. Run setup_phase1.ps1 first."
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

function Write-Utf8WithoutBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $parent = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

Import-DotEnv -Path $EnvFile

foreach ($requiredName in @('LIVEKIT_API_KEY', 'LIVEKIT_API_SECRET')) {
    $value = [Environment]::GetEnvironmentVariable($requiredName, 'Process')
    if (-not $value) {
        throw "$requiredName is missing from $EnvFile."
    }
}

$apiKeyYaml = ConvertTo-Json -InputObject ([string]$env:LIVEKIT_API_KEY) -Compress
$apiSecretYaml = ConvertTo-Json -InputObject ([string]$env:LIVEKIT_API_SECRET) -Compress

$config = @"
port: 7880
bind_addresses:
  - 0.0.0.0

rtc:
  tcp_port: 7881
  port_range_start: 50000
  port_range_end: 50020
  use_external_ip: false

keys:
  ${apiKeyYaml}: ${apiSecretYaml}

logging:
  level: info
"@

$absoluteOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
Write-Utf8WithoutBom -Path $absoluteOutputPath -Content $config
Write-Output $absoluteOutputPath
