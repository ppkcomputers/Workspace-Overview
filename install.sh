---

## install.sh

This script automatically resolves the target user's true `$HOME` path dynamically, ensures the directory tree exists, and pulls down the files directly from your repository branch.

```bash
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

# Step 1: Enforce folder paths structure safely
if [ ! -d "$TARGET_DIR" ]; then
    echo " -> Creating target directory profile at: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
else
    echo " -> Target destination folder already exists: $TARGET_DIR"
fi

# Step 2: Fetch configuration profiles from GitHub tracking tree
echo " -> Downloading core shell component..."
if curl -sSL -w "%{http_code}" "${GITHUB_RAW_URL}/shell.qml" -o "${TARGET_DIR}/shell.qml" | grep -q "^2"; then
    echo " [✓] shell.qml successfully installed."
else
    echo " [✗] Error: Failed to source remote source manifest."
    exit 1
fi

echo "----------------------------------------------------"
echo "Deployment complete! Run with your path variable:"
echo "quickshell --path ${TARGET_DIR}"
echo "===================================================="
