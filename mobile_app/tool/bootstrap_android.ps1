$ErrorActionPreference = 'Stop'

$mobileAppPath = Split-Path -Parent $PSScriptRoot
Push-Location $mobileAppPath

try {
    Write-Host 'Generating the standard Flutter Android wrapper...'
    flutter create --platforms=android --org com.aiteacher --project-name ai_teacher .

    Write-Host 'Restoring reviewed source files after flutter create...'
    git restore --source=HEAD -- `
        .gitignore `
        pubspec.yaml `
        analysis_options.yaml `
        README.md `
        lib `
        test `
        tool

    Write-Host 'Installing Flutter packages...'
    flutter pub get

    Write-Host ''
    Write-Host 'Android bootstrap completed.' -ForegroundColor Green
    Write-Host 'Next: flutter analyze'
    Write-Host 'Then: flutter test'
} finally {
    Pop-Location
}
