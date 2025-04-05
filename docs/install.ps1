# Set variables
$homeDir = "C:\Users\$env:USERNAME\AppData\Local\mine"
$repoUrl = "https://github.com/Pjdur/Mine"
$sourceFile = Join-Path -Path $PSScriptRoot -ChildPath "bin\mine-windows.exe"
$destFile = Join-Path -Path $homeDir -ChildPath "mine\bin\mine.exe"
$binDir = Split-Path -Path $destFile -Parent

# Create home directory path if it doesn't exist
if (-not (Test-Path -Path $homeDir)) {
    try {
        New-Item -Path $homeDir -ItemType Directory -Force
    }
    catch {
        Write-Error "Failed to install: unable to create home directory '$homeDir'"
        exit 1
    }
}

# Create bin directory if it doesn't exist
if (-not (Test-Path -Path $binDir)) {
    try {
        New-Item -Path $binDir -ItemType Directory -Force
    }
    catch {
        Write-Error "Failed to create bin directory '$binDir'"
        exit 1
    }
}

# Create temporary directory for downloading
$tempDir = New-TemporaryFile | ForEach-Object { $_.DirectoryName }
if (-not $tempDir) {
    Write-Error "Failed to create temporary directory"
    exit 1
}

# Change to temporary directory
Push-Location -Path $tempDir

try {
    # Download repository
    git clone $repoUrl
    Set-Location -Path $repoUrl.Split('/')[-1]

    # Build if necessary (modify this based on repository requirements)
    if (Test-Path -Path "build.ps1") {
        & ".\build.ps1"
    }

    # Check if executable exists
    if (-not (Test-Path -Path $sourceFile)) {
        Write-Error "Error: Executable '$sourceFile' not found in repository"
        exit 1
    }

    # Copy executable to destination
    Copy-Item -Path $sourceFile -Destination $destFile -Force

    # Add directory to PATH permanently
    $path = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if (-not ($path -like "*$binDir*")) {
        [Environment]::SetEnvironmentVariable("Path", $path + ";$binDir", "Machine")
        $env:Path += ";$binDir"
    }

    Write-Host "Successfully installed mine to $homeDir"
    Write-Host "Mine has been successfully installed."
}
finally {
    # Clean up temporary directory
    Pop-Location
    Remove-Item -Path $tempDir -Recurse -Force
}