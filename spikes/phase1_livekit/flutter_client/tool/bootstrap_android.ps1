$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot

try {
    flutter create --platforms=android --org com.aiteacher.phase1 --project-name ai_teacher_phase1_livekit .

    git restore --source=HEAD -- `
        pubspec.yaml `
        lib `
        tool

    $manifestPath = Join-Path $projectRoot 'android\app\src\main\AndroidManifest.xml'
    $manifest = Get-Content $manifestPath -Raw

    $permissions = @"
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
"@

    if ($manifest -notmatch 'android.permission.RECORD_AUDIO') {
        $manifest = $manifest -replace '<application', "$permissions`r`n    <application"
    }

    if ($manifest -notmatch 'usesCleartextTraffic') {
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
