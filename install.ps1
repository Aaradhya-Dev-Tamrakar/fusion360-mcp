<#
.SYNOPSIS
Installs or updates the FusionMCPBridge Add-In into Autodesk Fusion 360.
#>

$TargetDir = Join-Path $env:APPDATA "Autodesk\Autodesk Fusion 360\API\AddIns\FusionMCPBridge"
$SourceDir = Join-Path $PSScriptRoot "FusionMCPBridge"

Write-Host "Installing FusionMCPBridge to: $TargetDir" -ForegroundColor Cyan

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

Copy-Item -Path (Join-Path $SourceDir "FusionMCPBridge.py") -Destination $TargetDir -Force
Copy-Item -Path (Join-Path $SourceDir "FusionMCPBridge.manifest") -Destination $TargetDir -Force

Write-Host "FusionMCPBridge installed successfully!" -ForegroundColor Green
Write-Host "Open Autodesk Fusion 360, press Shift+S (Utilities -> Add-Ins), and run 'FusionMCPBridge'." -ForegroundColor Yellow
