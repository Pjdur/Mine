#!/bin/bash

# Create home directory path if it doesn't exist
homeDir="$HOME/mine"
if [ ! -d "$homeDir" ]; then
    mkdir -p "$homeDir" || { echo "Failed to install: your drive does not seem to have a home directory."; exit 1; }
fi

# Define file paths
sourceFile="$(dirname "$0")/bin/mine-win.exe"
destFile="$homeDir/mine/bin/mine"

# Create bin directory if it doesn't exist
binDir="$(dirname "$destFile")"
if [ ! -d "$binDir" ]; then
    mkdir -p "$binDir" || { echo "Failed to create bin directory '$binDir'"; exit 1; }
fi

# Copy file to home directory
if ! cp -f "$sourceFile" "$destFile"; then
    echo "Failed to copy file"
    exit 1
fi
echo "Successfully installed mine to $homeDir"

# Add directory to PATH permanently
if ! grep -q "$homeDir" "$HOME/.bashrc"; then
    echo "export PATH=\$PATH:$homeDir" >> "$HOME/.bashrc"
    # Refresh PATH in current session
    source "$HOME/.bashrc"
    echo "Mine has been successfully installed."
else
    echo "Mine is already installed."
fi