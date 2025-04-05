#!/bin/bash

# Set variables
HOME_DIR="/root"
REPO_URL="https://github.com/Pjdur/Mine"
SOURCE_FILE="./bin/mine-linux"
DEST_FILE="$HOME_DIR/mine/bin/mine"
BIN_DIR="$(dirname "$DEST_FILE")"

# Create home directory path if it doesn't exist
if [ ! -d "$HOME_DIR" ]; then
    if ! mkdir -p "$HOME_DIR"; then
        echo "Failed to install: unable to create home directory '$HOME_DIR'" >&2
        exit 1
    fi
fi

# Create bin directory if it doesn't exist
if [ ! -d "$BIN_DIR" ]; then
    if ! mkdir -p "$BIN_DIR"; then
        echo "Failed to create bin directory '$BIN_DIR'" >&2
        exit 1
    fi
fi

# Create temporary directory for downloading
TEMP_DIR="$(mktemp -d)"
if [ -z "$TEMP_DIR" ]; then
    echo "Failed to create temporary directory" >&2
    exit 1
fi

# Change to temporary directory
cd "$TEMP_DIR" || exit 1

# Download repository
if ! git clone "$REPO_URL" .; then
    echo "Failed to clone repository" >&2
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Build if necessary (modify this based on repository requirements)
if [ -f "build.sh" ]; then
    if ! ./build.sh; then
        echo "Failed to build executable" >&2
        rm -rf "$TEMP_DIR"
        exit 1
    fi
fi

# Check if executable exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Executable '$SOURCE_FILE' not found in repository" >&2
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Copy executable to destination
if ! cp "$SOURCE_FILE" "$DEST_FILE"; then
    echo "Error: Failed to copy file: $?" >&2
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Make the file executable
if ! chmod +x "$DEST_FILE"; then
    echo "Error: Failed to set executable permissions on '$DEST_FILE'" >&2
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Clean up temporary directory
rm -rf "$TEMP_DIR"

# Add directory to PATH permanently
if ! grep -q "$BIN_DIR" "$HOME/.bashrc"; then
    echo "export PATH=\$PATH:$BIN_DIR" >> "$HOME/.bashrc"
    # Refresh PATH in current session
    source "$HOME/.bashrc"
    echo "Successfully installed mine to $HOME_DIR"
    echo "Mine has been successfully installed."
else
    echo "Mine is already installed."
fi