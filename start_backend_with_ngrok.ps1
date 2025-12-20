# Script to start Flask backend and expose it via ngrok for mobile data access
# Make sure ngrok is installed: https://ngrok.com/download

Write-Host "Starting Flask backend..." -ForegroundColor Green
Start-Process python -ArgumentList "backend.py" -WindowStyle Minimized

Start-Sleep -Seconds 3

Write-Host "Checking if ngrok is installed..." -ForegroundColor Yellow
$ngrokPath = Get-Command ngrok -ErrorAction SilentlyContinue

if ($ngrokPath) {
    Write-Host "Starting ngrok tunnel on port 5000..." -ForegroundColor Green
    Write-Host "Your public URL will be displayed below. Copy it and update assets/config.json" -ForegroundColor Cyan
    Write-Host "Set 'backend_url_public' to: https://YOUR-NGROK-URL" -ForegroundColor Cyan
    Write-Host ""
    ngrok http 5000
} else {
    Write-Host "ngrok is not installed!" -ForegroundColor Red
    Write-Host "Please install ngrok from: https://ngrok.com/download" -ForegroundColor Yellow
    Write-Host "Or use an alternative like localtunnel, serveo, etc." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Backend is running on http://localhost:5000" -ForegroundColor Green
    Write-Host "For mobile data access, you need a public URL." -ForegroundColor Yellow
}





