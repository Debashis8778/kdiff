#!/bin/bash

set -e

# Installation script for kdiff
# Usage: curl -fsSL https://raw.githubusercontent.com/rajamohan-rj/kdiff/main/install.sh | bash

REPO="rajamohan-rj/kdiff"
BINARY_NAME="kdiff"
INSTALL_DIR="/usr/local/bin"
VERSION=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--dir /path/to/install] [--version v1.0.0]"
            echo "  --dir      Installation directory (default: /usr/local/bin)"
            echo "  --version  Specific version to install (default: latest)"
            echo "  --help     Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64)
        ARCH="x86_64"
        ;;
    arm64)
        ARCH="arm64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Get latest release version if not specified
if [ -z "$VERSION" ]; then
    echo "Getting latest version..."
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep -o '"tag_name": "v[^"]*' | cut -d'"' -f4 | sed 's/v//')
    
    if [ -z "$LATEST_VERSION" ]; then
        echo "Failed to get latest version"
        exit 1
    fi
    VERSION="$LATEST_VERSION"
else
    # Remove 'v' prefix if present
    VERSION=$(echo "$VERSION" | sed 's/^v//')
fi

echo "Installing $BINARY_NAME v$VERSION for $OS $ARCH to $INSTALL_DIR..."

# Download URL
DOWNLOAD_URL="https://github.com/$REPO/releases/download/v$VERSION/${BINARY_NAME}_${VERSION}_$(echo ${OS^})_${ARCH}.tar.gz"

# Create temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download and extract
echo "Downloading from $DOWNLOAD_URL..."
if ! curl -L --fail "$DOWNLOAD_URL" | tar xz; then
    echo "Failed to download or extract $BINARY_NAME"
    echo "Please check if version v$VERSION exists at: https://github.com/$REPO/releases"
    exit 1
fi

# Make executable and move to install directory
chmod +x "$BINARY_NAME"

# Install
echo "Installing $BINARY_NAME to $INSTALL_DIR..."
if [ -w "$INSTALL_DIR" ]; then
    mv "$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
else
    if command -v sudo >/dev/null 2>&1; then
        sudo mv "$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    else
        echo "Error: No write permission to $INSTALL_DIR and sudo not available"
        echo "Please run with --dir to specify a writable directory"
        exit 1
    fi
fi

# Cleanup
cd /
rm -rf "$TMP_DIR"

echo "✅ $BINARY_NAME v$VERSION installed successfully!"
echo "📍 Installed to: $INSTALL_DIR/$BINARY_NAME"

# Check if install directory is in PATH
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "⚠️  Warning: $INSTALL_DIR is not in your PATH"
    echo "   Add it to your shell profile: export PATH="$INSTALL_DIR:\$PATH""
fi

echo "🚀 Run '$BINARY_NAME --help' to get started."
