# One-off fix (2026-11-21): the Android SDK had been installed into the Claude app's private AppData folder.
# It now lives in C:\Users\shero\dev\android-sdk; point the user environment and Flutter at it.
$sdk = 'C:\Users\shero\dev\android-sdk'
[Environment]::SetEnvironmentVariable('ANDROID_HOME', $sdk, 'User')
[Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT', $sdk, 'User')
$old = 'C:\Users\shero\AppData\Local\Android\Sdk'
$parts = [Environment]::GetEnvironmentVariable('Path', 'User') -split ';' | Where-Object { $_ -and -not $_.StartsWith($old) }
$parts += "$sdk\platform-tools", "$sdk\emulator", "$sdk\cmdline-tools\latest\bin"
[Environment]::SetEnvironmentVariable('Path', ($parts | Select-Object -Unique) -join ';', 'User')
$env:ANDROID_HOME = $sdk
& 'C:\Users\shero\dev\flutter\bin\flutter.bat' config --android-sdk $sdk
Write-Host 'User PATH now contains:'
[Environment]::GetEnvironmentVariable('Path', 'User') -split ';' | Select-String -Pattern 'android|flutter'
& "$sdk\emulator\emulator.exe" -list-avds
