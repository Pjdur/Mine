# Set variables
$homeDir = "$env:USERPROFILE\.mine"
$exeUrl = "https://github.com/Pjdur/Mine/blob/main/bin/mine-win.exe?raw=true"
$destFile = Join-Path -Path $homeDir -ChildPath "mine\bin\mine.exe"
$binDir = Split-Path -Path $destFile -Parent
$expectedChecksum = "19D05FA769D6FB763BE16419CFA61676674A9C2FFB500201F77541B60A70F40A"

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

    $totalBytes = $webClient.ResponseHeaders["Content-Length"]
    $downloadedBytes = 0
    $bufferSize = 8192

    Write-Host "Downloading executable..."
    [System.IO.File]::Delete($destFile) | Out-Null
    $stream = [System.IO.File]::Create($destFile)
    $webClient = New-Object System.Net.WebClient
    $webStream = $webClient.OpenRead($exeUrl)

    try {
        $buffer = New-Object byte[] $bufferSize
        while (($bytesRead = $webStream.Read($buffer, 0, $bufferSize)) -gt 0) {
            $stream.Write($buffer, 0, $bytesRead)
            $downloadedBytes += $bytesRead

            $percentComplete = [math]::Round(($downloadedBytes / $totalBytes) * 100)
            $progressBar = ("#" * ($percentComplete / 5)) + ("-" * (20 - ($percentComplete / 5)))
            Write-Host -NoNewline "`r[$progressBar] $percentComplete% "
        }
    }
    finally {
        $stream.Close()
        $webStream.Close()
    }

    # Calculate the checksum of the downloaded file
    Write-Host "Verifying checksum..."
    $calculatedChecksum = Get-FileHash -Path $destFile -Algorithm SHA256 | Select-Object -ExpandProperty Hash

    if ($calculatedChecksum -ne $expectedChecksum) {
        Write-Error "Checksum verification failed. Expected: $expectedChecksum, but got: $calculatedChecksum. Report this security issue to https://github.com/Pjdur/Mine/security/advisories"
        Remove-Item -Path $destFile -Force
        exit 1
    }

    # Add directory to PATH for the current user
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User ")
    if (-not ($userPath -like "*$binDir*")) {
        [Environment]::SetEnvironmentVariable("Path", $userPath + ";$binDir", "User ")
        $env:Path += ";$binDir"
    }

    Write-Host "Successfully installed mine to $homeDir"
    Write-Host "Mine has been successfully installed."
}
catch {
    Write-Error "Failed to download or install the executable: $_"
    exit 1
}