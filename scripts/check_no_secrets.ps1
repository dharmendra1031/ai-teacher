$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$trackedFiles = git -C $root ls-files --cached --others --exclude-standard
$patterns = @(
    '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----',
    'sk-[A-Za-z0-9]{20,}',
    'AKIA[0-9A-Z]{16}',
    '(?i)(api_secret|password)\s*=\s*["''][^"'']{8,}["'']'
)

$violations = @()
foreach ($relativePath in $trackedFiles) {
    $path = Join-Path $root $relativePath
    if (-not (Test-Path $path -PathType Leaf)) { continue }
    $content = Get-Content $path -Raw -ErrorAction SilentlyContinue
    foreach ($pattern in $patterns) {
        if ($content -match $pattern -and $relativePath -notlike '*.example') {
            $violations += "$relativePath matched $pattern"
        }
    }
}

if ($violations.Count -gt 0) {
    $violations | ForEach-Object { Write-Error $_ }
    exit 1
}
Write-Host 'No high-confidence secret patterns found in tracked files.'
