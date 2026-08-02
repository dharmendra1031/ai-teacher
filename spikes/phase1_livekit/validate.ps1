$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$liveKitExecutable = Join-Path $root 'infrastructure\bin\livekit-server.exe'
Push-Location $root

try {
    Write-Host '1/5 PowerShell syntax checks'
    $parseFailures = @()
    Get-ChildItem -Path $root -Filter '*.ps1' -File -Recurse | ForEach-Object {
        $tokens = $null
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile(
            $_.FullName,
            [ref]$tokens,
            [ref]$errors
        ) | Out-Null

        foreach ($parseError in $errors) {
            $parseFailures += (
                '{0}:{1}:{2} {3}' -f
                $_.FullName,
                $parseError.Extent.StartLineNumber,
                $parseError.Extent.StartColumnNumber,
                $parseError.Message
            )
        }
    }

    if ($parseFailures.Count -gt 0) {
        $parseFailures | ForEach-Object { Write-Host $_ -ForegroundColor Red }
        throw "PowerShell syntax validation failed with $($parseFailures.Count) error(s)."
    }

    Write-Host '2/5 Python syntax checks'
    py -3.12 -m py_compile token_service\server.py
    py -3.12 -m py_compile python_participant\participant.py

    Write-Host '3/5 Native LiveKit and environment checks'
    if (-not (Test-Path .env)) {
        throw 'Missing .env. Run .\setup_phase1.ps1 first.'
    }
    if (-not (Test-Path $liveKitExecutable)) {
        throw 'Native LiveKit Server is not installed. Run .\setup_phase1.ps1 first.'
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

    Write-Host '4/5 Flutter dependency resolution and analysis'
    Push-Location flutter_client
    try {
        flutter pub get
        flutter analyze

        Write-Host '5/5 Flutter tests'
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
