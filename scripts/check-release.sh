#!/bin/bash

# Script to monitor GitHub release status

set -e

TAG="v0.1.0"
REPO="rajamohan-rj/kdiff"

echo "🔍 Monitoring release status for $TAG..."
echo "Repository: https://github.com/$REPO"
echo "Actions: https://github.com/$REPO/actions"
echo "Releases: https://github.com/$REPO/releases"
echo ""

# Check if release exists
echo "📦 Checking if release exists..."
RELEASE_URL="https://api.github.com/repos/$REPO/releases/tags/$TAG"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$RELEASE_URL")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Release $TAG found!"
    
    # Get release info
    echo "📋 Release information:"
    curl -s "$RELEASE_URL" | jq -r '.name, .tag_name, .published_at'
    
    # List assets
    echo ""
    echo "📦 Assets:"
    curl -s "$RELEASE_URL" | jq -r '.assets[] | "- \(.name) (\(.size) bytes)"'
    
    # Test download
    echo ""
    echo "🧪 Testing download..."
    DOWNLOAD_URL="https://github.com/$REPO/releases/download/$TAG/kdiff_${TAG}_Darwin_arm64.tar.gz"
    if curl -sL --fail "$DOWNLOAD_URL" -o "test-download-$TAG.tar.gz"; then
        echo "✅ Download successful!"
        echo "📁 File size: $(ls -lh test-download-$TAG.tar.gz | awk '{print $5}')"
        echo "🗜️  Testing extraction..."
        if tar -tzf "test-download-$TAG.tar.gz" > /dev/null 2>&1; then
            echo "✅ Archive is valid!"
            echo "📄 Contents:"
            tar -tzf "test-download-$TAG.tar.gz"
        else
            echo "❌ Archive is corrupted"
        fi
        rm -f "test-download-$TAG.tar.gz"
    else
        echo "❌ Download failed"
    fi
    
    # Test installation script
    echo ""
    echo "🧪 Testing installation script..."
    if curl -sSL "https://raw.githubusercontent.com/$REPO/main/install.sh" | bash -s -- --help > /dev/null 2>&1; then
        echo "✅ Installation script is accessible"
    else
        echo "❌ Installation script failed"
    fi
    
else
    echo "❌ Release $TAG not found (HTTP $HTTP_CODE)"
    echo "🔍 Available releases:"
    curl -s "https://api.github.com/repos/$REPO/releases" | jq -r '.[].tag_name' | head -5
fi
