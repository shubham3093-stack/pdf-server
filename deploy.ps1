# deploy.ps1
# -------------------------
# PowerShell script to build Flutter web and deploy to GitHub Pages

# Change this to your repository name
$repoName = "pdf-server"

Write-Host "Building Flutter web..."
flutter clean
flutter pub get
flutter build web --release --base-href /$repoName/

Write-Host "Copying build to docs folder..."
if (!(Test-Path docs)) { New-Item -ItemType Directory -Path docs }
# Remove old docs contents
Remove-Item docs\* -Recurse -Force -ErrorAction SilentlyContinue
# Copy new build
Copy-Item build\web\* docs\ -Recurse -Force

# Cache-busting step
$indexFile = "docs\index.html"
if (Test-Path $indexFile) {
    $content = Get-Content $indexFile
    $version = (Get-Date -Format "yyyyMMddHHmmss") # timestamp version
    $content = $content -replace 'main.dart.js(\?v=\d+)?', "main.dart.js?v=$version"
    Set-Content -Path $indexFile -Value $content -Encoding UTF8
    Write-Host "Updated index.html with cache-busting version: $version"
} else {
    Write-Host "index.html not found in docs folder!"
}

Write-Host "Committing changes..."
git add docs
git commit -m "Update Flutter web build for GitHub Pages ($version)" -ErrorAction SilentlyContinue

Write-Host "Pushing to GitHub..."
git push

Write-Host 'Deployment complete!'
Write-Host 'Check your site at: https://shubham3093-stack.github.io/'$repoName'/'





