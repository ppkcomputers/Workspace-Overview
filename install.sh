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
API_URL="https://api.github.com/repos/${REPO_USER}/${REPO_NAME}/git/trees/${BRANCH}?recursive=1"

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

# Step 2: Dynamically fetch all file paths from GitHub API and download them
echo " -> Mapping repository structure..."
FILES=$(curl -sSL "$API_URL" | grep '"path":' | awk -F'"' '{print $4}')

if [ -z "$FILES" ]; then
    echo " [✗] Error: Could not map repository or repository is empty."
    exit 1
fi

echo " -> Downloading all repository files..."
for FILE in $FILES; do
    # Skip directories in the tree map; curl will create them if needed
    if [[ "$FILE" == *.* ]]; then
        # Ensure subdirectories exist locally if your repo uses folders
        FILE_DIR=$(dirname "$FILE")
        if [ "$FILE_DIR" != "." ]; then
            mkdir -p "${TARGET_DIR}/${FILE_DIR}"
        fi
        
        echo "   -> Downloading: $FILE"
        curl -sSL "${GITHUB_RAW_URL}/${FILE}" -o "${TARGET_DIR}/${FILE}"
    fi
done

echo "----------------------------------------------------"
echo "Deployment complete! All files synchronized."
echo "Run with your path variable:"
echo "quickshell --path ${TARGET_DIR}"
echo "===================================================="
