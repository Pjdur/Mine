# Create home directory path if it doesn't exist
$homeDir = "$env:USERPROFILE\mine"
if (-Not (Test-Path $homeDir)) {
    New-Item -ItemType Directory -Force -Path $homeDir | Out-Null
}

# Define file paths
$sourceFile = Join-Path -Path -ChildPath 'https://github.com/Pjdur/Mine/bin/mine-win.exe' # Absolute path for avoiding directory errors
$destFile = Join-Path -Path $homeDir -ChildPath 'mine\bin\mine'

# Copy file to home directory
try {
    Copy-Item -Path $sourceFile -Destination $destFile -Force
    Write-Host "Successfully installed mine to $homeDir"
}
catch {
    Write-Error "Failed to copy file: $_"
    exit 1
}

# Add directory to PATH permanently
try {
    # Get current PATH
    $currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    
    # Check if directory is already in PATH
    if (-Not ($currentPath -split ';' -contains $homeDir)) {
        # Add directory to PATH
        $newPath = "$currentPath;$homeDir"
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        
        # Refresh PATH in current session
        $env:Path = [Environment]::GetEnvironmentVariable('Path', 'User')
        Write-Host "Mine has been successfully installed."
    }
    else {
        Write-Host "Mine is already installed."
    }
}
catch {
    Write-Error "Failed to update PATH: $_"
    exit 1
}
