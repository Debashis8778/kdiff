# Installation script for kdiff on Windows
# Usage: iwr -useb https://raw.githubusercontent.com/rajamohan-rj/kdiff/main/install.ps1 | iex

param(
    [string]$InstallDir = "$env:USERPROFILE\bin",
    [string]$Version = ""
)

$ErrorActionPreference = "Stop"

$REPO = "rajamohan-rj/kdiff"
$BINARY_NAME = "kdiff"

# Show help if requested
if ($args -contains "--help" -or $args -contains "-h") {
    Write-Host "Usage: install.ps1 [-InstallDir <path>] [-Version <version>]"
    Write-Host "  -InstallDir  Installation directory (default: $env:USERPROFILE\bin)"
    Write-Host "  -Version     Specific version to install (default: latest)"
    Write-Host "  -h, --help   Show this help message"
    exit 0
}

# Detect architecture
$ARCH = if ([Environment]::Is64BitProcess) { "x86_64" } else { "i386" }

# Get latest release version if not specified
if (-not $Version) {
    Write-Host "Getting latest version..."
    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$REPO/releases/latest"
        $Version = $response.tag_name -replace '^v', ''
    } catch {
        Write-Error "Failed to get latest version: $_"
        exit 1
    }
} else {
    # Remove 'v' prefix if present
    $Version = $Version -replace '^v', ''
}

Write-Host "Installing $BINARY_NAME v$Version for Windows $ARCH to $InstallDir..."

# Create install directory if it doesn't exist
if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# Download URL
$DOWNLOAD_URL = "https://github.com/$REPO/releases/download/v$Version/${BINARY_NAME}_${Version}_Windows_${ARCH}.zip"

# Create temporary directory
$TMP_DIR = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }

try {
    Write-Host "Downloading from $DOWNLOAD_URL..."
    
    # Download
    $zipFile = Join-Path $TMP_DIR "${BINARY_NAME}.zip"
    try {
        Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $zipFile
    } catch {
        Write-Error "Failed to download $BINARY_NAME. Please check if version v$Version exists at: https://github.com/$REPO/releases"
        exit 1
    }

    # Extract
    Expand-Archive -Path $zipFile -DestinationPath $TMP_DIR -Force

    # Move to install directory
    $binaryPath = Join-Path $TMP_DIR "${BINARY_NAME}.exe"
    $installPath = Join-Path $InstallDir "${BINARY_NAME}.exe"
    
    if (Test-Path $binaryPath) {
        Move-Item $binaryPath $installPath -Force
    } else {
        Write-Error "Binary not found after extraction"
        exit 1
    }

    Write-Host "✅ $BINARY_NAME v$Version installed successfully!"
    Write-Host "📍 Installed to: $installPath"
    
    # Check if install directory is in PATH
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
    if ($currentPath -notlike "*$InstallDir*") {
        Write-Host "⚠️  Warning: $InstallDir is not in your PATH"
        Write-Host "   Add it manually or run: [Environment]::SetEnvironmentVariable('PATH', `$env:PATH + ';$InstallDir', [EnvironmentVariableTarget]::User)"
    }
    
    Write-Host "🚀 Run '$BINARY_NAME --help' to get started."

} finally {
    # Cleanup
    Set-Location $env:USERPROFILE
    Remove-Item $TMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
}
