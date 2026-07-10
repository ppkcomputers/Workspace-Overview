#!/usr/bin/env bash

# Stop execution on any unexpected failures
set -e

# Target repository definitions
REPO_USER="ppkcomputers"
REPO_NAME="Workspace-Overview"
BRANCH="main"

# Dynamically locate the calling user's configuration hierarchy
TARGET_DIR="${HOME}/.config/Quickshell/ActiveWorkspaces"
GITHUB_RAW_URL="https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/${BRANCH}"

echo "===================================================="
echo " Deploying Hyprland Workspace Overview Dashboard... "
echo "===================================================="

# Step 1: Check if Quickshell is installed on the system
if ! command -v quickshell &> /dev/null; then
    echo " [✗] Error: 'quickshell' is not installed or not in your PATH."
    echo "     Please install Quickshell before running this setup script."
    echo "===================================================="
    exit 1
fi

# Step 2: Enforce folder paths structure safely
if [ ! -d "$TARGET_DIR" ]; then
    echo " -> Creating target directory profile at: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
else
    echo " -> Target destination folder already exists: $TARGET_DIR"
fi

# Step 3: Fetch configuration profiles from GitHub
echo " -> Downloading core shell component..."
if curl -sSL -w "%{http_code}" "${GITHUB_RAW_URL}/shell.qml" -o "${TARGET_DIR}/shell.qml" | grep -q "^2"; then
    echo " [✓] shell.qml successfully installed."
else
    echo " [✗] Error: Failed to source shell.qml from remote repository."
    exit 1
fi

echo " -> Downloading toggle script component..."
if curl -sSL -w "%{http_code}" "${GITHUB_RAW_URL}/slide.sh" -o "${TARGET_DIR}/slide.sh" | grep -q "^2"; then
    echo " [✓] slide.sh successfully installed."
    chmod +x "${TARGET_DIR}/slide.sh"
    echo " [✓] Marked slide.sh as executable."
else
    echo " [✗] Error: Failed to source slide.sh from remote repository."
    exit 1
fi

echo "----------------------------------------------------"
echo "Deployment complete! All files synchronized."
echo "Run with your path variable:"
echo "quickshell --path ${TARGET_DIR}"
echo "===================================================="
