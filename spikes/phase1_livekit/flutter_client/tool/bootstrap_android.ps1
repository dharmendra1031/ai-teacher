$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot

function Assert-LastExitCode {
    param([Parameter(Mandatory = $true)][string]$Operation)

    if ($LASTEXITCODE -ne 0) {
        throw "$Operation failed with exit code $LASTEXITCODE."
    }
}

function Write-Utf8WithoutBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

Push-Location $projectRoot

try {
    flutter create --platforms=android --org com.aiteacher.phase1 --project-name ai_teacher_phase1_livekit .
    Assert-LastExitCode -Operation 'Flutter Android wrapper generation'

    # flutter create generates a default widget test that references MyApp. Remove
    # generated tests and restore only the reviewed tests committed to this spike.
    $testDirectory = Join-Path $projectRoot 'test'
    Remove-Item $testDirectory -Recurse -Force -ErrorAction SilentlyContinue

    git restore --source=HEAD -- `
        pubspec.yaml `
        lib `
        test `
        tool
    Assert-LastExitCode -Operation 'Reviewed Flutter source restoration'

    $manifestPath = Join-Path $projectRoot 'android\app\src\main\AndroidManifest.xml'
    $manifest = Get-Content $manifestPath -Raw

    $declarations = @(
        '<uses-feature android:name="android.hardware.camera" android:required="false" />',
        '<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />',
        '<uses-permission android:name="android.permission.INTERNET" />',
        '<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />',
        '<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />',
        '<uses-permission android:name="android.permission.CAMERA" />',
        '<uses-permission android:name="android.permission.RECORD_AUDIO" />',
        '<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />',
        '<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />',
        '<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />',
        '<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />'
    )

    $missingDeclarations = @()
    foreach ($declaration in $declarations) {
        $nameMatch = [regex]::Match($declaration, 'android:name="([^"]+)"')
        if (-not $nameMatch.Success) {
            continue
        }

        $needle = 'android:name="' + $nameMatch.Groups[1].Value + '"'
        if (-not $manifest.Contains($needle)) {
            $missingDeclarations += "    $declaration"
        }
    }

    if ($missingDeclarations.Count -gt 0) {
        $declarationBlock = ($missingDeclarations -join "`r`n") + "`r`n"
        $manifest = $manifest -replace '<application', "$declarationBlock    <application"
    }

    if ($manifest -match 'android:usesCleartextTraffic="[^"]*"') {
        $manifest = [regex]::Replace(
            $manifest,
            'android:usesCleartextTraffic="[^"]*"',
            'android:usesCleartextTraffic="true"',
            1
        )
    } else {
        $manifest = $manifest -replace '<application', '<application android:usesCleartextTraffic="true"'
    }

    Write-Utf8WithoutBom -Path $manifestPath -Content $manifest

    flutter pub get
    Assert-LastExitCode -Operation 'Flutter dependency installation'

    Write-Host ''
    Write-Host 'Phase 1 Android client bootstrap complete.' -ForegroundColor Green
    Write-Host 'Run flutter analyze, flutter test, then flutter run with TOKEN_SERVICE_URL.'
} finally {
    Pop-Location
}
