# Set variables
$homeDir = "C:\Users\$env:USERNAME"
# Check if the script is running in PowerShell
$exeUrl = "https://github.com/Pjdur/Mine/blob/main/bin/mine-win.exe?raw=true"
$destFile = Join-Path -Path $homeDir -ChildPath "mine\bin\mine.exe"
$binDir = Split-Path -Path $destFile -Parent

# Create home directory path if it doesn't exist
if (-not (Test-Path -Path $homeDir)) {
    try {
        $null = New-Item -Path $homeDir -ItemType Directory -Force
    }
    catch {
        Write-Error "Failed to install: unable to create home directory '$homeDir'"
        exit 1
    }
}

# Create bin directory if it doesn't exist
if (-not (Test-Path -Path $binDir)) {
    try {
        $null = New-Item -Path $binDir -ItemType Directory -Force
    }
    catch {
        Write-Error "Failed to create bin directory '$binDir'"
        exit 1
    }
}

try {
    # Download the executable directly
    Write-Host "Downloading executable..."
    Invoke-WebRequest -Uri $exeUrl -OutFile $destFile -ErrorAction Stop

    # Add directory to PATH permanently
    $path = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if (-not ($path -like "*$binDir*")) {
        [Environment]::SetEnvironmentVariable("Path", $path + ";$binDir", "Machine")
        $env:Path += ";$binDir"
    }

    Write-Host "Successfully installed mine to $homeDir"
    Write-Host "Mine has been successfully installed."
}
catch {
    Write-Error "Failed to download or install the executable: $_"
    exit 1
}
