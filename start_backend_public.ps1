# Script to start Flask backend and expose it via serveo (no installation needed)
# serveo.net is a free SSH tunnel service - no signup required!

Write-Host "Starting Flask backend..." -ForegroundColor Green
Start-Process python -ArgumentList "backend.py" -WindowStyle Minimized

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "Setting up public tunnel via serveo.net..." -ForegroundColor Green
Write-Host "This will create a public URL for your backend." -ForegroundColor Cyan
Write-Host ""
Write-Host "Your public URL will be displayed below." -ForegroundColor Yellow
Write-Host "Copy the 'Forwarding' URL (looks like https://xxxx.serveo.net:443)" -ForegroundColor Yellow
Write-Host "Then update assets/config.json with that URL in 'backend_url_public'" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C to stop the tunnel" -ForegroundColor Gray
Write-Host ""

# Use SSH to create tunnel via serveo (works on Windows 10/11 with OpenSSH)
ssh -R 80:localhost:5000 serveo.net





