# PowerShell script to deploy and test all services (nginx + microservices + test-runner)
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Set-Location "$scriptDir\.."

Write-Host "[1/2] Building and starting all services (nginx + microservices + test-runner)..."
docker compose up --build -d

# Wait for containers to be healthy
Start-Sleep -Seconds 5

Write-Host "[2/2] Running health and routing tests..."
docker compose run --rm test-runner

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nAll services healthy and routing OK."
} else {
    Write-Host "`nSome tests failed. Check logs above."
}
