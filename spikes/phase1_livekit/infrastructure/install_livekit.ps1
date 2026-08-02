param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$version = '1.13.1'
$assetName = "livekit_${version}_windows_amd64.zip"
$releaseBaseUrl = "https://github.com/livekit/livekit/releases/download/v$version"
$downloadUrl = "$releaseBaseUrl/$assetName"
$checksumsUrl = "$releaseBaseUrl/checksums.txt"

$binDirectory = Join-Path $PSScriptRoot 'bin'
$executablePath = Join-Path $binDirectory 'livekit-server.exe'

if ((Test-Path $executablePath) -and -not $Force) {
    Write-Host 'LiveKit Server is already installed at:' -ForegroundColor Green
    Write-Host $executablePath
    & $executablePath --version
    exit 0
}

$tempDirectory = Join-Path $env:TEMP "ai-teacher-livekit-$version"
$archivePath = Join-Path $tempDirectory $assetName
$checksumsPath = Join-Path $tempDirectory 'checksums.txt'
$extractDirectory = Join-Path $tempDirectory 'extracted'

Remove-Item $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $tempDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $binDirectory -Force | Out-Null

try {
    Write-Host "Downloading LiveKit Server v$version for Windows..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath
    Invoke-WebRequest -Uri $checksumsUrl -OutFile $checksumsPath

    $checksumLine = Get-Content $checksumsPath |
        Where-Object { $_ -match [regex]::Escape($assetName) } |
        Select-Object -First 1

    if (-not $checksumLine) {
        throw "Checksum entry not found for $assetName."
    }

    $expectedChecksumMatch = [regex]::Match($checksumLine, '[A-Fa-f0-9]{64}')
    if (-not $expectedChecksumMatch.Success) {
        throw 'Could not parse the expected SHA-256 checksum.'
    }

    $expectedChecksum = $expectedChecksumMatch.Value.ToLowerInvariant()
    $actualChecksum = (Get-FileHash -Path $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()

    if ($actualChecksum -ne $expectedChecksum) {
        throw "LiveKit archive checksum mismatch. Expected $expectedChecksum but received $actualChecksum."
    }

    Expand-Archive -Path $archivePath -DestinationPath $extractDirectory -Force

    $downloadedExecutable = Get-ChildItem -Path $extractDirectory -Filter 'livekit-server.exe' -File -Recurse |
        Select-Object -First 1

    if (-not $downloadedExecutable) {
        throw 'livekit-server.exe was not found in the downloaded archive.'
    }

    Copy-Item $downloadedExecutable.FullName $executablePath -Force

    Write-Host ''
    Write-Host 'LiveKit Server installed successfully.' -ForegroundColor Green
    Write-Host $executablePath
    & $executablePath --version
} finally {
    Remove-Item $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue
}
