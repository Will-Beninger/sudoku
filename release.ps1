# Release Script for Sudoku App

# 1. Extract version from pubspec.yaml
$pubspec = Get-Content pubspec.yaml
$versionLine = $pubspec | Where-Object { $_ -match "^version: (.+)" }
if ($versionLine -match "version: (.+)") {
    $version = $matches[1].Trim()
} else {
    Write-Error "Could not find version in pubspec.yaml"
    exit 1
}

$tag = "v$version"
Write-Host "Preparing release for $tag..." -ForegroundColor Cyan

# 2. Build Windows Release
Write-Host "Building Windows binary..." -ForegroundColor Cyan
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed"
    exit 1
}

# 3. Archive Output using Compress-Archive (Built-in)
# Clean up previous archive if exists
if (Test-Path "sudoku_$version.zip") {
    Remove-Item "sudoku_$version.zip"
}

Write-Host "Archiving build output..." -ForegroundColor Cyan
# Compress the contents of the Runner directory (not the directory itself ideally, but ensuring we get the contents)
# Windows build output: build/windows/x64/runner/Release
$buildDir = "build\windows\x64\runner\Release"

if (-not (Test-Path $buildDir)) {
    Write-Error "Build directory not found: $buildDir"
    exit 1
}

Compress-Archive -Path "$buildDir\*" -DestinationPath "sudoku_$version.zip"

Write-Host "Archive created: sudoku_$version.zip" -ForegroundColor Green

# 4. Git Tagging
Write-Host "Creating git tag $tag..." -ForegroundColor Cyan
git tag -a $tag -m "Release $version"
git push origin $tag

# 5. GitHub Release (Optional if gh is installed)
if (Get-Command "gh" -ErrorAction SilentlyContinue) {
    Write-Host "Creating GitHub Release..." -ForegroundColor Cyan
    # Create draft release with the artifact
    gh release create $tag "sudoku_$version.zip" --title "Release $version" --generate-notes --draft
    Write-Host "GitHub Release draft created!" -ForegroundColor Green
} else {
    Write-Host "GitHub CLI (gh) not found. Skipping release upload." -ForegroundColor Yellow
    Write-Host "Please manually upload 'sudoku_$version.zip' to the GitHub release for tag $tag."
}

Write-Host "Release process complete!" -ForegroundColor Green
