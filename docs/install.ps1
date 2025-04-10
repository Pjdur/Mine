# Set variables
$homeDir = "C:\root"
$repoUrl = "https://github.com/Pjdur/Mine"
$sourceFile = Join-Path -Path -ChildPath "bin\mine-windows.exe"
$destFile = Join-Path -Path $homeDir -ChildPath "mine\bin\mine.exe"
$binDir = Split-Path -Path $destFile -Parent

# Function to install Git if not present
function Install-Git {
    Write-Host "Installing Git..."
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.39.2.windows.1/MinGit.64-bit.exe"
    $tempPath = Join-Path -Path $env:TEMP -ChildPath "git-installer.exe"
    
    try {
        Invoke-WebRequest -Uri $gitUrl -OutFile $tempPath
        Start-Process -FilePath $tempPath -ArgumentList "/SILENT" -Wait
        Remove-Item -Path $tempPath -Force
        $env:PATH += ";C:\Program Files\Git\bin"
    }
    catch {
        Write-Error "Failed to install Git: $_"
        return $false
    }
    return $true
}

# Function to download repository using Invoke-WebRequest
function Download-Repository {
    param($url, $destination)
    
    Write-Host "Downloading repository..."
    $downloadUrl = "$url/archive/refs/heads/main.zip"
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile (Join-Path -Path $destination -ChildPath "repo.zip")
        Expand-Archive -Path (Join-Path -Path $destination -ChildPath "repo.zip") -DestinationPath $destination -Force
        Remove-Item -Path (Join-Path -Path $destination -ChildPath "repo.zip") -Force
        return $true
    }
    catch {
        Write-Error "Failed to download repository: $_"
        return $false
    }
}

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

# Create temporary directory for downloading
$tempDir = New-TemporaryFile | ForEach-Object { $_.DirectoryName }
if (-not $tempDir) {
    Write-Error "Failed to create temporary directory"
    exit 1
}

# Change to temporary directory
Push-Location -Path $tempDir

try {
    # Check if Git is installed
    if (Get-Command -Name git -ErrorAction SilentlyContinue) {
        Write-Host "Git found, using git clone method..."
        git clone $repoUrl
        Set-Location -Path $repoUrl.Split('/')[-1]
    }
    else {
        Write-Host "Git not found, using download method..."
        if (-not (Download-Repository -url $repoUrl -destination $tempDir)) {
            if (-not (Install-Git)) {
                Write-Error "Failed to install Git. Please install Git manually and try again."
                exit 1
            }
            # Try git clone again after installation
            if (-not (git clone $repoUrl)) {
                Write-Error "Failed to clone repository after Git installation"
                exit 1
            }
            Set-Location -Path $repoUrl.Split('/')[-1]
        }
    }

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