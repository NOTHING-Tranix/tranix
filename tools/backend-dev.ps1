# Starts the backend for dev testing with the real services that are set up:
#   SMS by Twilio, push by Firebase, free maps (OSRM routes + OpenStreetMap search).
# Secrets are NOT in this file. Set them once as Windows user environment variables (see docs/dev-testing.md):
#   TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM, SMS_REDIRECT_TO, FCM_SERVICE_ACCOUNT_FILE
# Usage:  powershell -ExecutionPolicy Bypass -File tools\backend-dev.ps1          (needs PostgreSQL running)
#         SMS is OFF by default (saves Twilio credit; the dev OTP is always 123456).
#         add -Sms to send real SMS through Twilio (OTPs, tracking links, notifications)
#         add -RandomOtp to send real random OTPs by SMS instead of the fixed dev code 123456 (turns -Sms on)
param([switch]$Sms, [switch]$RandomOtp)
if ($RandomOtp) { $Sms = $true }

function UserVar($name) { [Environment]::GetEnvironmentVariable($name, 'User') }

$env:JAVA_HOME = 'C:\Users\shero\.jdks\openjdk-21.0.2'
foreach ($n in 'TWILIO_ACCOUNT_SID', 'TWILIO_AUTH_TOKEN', 'TWILIO_FROM', 'SMS_REDIRECT_TO', 'FCM_SERVICE_ACCOUNT_FILE') {
    $v = UserVar $n
    if ($v) { Set-Item -Path "env:$n" -Value $v }
}

# backend\.env (not in git) wins over the user variables: KEY=VALUE per line, # for comments. See backend\.env.example.
$dotenv = Join-Path $PSScriptRoot '..\backend\.env'
if (Test-Path $dotenv) {
    foreach ($line in Get-Content $dotenv) {
        $t = $line.Trim()
        if (-not $t -or $t.StartsWith('#') -or -not $t.Contains('=')) { continue }
        $i = $t.IndexOf('=')
        $key = $t.Substring(0, $i).Trim()
        $val = $t.Substring($i + 1).Trim().Trim('"').Trim("'")
        if ($key -and $val) { Set-Item -Path "env:$key" -Value $val }
    }
    Write-Host 'Loaded settings from backend\.env'
}

# With an ngrok domain, links the server hands out (SMS tracking links, file links, top-up pages) use the tunnel.
if ($env:NGROK_DOMAIN -and -not $env:PUBLIC_BASE_URL) {
    $env:PUBLIC_BASE_URL = 'https://' + ($env:NGROK_DOMAIN -replace '^https?://', '' -replace '/.*$', '')
}
if ($env:PUBLIC_BASE_URL) { Write-Host "Public links: $($env:PUBLIC_BASE_URL)" }
Remove-Item Env:NGROK_AUTHTOKEN -ErrorAction SilentlyContinue  # only the tunnel needs it

if (-not $Sms) {
    $env:SMS_PROVIDER = 'fake'
    Write-Host 'SMS: off - nothing is sent (use -Sms to send real SMS through Twilio)'
} elseif ($env:TWILIO_ACCOUNT_SID -and $env:TWILIO_AUTH_TOKEN -and $env:TWILIO_FROM) {
    $env:SMS_PROVIDER = 'twilio'
    if ($env:SMS_REDIRECT_TO) { Write-Host "SMS: Twilio - every SMS goes to the testing number (SMS_REDIRECT_TO)" }
    else { Write-Host 'SMS: Twilio - sent to the real recipients' }
} else {
    Write-Host 'SMS: fake (set TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM to use Twilio)'
}
if ($env:FCM_SERVICE_ACCOUNT_FILE -and (Test-Path $env:FCM_SERVICE_ACCOUNT_FILE)) {
    $env:PUSH_PROVIDER = 'fcm'
    Write-Host 'Push: Firebase'
} else {
    Write-Host 'Push: off (set FCM_SERVICE_ACCOUNT_FILE to the Firebase service-account key file)'
}
Write-Host 'Maps: free (OSRM routes, OpenStreetMap search)'
$extra = @()
if ($RandomOtp) {
    # an empty tranix.dev.otp turns the fixed code off (setting an env var to '' would delete it in PowerShell)
    $extra = @('-Dspring-boot.run.arguments=--tranix.dev.otp=')
    Write-Host 'OTP: random codes by SMS'
} else {
    Write-Host 'OTP: fixed dev code 123456'
}

Set-Location (Join-Path $PSScriptRoot '..\backend')
& .\mvnw.cmd spring-boot:run '-Dspring-boot.run.profiles=dev' @extra
