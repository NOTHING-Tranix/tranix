# Opens the backend (localhost:8080) to the internet through your fixed ngrok address, so testers on other
# networks can use the app. Needs in backend\.env:  NGROK_AUTHTOKEN=...  and  NGROK_DOMAIN=...ngrok-free.dev
# Start the backend first (tools\backend-dev.ps1), then run this in another window. Ctrl+C closes the tunnel.
$dotenv = Join-Path $PSScriptRoot '..\backend\.env'
$cfg = @{}
if (Test-Path $dotenv) {
    foreach ($line in Get-Content $dotenv) {
        $t = $line.Trim()
        if (-not $t -or $t.StartsWith('#') -or -not $t.Contains('=')) { continue }
        $i = $t.IndexOf('=')
        $cfg[$t.Substring(0, $i).Trim()] = $t.Substring($i + 1).Trim().Trim('"').Trim("'")
    }
}
if (-not $cfg.NGROK_AUTHTOKEN -or -not $cfg.NGROK_DOMAIN) {
    Write-Host 'Add NGROK_AUTHTOKEN and NGROK_DOMAIN to backend\.env first (see docs\friends-testing.md).'
    exit 1
}
if (-not (Get-Command ngrok -ErrorAction SilentlyContinue)) {
    Write-Host 'ngrok is not installed. Install it with:  winget install ngrok.ngrok   then open a new window.'
    exit 1
}
try { Invoke-WebRequest -UseBasicParsing 'http://localhost:8080/actuator/health' -TimeoutSec 5 | Out-Null }
catch { Write-Host 'The backend is not running on localhost:8080. Start tools\backend-dev.ps1 first.'; exit 1 }

$domain = $cfg.NGROK_DOMAIN -replace '^https?://', '' -replace '/.*$', ''
Write-Host ''
Write-Host "Public server address for the app:  $domain"
Write-Host "Swagger (admin):                     https://$domain/swagger-ui.html"
Write-Host 'Leave this window open while people are testing. Ctrl+C to stop.'
Write-Host ''
$env:NGROK_AUTHTOKEN = $cfg.NGROK_AUTHTOKEN
ngrok http 8080 --url "https://$domain"
