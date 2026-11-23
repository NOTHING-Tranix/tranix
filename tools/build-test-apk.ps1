# Builds the testing APK that talks to your ngrok address (NGROK_DOMAIN in backend\.env) and copies it to
# Downloads\Tranix-test.apk, ready to send on WhatsApp/Drive. Testers can still change the server address on the
# Welcome screen ("Server") if it ever changes.
$dotenv = Join-Path $PSScriptRoot '..\backend\.env'
$domain = $null
if (Test-Path $dotenv) {
    foreach ($line in Get-Content $dotenv) {
        if ($line.Trim().StartsWith('NGROK_DOMAIN=')) { $domain = $line.Trim().Substring(13).Trim().Trim('"') -replace '^https?://', '' -replace '/.*$', '' }
    }
}
if (-not $domain) { Write-Host 'Add NGROK_DOMAIN=...ngrok-free.dev to backend\.env first.'; exit 1 }

Set-Location (Join-Path $PSScriptRoot '..\frontend')
flutter pub get | Out-Null  # packages must be downloaded on this machine
Write-Host "Building the testing APK for https://$domain (takes a few minutes)..."
flutter build apk --release "--dart-define=API_BASE_URL=https://$domain/api/v1"
if ($LASTEXITCODE -ne 0) { Write-Host 'Build failed.'; exit 1 }
$out = Join-Path $env:USERPROFILE 'Downloads\Tranix-test.apk'
Copy-Item 'build\app\outputs\flutter-apk\app-dev-release.apk' $out -Force
Write-Host ''
Write-Host "Done: $out"
Write-Host 'Send this file to your testers (WhatsApp as a document, or Google Drive).'
