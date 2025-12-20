# GlucoGuard Project Runner
# This script helps you run the GlucoGuard project

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   GlucoGuard Project Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Python is installed
$pythonCheck = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCheck) {
    Write-Host "ERROR: Python is not installed or not in PATH!" -ForegroundColor Red
    exit 1
}

# Check if Flutter is installed
$flutterCheck = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCheck) {
    Write-Host "ERROR: Flutter is not installed or not in PATH!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Python found: $(python --version)" -ForegroundColor Green
Write-Host "✓ Flutter found: $(flutter --version | Select-Object -First 1)" -ForegroundColor Green
Write-Host ""

# Check if model file exists
if (-not (Test-Path "diabetesModel.pkl")) {
    Write-Host "WARNING: diabetesModel.pkl not found!" -ForegroundColor Yellow
    Write-Host "The backend may not work properly without the model file." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Starting Flask backend on port 5000..." -ForegroundColor Green
Write-Host "Backend will be available at: http://localhost:5000" -ForegroundColor Cyan
Write-Host ""
Write-Host "To test the backend, open another terminal and run:" -ForegroundColor Yellow
Write-Host "  curl http://localhost:5000/ping" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Ctrl+C to stop the backend" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Start the Flask backend
python backend.py

