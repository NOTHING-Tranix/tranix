# Quick check of a running dev backend: health, address search (OpenStreetMap), a sign-in OTP SMS (Twilio) and
# sign-in with the dev code. Usage: powershell -ExecutionPolicy Bypass -File tools\smoke-test.ps1
$api = 'http://localhost:8080/api/v1'
function Step($name, $block) {
    try { $r = & $block; Write-Host "OK   $name $r" } catch { Write-Host "FAIL $name : $($_.Exception.Message)" }
}
Step 'health' { (Invoke-RestMethod 'http://localhost:8080/actuator/health').status }
Step 'OTP SMS to 9000000001 (check your phone)' {
    Invoke-RestMethod -Method Post "$api/auth/otp/send" -ContentType 'application/json' -Body '{"mobile":"9000000001","purpose":"SIGN_IN"}' | Out-Null
    'sent'
}
$token = $null
Step 'sign in with 123456' {
    $res = Invoke-RestMethod -Method Post "$api/auth/sign-in" -ContentType 'application/json' -Body '{"mobile":"9000000001","otp":"123456","deviceId":"smoke"}'
    $script:token = $res.accessToken
    "as $($res.user.name) ($($res.user.role))"
}
Step 'address search (OpenStreetMap)' {
    $h = Invoke-RestMethod "$api/map/geocode?q=Koyambedu" -Headers @{ Authorization = "Bearer $script:token" }
    "$(@($h).Count) results, first: $(@($h)[0].name)"
}
