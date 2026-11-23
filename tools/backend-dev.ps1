# Starts the backend for dev testing with the real services that are set up:
#   SMS by Twilio, push by Firebase, free maps (OSRM routes + OpenStreetMap search).
# Secrets are NOT in this file. Set them once as Windows user environment variables (see docs/dev-testing.md):
#   TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM, SMS_REDIRECT_TO, FCM_SERVICE_ACCOUNT_FILE
# Usage:  powershell -ExecutionPolicy Bypass -File tools\backend-dev.ps1          (needs PostgreSQL running)
#         add -RandomOtp to send real random OTPs by SMS instead of the fixed dev code 123456
param([switch]$RandomOtp)

function UserVar($name) { [Environment]::GetEnvironmentVariable($name, 'User') }

$env:JAVA_HOME = 'C:\Users\shero\.jdks\openjdk-21.0.2'
foreach ($n in 'TWILIO_ACCOUNT_SID', 'TWILIO_AUTH_TOKEN', 'TWILIO_FROM', 'SMS_REDIRECT_TO', 'FCM_SERVICE_ACCOUNT_FILE') {
    $v = UserVar $n
    if ($v) { Set-Item -Path "env:$n" -Value $v }
}

if ($env:TWILIO_ACCOUNT_SID -and $env:TWILIO_AUTH_TOKEN -and $env:TWILIO_FROM) {
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
    Write-Host 'OTP: fixed dev code 123456 (also sent by SMS)'
}

Set-Location (Join-Path $PSScriptRoot '..\backend')
& .\mvnw.cmd spring-boot:run '-Dspring-boot.run.profiles=dev' @extra
