# Script to automatically install APK when Android device is connected

Write-Host "Waiting for Android device to be connected..." -ForegroundColor Yellow
Write-Host "Please connect your phone via USB and enable USB debugging" -ForegroundColor Cyan
Write-Host ""

$maxAttempts = 30
$attempt = 0

while ($attempt -lt $maxAttempts) {
    $devices = flutter devices 2>&1 | Select-String -Pattern "android|device"
    
    if ($devices -match "android") {
        Write-Host "Device detected! Installing APK..." -ForegroundColor Green
        flutter install
        Write-Host ""
        Write-Host "Installation complete! Check your phone." -ForegroundColor Green
        exit 0
    }
    
    Start-Sleep -Seconds 2
    $attempt++
    Write-Host "." -NoNewline -ForegroundColor Gray
}

Write-Host ""
Write-Host "No device detected after $maxAttempts attempts." -ForegroundColor Red
Write-Host ""
Write-Host "Manual installation:" -ForegroundColor Yellow
Write-Host "1. Copy: build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor White
Write-Host "2. Transfer to your phone and install manually" -ForegroundColor White





