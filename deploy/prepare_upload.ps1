param(
  [string]$WorkspaceRoot = "D:\25080\Documents\AndroidStudioProjects",
  [string]$OutputDir = "D:\25080\Documents\AndroidStudioProjects\_luminous_upload"
)

$ErrorActionPreference = 'Stop'

$luminousRoot = Join-Path $WorkspaceRoot "Luminous"
$websiteRoot = Join-Path $WorkspaceRoot "LuminousWebsite"
$pptRoot = Join-Path $WorkspaceRoot "LuminousPPT"

$siteFrontendRoot = Join-Path $websiteRoot "luminousvue"
$siteBackendRoot = Join-Path $websiteRoot "luminousBackend"
$pptSource = Join-Path $pptRoot "reveal.js-master"

if (-not (Test-Path $luminousRoot)) { throw "Missing: $luminousRoot" }
if (-not (Test-Path $siteFrontendRoot)) { throw "Missing: $siteFrontendRoot" }
if (-not (Test-Path $siteBackendRoot)) { throw "Missing: $siteBackendRoot" }
if (-not (Test-Path $pptSource)) { throw "Missing: $pptSource" }

Push-Location $siteFrontendRoot
npm ci
npm run build
Pop-Location

if (-not (Test-Path (Join-Path $siteFrontendRoot "dist"))) {
  throw "Build output not found: $siteFrontendRoot\\dist"
}

if (Test-Path $OutputDir) {
  Remove-Item $OutputDir -Recurse -Force
}

New-Item -Path $OutputDir -ItemType Directory | Out-Null
New-Item -Path (Join-Path $OutputDir "deploy") -ItemType Directory | Out-Null
New-Item -Path (Join-Path $OutputDir "site-frontend") -ItemType Directory | Out-Null

robocopy (Join-Path $luminousRoot "backend") (Join-Path $OutputDir "backend") /E /NFL /NDL /NJH /NJS /NP /XD node_modules dist .git .idea .vscode
robocopy (Join-Path $luminousRoot "deploy") (Join-Path $OutputDir "deploy") /E /NFL /NDL /NJH /NJS /NP /XD certs
Copy-Item (Join-Path $luminousRoot "docker-compose.prod.yml") (Join-Path $OutputDir "docker-compose.prod.yml") -Force

robocopy $siteBackendRoot (Join-Path $OutputDir "site-backend") /E /NFL /NDL /NJH /NJS /NP /XD node_modules .git .idea .vscode
robocopy (Join-Path $siteFrontendRoot "dist") (Join-Path $OutputDir "site-frontend\\dist") /E /NFL /NDL /NJH /NJS /NP
robocopy $pptSource (Join-Path $OutputDir "ppt") /E /NFL /NDL /NJH /NJS /NP

# Ensure site-backend Dockerfile exists in upload bundle.
$siteDockerfile = Join-Path $siteBackendRoot "Dockerfile"
if (-not (Test-Path $siteDockerfile)) {
  throw "Missing website backend Dockerfile: $siteDockerfile"
}

$zipPath = "$OutputDir.zip"
if (Test-Path $zipPath) {
  Remove-Item $zipPath -Force
}
Compress-Archive -Path (Join-Path $OutputDir "*") -DestinationPath $zipPath -Force

Write-Host "Upload folder prepared: $OutputDir"
Write-Host "Zip prepared: $zipPath"
