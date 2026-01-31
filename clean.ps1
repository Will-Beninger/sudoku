Write-Host "Cleaning up artifacts and build cache..." -ForegroundColor Cyan
if (Test-Path "release_artifacts") {
    Remove-Item "release_artifacts" -Recurse -Force
    Write-Host "Removed release_artifacts directory."
}
flutter clean
Write-Host "Cleanup complete!" -ForegroundColor Green
