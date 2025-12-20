# Script to download ngrok for Windows
# This downloads the actual ngrok executable (not the Windows Store version)

$ngrokUrl = "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip"
$zipFile = "ngrok.zip"
$extractPath = "."

Write-Host "Downloading ngrok..." -ForegroundColor Green

try {
    Invoke-WebRequest -Uri $ngrokUrl -OutFile $zipFile
    Write-Host "Extracting ngrok..." -ForegroundColor Green
    
    # Extract using built-in PowerShell
    Expand-Archive -Path $zipFile -DestinationPath $extractPath -Force
    
    # Remove zip file
    Remove-Item $zipFile
    
    Write-Host ""
    Write-Host "ngrok downloaded successfully!" -ForegroundColor Green
    Write-Host "You can now run: .\ngrok.exe http 5000" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "Error downloading ngrok: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: Use serveo.net (no download needed)" -ForegroundColor Yellow
    Write-Host "Run: .\start_backend_public.ps1" -ForegroundColor Cyan
}





