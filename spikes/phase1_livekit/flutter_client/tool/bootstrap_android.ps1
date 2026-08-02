$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot

try {
    flutter create --platforms=android --org com.aiteacher.phase1 --project-name ai_teacher_phase1_livekit .

    # flutter create generates a default widget test that references MyApp. Remove
    # generated tests and restore only the reviewed tests committed to this spike.
    $testDirectory = Join-Path $projectRoot 'test'
    Remove-Item $testDirectory -Recurse -Force -ErrorAction SilentlyContinue

    git restore --source=HEAD -- `
        pubspec.yaml `
        lib `
        test `
        tool

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

        $androidName = [regex]::Escape($nameMatch.Groups[1].Value)
        if ($manifest -notmatch "android:name=\"$androidName\"") {
            $missingDeclarations += "    $declaration"
        }
    }

    if ($missingDeclarations.Count -gt 0) {
        $declarationBlock = ($missingDeclarations -join "`r`n") + "`r`n"
        $manifest = $manifest -replace '<application', "$declarationBlock    <application"
    }

    if ($manifest -notmatch 'android:usesCleartextTraffic=') {
        $manifest = $manifest -replace '<application', '<application android:usesCleartextTraffic="true"'
    }

    Set-Content -Path $manifestPath -Value $manifest -Encoding UTF8

    flutter pub get

    Write-Host ''
    Write-Host 'Phase 1 Android client bootstrap complete.' -ForegroundColor Green
    Write-Host 'Run flutter analyze, flutter test, then flutter run with TOKEN_SERVICE_URL.'
} finally {
    Pop-Location
}
