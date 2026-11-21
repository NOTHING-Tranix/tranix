# Starts the Tranix emulator (if needed) and runs the app on it.
# Usage:  powershell -ExecutionPolicy Bypass -File tools\run-emulator.ps1            (fake data)
#         powershell -ExecutionPolicy Bypass -File tools\run-emulator.ps1 -Backend   (local backend on :8080)
#         add -Clean once after moving machines/folders (rebuilds packages from scratch)
#         add -DebugMode for hot reload (slower to start on this PC; release starts fastest)
param([switch]$Backend, [switch]$Clean, [switch]$DebugMode)

$sdk = 'C:\Users\shero\dev\android-sdk'
$adb = "$sdk\platform-tools\adb.exe"
$env:ANDROID_HOME = $sdk

$running = & $adb devices | Select-String 'emulator-\d+\s+device'
$tranix = $null
foreach ($line in $running) {
    $id = ($line -split '\s+')[0]
    $name = (& $adb -s $id shell getprop ro.boot.qemu.avd_name 2>$null)
    if ("$name".Trim() -eq 'tranix_api36') { $tranix = $id }
}
if (-not $tranix) {
    Write-Host 'Starting the emulator (first boot can take 1-2 minutes)...'
    Start-Process -FilePath "$sdk\emulator\emulator.exe" -ArgumentList '-avd', 'tranix_api36', '-no-snapshot-load'
    for ($i = 0; $i -lt 120 -and -not $tranix; $i++) {
        Start-Sleep -Seconds 3
        foreach ($line in (& $adb devices | Select-String 'emulator-\d+\s+device')) {
            $id = ($line -split '\s+')[0]
            if ("$(& $adb -s $id shell getprop ro.boot.qemu.avd_name 2>$null)".Trim() -eq 'tranix_api36' -and
                "$(& $adb -s $id shell getprop sys.boot_completed 2>$null)".Trim() -eq '1') { $tranix = $id }
        }
    }
}
if (-not $tranix) { Write-Host 'Emulator did not start.'; exit 1 }
Write-Host "Emulator ready: $tranix"

Set-Location (Join-Path $PSScriptRoot '..\frontend')
if ($Clean) { flutter clean; flutter pub get }
$mode = if ($DebugMode) { '--debug' } else { '--release' }
if ($Backend) {
    flutter run $mode -d $tranix --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
} else {
    flutter run $mode -d $tranix --dart-define=USE_MOCK=true
}
