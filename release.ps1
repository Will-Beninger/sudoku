# Release Script for Sudoku App

# 1. Extract version from pubspec.yaml
$pubspec = Get-Content pubspec.yaml
$versionLine = $pubspec | Where-Object { $_ -match "^version: (.+)" }
if ($versionLine -match "version: (.+)") {
    $version = $matches[1].Trim()
}
else {
    Write-Error "Could not find version in pubspec.yaml"
    exit 1
}

$tag = "v$version"
Write-Host "Preparing release for $tag..." -ForegroundColor Cyan

# Prepare Artifacts Directory
$artifactsDir = "release_artifacts"
if (-not (Test-Path $artifactsDir)) {
    New-Item -ItemType Directory -Force -Path $artifactsDir | Out-Null
    Write-Host "Created $artifactsDir directory."
}
else {
    Write-Host "Using existing $artifactsDir directory."
}

# --- WINDOWS ---
Write-Host "`n[Windows] Building binary..." -ForegroundColor Cyan
flutter build windows --release
if ($LASTEXITCODE -ne 0) { Write-Error "Windows build failed"; exit 1 }

$windowsBuildDir = "build\windows\x64\runner\Release"
$windowsZip = "$artifactsDir\sudoku_windows_$version.zip"
if (Test-Path $windowsZip) { Remove-Item $windowsZip }

Write-Host "[Windows] Archiving..." -ForegroundColor Cyan
Compress-Archive -Path "$windowsBuildDir\*" -DestinationPath $windowsZip -Force
Write-Host "[Windows] Artifact created: $windowsZip" -ForegroundColor Green

# --- ANDROID ---
Write-Host "`n[Android] Building APK..." -ForegroundColor Cyan
flutter build apk --release
if ($LASTEXITCODE -ne 0) { Write-Error "Android build failed"; exit 1 }

$apkSource = "build\app\outputs\flutter-apk\app-release.apk"
$apkDest = "$artifactsDir\sudoku_android_$version.apk"
Copy-Item $apkSource $apkDest -Force
Write-Host "[Android] Artifact created: $apkDest" -ForegroundColor Green

# --- WEB & DEPLOY ---
Write-Host "`n[Web] Building Web (Base URL: /sudoku/)..." -ForegroundColor Cyan
# Build with base-href for GitHub Pages
flutter build web --release --base-href "/sudoku/"
if ($LASTEXITCODE -ne 0) { Write-Error "Web build failed"; exit 1 }

$webBuildDir = "build\web"
$webZip = "$artifactsDir\sudoku_web_$version.zip"
if (Test-Path $webZip) { Remove-Item $webZip }

Write-Host "[Web] Archiving..." -ForegroundColor Cyan
Compress-Archive -Path "$webBuildDir\*" -DestinationPath $webZip -Force
Write-Host "[Web] Artifact created: $webZip" -ForegroundColor Green

# Deploy to gh-pages
Write-Host "`n[Start Web Deployment] Pushing to gh-pages..." -ForegroundColor Yellow
$currentLocation = Get-Location
$remoteUrl = git remote get-url origin

# Push Main first (optional but good practice)
Write-Host "Pushing main branch..."
try { git push origin main } catch { Write-Warning "Failed to push main (might be up to date or auth issue)." }

# Deploy
try {
    Set-Location $webBuildDir
    
    if (Test-Path .git) { Remove-Item .git -Recurse -Force }
    git init
    git checkout -b gh-pages
    git add .
    git commit -m "Deploy Web Build $version"
    git remote add origin $remoteUrl
    
    git push -f origin gh-pages
    Write-Host "Deployed to gh-pages successfully!" -ForegroundColor Green
    Write-Host "App URL: https://Will-Beninger.github.io/sudoku/" -ForegroundColor Cyan
}
catch {
    Write-Error "Failed to deploy to gh-pages: $_"
}
finally {
    Set-Location $currentLocation
}


# --- TAGGING ---
Write-Host "`n[Git] Creating tag $tag..." -ForegroundColor Cyan
if (git rev-parse -q --verify "refs/tags/$tag") {
    Write-Host "Tag $tag already exists locally." -ForegroundColor Yellow
}
else {
    git tag -a $tag -m "Release $version"
    Write-Host "Tag created."
}
git push origin $tag


# --- RELEASE ---
if (Get-Command "gh" -ErrorAction SilentlyContinue) {
    Write-Host "`n[GitHub] Creating Draft Release..." -ForegroundColor Cyan
    
    # Collect all artifacts
    $files = Get-ChildItem "$artifactsDir\*" | Select-Object -ExpandProperty FullName
    
    # Create draft release
    gh release create $tag $files --title "Release $version" --generate-notes --draft
    
    Write-Host "GitHub Release draft created with artifacts!" -ForegroundColor Green
}
else {
    Write-Host "`n[GitHub] 'gh' CLI not found. Skipping upload." -ForegroundColor Yellow
    Write-Host "Please manually create release '$tag' and upload files from '$artifactsDir\'"
}

Write-Host "`nRelease process complete!" -ForegroundColor Green
