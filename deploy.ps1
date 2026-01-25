$ErrorActionPreference = "Stop"

# Build the project web version for release
Write-Host "Step 0: Building web version for release..." -ForegroundColor Yellow
flutter build web --release --base-href "/sudoku/"

Write-Host "Starting Sudoku Deployment..." -ForegroundColor Cyan

# Get Remote URL
$remoteUrl = git remote get-url origin
Write-Host "Detected Remote: $remoteUrl" -ForegroundColor Gray

# 1. Push Code to Main
Write-Host "Step 1: Pushing source code to main..." -ForegroundColor Yellow
try {
    git push origin main
}
catch {
    Write-Error "Failed to push to main. Please check your SSH keys or git credentials."
}

# 2. Deploy Web Build
Write-Host "Step 2: Preparing web deployment..." -ForegroundColor Yellow
$buildDir = Join-Path $PSScriptRoot "build\web"

if (-not (Test-Path $buildDir)) {
    Write-Error "Build directory not found at $buildDir. Please run 'flutter build web --release' first."
}

Set-Location $buildDir

# Initialize temp git repo for deployment
if (Test-Path .git) {
    Remove-Item .git -Recurse -Force
}
git init
git checkout -b gh-pages
git add .
git commit -m "Deploy Web Build"
git remote add origin $remoteUrl

Write-Host "Step 3: Pushing to gh-pages..." -ForegroundColor Yellow
try {
    git push -f origin gh-pages
    Write-Host "Deployment Complete!" -ForegroundColor Green
    Write-Host "Your app should be live shortly at: https://Will-Beninger.github.io/sudoku/" -ForegroundColor Cyan
}
catch {
    Write-Error "Failed to push to gh-pages. Please check your SSH keys."
}
