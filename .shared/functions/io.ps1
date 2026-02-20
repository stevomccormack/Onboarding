# .shared/functions/io.ps1

# ------------------------------------------------------------------------------------------------
# Test-EnsureDirectory:
# Ensures a directory exists at the given path. Creates it (including parents) if missing.
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function Test-EnsureDirectory {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        # Path:
        # Directory path to test or create.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    # Guard: already exists
    if (Test-Path -LiteralPath $Path -PathType Container) {
        Write-OkMessage -Title "Directory exists" -Message $Path
        return $true
    }   

    try {
        New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null
        Write-OkMessage -Title "Directory created" -Message $Path
        return $true
    }
    catch {
        Write-FailMessage -Title "Ensure directory failed" -Message $Path
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# Test-EnsureFile:
# Ensures a file exists at the given path. Creates it if missing.
# Parent directory must already exist.
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function Test-EnsureFile {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        # Path:
        # File path to test or create.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    # Guard: already exists
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        Write-OkMessage -Title "File exists" -Message $Path
        return $true
    }

    # Guard: parent directory must exist
    $directory = Split-Path -Path $Path -Parent
    if ($directory -and -not (Test-Path -LiteralPath $directory -PathType Container)) {
        Write-FailMessage -Title "Parent directory missing" -Message $directory
        return $false
    }

    try {
        New-Item -ItemType File -Path $Path -Force -ErrorAction Stop | Out-Null
        Write-OkMessage -Title "File created" -Message $Path
        return $true
    }
    catch {
        Write-FailMessage -Title "Ensure file failed" -Message $Path
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# New-DirectoryPath:
# Creates a new directory at the given path.
# Fails if the path already exists.
# Returns the created path on success, otherwise $null.
# ------------------------------------------------------------------------------------------------
function New-DirectoryPath {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Path:
        # Directory path to create.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    # Guards
    if (Test-Path -LiteralPath $Path -PathType Container) {
        Write-FailMessage -Title "Directory exists" -Message $Path
        return $null
    }

    if (Test-Path -LiteralPath $Path) {
        Write-FailMessage -Title "Path exists (not directory)" -Message $Path
        return $null
    }

    try {
        New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null
        Write-OkMessage -Title "Directory created" -Message $Path
        return $Path
    }
    catch {
        Write-FailMessage -Title "Create directory failed" -Message $Path
        return $null
    }
}

# ------------------------------------------------------------------------------------------------
# New-FilePath:
# Creates a new file at the given path.
# Parent directory must already exist.
# Fails if the path already exists.
# Returns the created path on success, otherwise $null.
# ------------------------------------------------------------------------------------------------
function New-FilePath {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Path:
        # File path to create.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    # Guards
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        Write-FailMessage -Title "New File" -Message "Failed to create file, already exists: $Path"
        return $null
    }

    if (Test-Path -LiteralPath $Path) {
        Write-FailMessage -Title "New File" -Message "Failed to create file, path exists and is not a file: $Path"
        return $null
    }

    $directory = Split-Path -Path $Path -Parent
    if ($directory -and -not (Test-Path -LiteralPath $directory -PathType Container)) {
        Write-FailMessage -Title "New File" -Message "Failed to create file, parent directory missing: $directory"
        return $null
    }

    try {
        New-Item -ItemType File -Path $Path -Force -ErrorAction Stop | Out-Null
        Write-OkMessage -Title "New File" -Message "Created new file: $Path"
        return $Path
    }
    catch {
        Write-FailMessage -Title "New File" -Message "Failed to create file: $Path"
        Write-Warn $_.Exception.Message -NoIcon
        return $null
    }
}

# ------------------------------------------------------------------------------------------------
# Clear-Directory:
# Removes all contents of a directory but keeps the directory itself.
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function Clear-Directory {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param (
        # Path:
        # Directory whose contents will be removed.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    # Guard
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        Write-FailMessage -Title "Clear Directory" -Message "Directory not found: $Path"
        return $false
    }

    if (-not $PSCmdlet.ShouldProcess($Path, "Remove all child items")) {
        return $true
    }

    try {
        Get-ChildItem -LiteralPath $Path -Force -ErrorAction Stop |
        Remove-Item -Recurse -Force -ErrorAction Stop

        Write-OkMessage -Title "Clear Directory" -Message "Removed all files from directory: $Path"
        return $true
    }
    catch {
        Write-FailMessage -Title "Clear Directory" -Message "Failed to remove all files from directory: $Path"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# Clear-File:
# Deletes a file at the given path.
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function Clear-File {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param (
        # Path:
        # File path to delete.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    # Guard
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-FailMessage -Title "Clear File" -Message "File not found: $Path"
        return $false
    }

    Write-StatusMessage -Title "Clear File" -Message "Deleting file: $Path"
    if (-not $PSCmdlet.ShouldProcess($Path, "Delete file")) {
        return $true
    }

    try {
        Remove-Item -LiteralPath $Path -Force -ErrorAction Stop
        Write-OkMessage -Title "Clear File" -Message "Deleted file: $Path"
        return $true
    }
    catch {
        Write-FailMessage -Title "Clear File" -Message "Failed to delete file: $Path"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# New-BackupFile:
# Creates a timestamped backup of a file.
# Optionally deletes the original file after backup.
# Returns the backup path on success, otherwise $null.
# ------------------------------------------------------------------------------------------------
function New-BackupFile {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Path:
        # File path to back up.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        # BackupDateTimeFormat:
        # DateTime format used for the backup suffix.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$BackupDateTimeFormat = "yyyyMMddHHmmss",

        # BackupFileSuffix:
        # Suffix used for backup files.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$BackupFileSuffix = ".bak",

        # DeleteAfterBackup:
        # Deletes the original file after backup.
        [Parameter()]
        [switch]$DeleteAfterBackup
    )

    # Guard
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-FailMessage -Title "Backup File" -Message "File not found: $Path"
        return $null
    }

    try {
        $timestamp = Get-Date -Format $BackupDateTimeFormat -ErrorAction Stop
        $backupPath = "$Path$BackupFileSuffix.$timestamp"

        Copy-Item -LiteralPath $Path -Destination $backupPath -Force -ErrorAction Stop
        Write-OkMessage -Title "Backup File" -Message "Backup file created: $backupPath"

        if ($DeleteAfterBackup.IsPresent) {
            Remove-Item -LiteralPath $Path -Force -ErrorAction Stop
            Write-OkMessage -Title "Backup File" -Message "Original file deleted: $Path"
        }

        return $backupPath
    }
    catch {
        Write-FailMessage -Title "Backup File" -Message "Failed to create backup for file: $Path"
        Write-Warn $_.Exception.Message -NoIcon
        return $null
    }
}

# ------------------------------------------------------------------------------------------------
# New-BackupDirectory:
# Creates a timestamped backup of a directory.
# Optionally clears the original directory after backup.
# Returns the backup path on success, otherwise $null.
# ------------------------------------------------------------------------------------------------
function New-BackupDirectory {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # SourcePath:
        # Directory path to back up.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,

        # DestinationPath:
        # Directory path where backup will be created.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath,

        # ClearAfterBackup:
        # Clears the original directory contents after backup.
        [Parameter()]
        [switch]$ClearAfterBackup
    )

    # Guard
    if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {
        Write-FailMessage -Title "Backup Directory" -Message "Source directory not found: $SourcePath"
        return $null
    }

    try {
        # Ensure destination parent directory exists
        $destinationParent = Split-Path -Path $DestinationPath -Parent
        if ($destinationParent -and -not (Test-Path -LiteralPath $destinationParent -PathType Container)) {
            New-Item -ItemType Directory -Path $destinationParent -Force -ErrorAction Stop | Out-Null
        }

        Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Recurse -Force -ErrorAction Stop
        Write-OkMessage -Title "Backup Directory" -Message "Backup directory created: $DestinationPath"

        if ($ClearAfterBackup.IsPresent) {
            Get-ChildItem -LiteralPath $SourcePath -Force -ErrorAction Stop |
            Remove-Item -Recurse -Force -ErrorAction Stop

            Write-OkMessage -Title "Backup Directory" -Message "Original directory cleared: $SourcePath"
        }

        return $DestinationPath
    }
    catch {
        Write-FailMessage -Title "Backup Directory" -Message "Failed to create backup for directory: $SourcePath"
        Write-Warn $_.Exception.Message -NoIcon
        return $null
    }
}
