# Create home directory path if it doesn't exist
$homeDir = "$env:USERPROFILE\\mine"
if (-Not (Test-Path $homeDir)) {
    New-Item -ItemType Directory -Force -Path $homeDir | Out-Null
}

# Define file paths
$sourceFile = 'https://github.com/Pjdur/Mine/releases/latest/download/mine-win.exe' # Correct URL for the executable
$destFile = Join-Path -Path $homeDir -ChildPath 'bin\\mine.exe'

# Download file to home directory
try {
    Invoke-WebRequest -Uri $sourceFile -OutFile $destFile -UseBasicParsing
    Write-Host "Successfully installed mine to $homeDir"
}
catch {
    Write-Error "Failed to download file: $_"
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
