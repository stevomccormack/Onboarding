# .shared/functions/git-config.ps1

# ------------------------------------------------------------------------------------------------
# New-GitSafeDirectory:
# Adds a directory to Git's safe.directory configuration at the specified scope.
# Checks if the directory is already registered to prevent duplicates (idempotent).
# Returns $true if directory was added or already exists, otherwise $false.
# ------------------------------------------------------------------------------------------------
function New-GitSafeDirectory {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param (
        # Path:
        # Directory path to add to safe.directory configuration.
        # Example: 'D:\Projects\MyRepo', 'C:\Dev\App'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        # Scope:
        # Git configuration scope (local, global, system).
        # Default: 'global' (user-level, most common for safe.directory)
        [Parameter()]
        [ValidateSet('local', 'global', 'system')]
        [string]$Scope = 'global',

        # SkipIfExists:
        # Skip if directory already exists in safe.directory (no error).
        [Parameter()]
        [switch]$SkipIfExists
    )

    # Guards
    if (-not (Test-Command -Name 'git')) {
        Write-FailMessage -Title "Git Not Found" -Message "Git is not installed or not in PATH"
        return $false
    }

    $pathClean = $Path.Trim()

    # Normalize path for Git (forward slashes, no trailing slash)
    $normalizedPath = $pathClean.Replace('\', '/')
    if ($normalizedPath.EndsWith('/')) {
        $normalizedPath = $normalizedPath.TrimEnd('/')
    }

    Write-StatusMessage -Title "Git Safe Directory" -Message "Checking if directory is already registered"
    Write-Var -Name "Path" -Value $normalizedPath -NoIcon
    Write-Var -Name "Scope" -Value $Scope -NoIcon

    try {
        # Get all safe directories at specified scope
        $existingSafeDirs = @(git config --$Scope --get-all safe.directory 2>$null)
        
        # Normalize existing paths for comparison
        $existingNormalized = $existingSafeDirs | ForEach-Object { 
            $_.Replace('\', '/').TrimEnd('/')
        }

        # Check if already exists
        if ($existingNormalized -contains $normalizedPath) {
            if ($SkipIfExists) {
                Write-OkMessage -Title "Git Safe Directory" -Message "Directory already registered (skipped)"
                return $true
            }
            Write-InfoMessage -Title "Git Safe Directory" -Message "Directory already registered"
            return $true
        }

        if (-not $PSCmdlet.ShouldProcess($normalizedPath, "Add to git config --$Scope safe.directory")) {
            return $true
        }

        # Add to safe.directory
        Write-StatusMessage -Title "Git Safe Directory" -Message "Registering directory"
        git config --$Scope --add safe.directory $normalizedPath 2>&1 | Out-Null
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-OkMessage -Title "Git Safe Directory" -Message "Directory registered: $normalizedPath"
            return $true
        }

        Write-FailMessage -Title "Git Safe Directory" -Message "Failed to register directory (exit $exitCode)"
        return $false
    }
    catch {
        Write-FailMessage -Title "Git Safe Directory" -Message "Error registering directory"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# Remove-GitSafeDirectory:
# Removes a directory from Git's safe.directory configuration at the specified scope.
# Returns $true if directory was removed or doesn't exist, otherwise $false.
# ------------------------------------------------------------------------------------------------
function Remove-GitSafeDirectory {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param (
        # Path:
        # Directory path to remove from safe.directory configuration.
        # Example: 'D:\Projects\MyRepo', 'C:\Dev\App'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        # Scope:
        # Git configuration scope (local, global, system).
        [Parameter()]
        [ValidateSet('local', 'global', 'system')]
        [string]$Scope = 'global'
    )

    # Guards
    if (-not (Test-Command -Name 'git')) {
        Write-FailMessage -Title "Git Not Found" -Message "Git is not installed or not in PATH"
        return $false
    }

    $pathClean = $Path.Trim()

    # Normalize path for Git
    $normalizedPath = $pathClean.Replace('\', '/')
    if ($normalizedPath.EndsWith('/')) {
        $normalizedPath = $normalizedPath.TrimEnd('/')
    }

    Write-StatusMessage -Title "Git Safe Directory" -Message "Removing directory registration"
    Write-Var -Name "Path" -Value $normalizedPath -NoIcon
    Write-Var -Name "Scope" -Value $Scope -NoIcon

    try {
        # Check if exists
        $existingSafeDirs = @(git config --$Scope --get-all safe.directory 2>$null)
        $existingNormalized = $existingSafeDirs | ForEach-Object { 
            $_.Replace('\', '/').TrimEnd('/')
        }

        if ($existingNormalized -notcontains $normalizedPath) {
            Write-InfoMessage -Title "Git Safe Directory" -Message "Directory not registered (nothing to remove)"
            return $true
        }

        if (-not $PSCmdlet.ShouldProcess($normalizedPath, "Remove from git config --$Scope safe.directory")) {
            return $true
        }

        # Remove from safe.directory
        git config --$Scope --unset safe.directory $normalizedPath 2>&1 | Out-Null
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-OkMessage -Title "Git Safe Directory" -Message "Directory unregistered: $normalizedPath"
            return $true
        }

        Write-FailMessage -Title "Git Safe Directory" -Message "Failed to unregister directory (exit $exitCode)"
        return $false
    }
    catch {
        Write-FailMessage -Title "Git Safe Directory" -Message "Error unregistering directory"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# Get-GitSafeDirectories:
# Retrieves all safe directories configured at the specified scope.
# Returns array of paths, or empty array if none configured.
# ------------------------------------------------------------------------------------------------
function Get-GitSafeDirectories {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        # Scope:
        # Git configuration scope (local, global, system, or 'all' for all scopes).
        [Parameter()]
        [ValidateSet('local', 'global', 'system', 'all')]
        [string]$Scope = 'all'
    )

    # Guards
    if (-not (Test-Command -Name 'git')) {
        Write-FailMessage -Title "Git Not Found" -Message "Git is not installed or not in PATH"
        return @()
    }

    try {
        if ($Scope -eq 'all') {
            # Get from all scopes
            $safeDirs = @(git config --get-all safe.directory 2>$null)
        }
        else {
            # Get from specific scope
            $safeDirs = @(git config --$Scope --get-all safe.directory 2>$null)
        }

        if ($safeDirs.Count -eq 0) {
            Write-InfoMessage -Title "Git Safe Directory" -Message "No safe directories configured"
            return @()
        }

        Write-OkMessage -Title "Git Safe Directory" -Message "Found $($safeDirs.Count) safe director$(if ($safeDirs.Count -eq 1) { 'y' } else { 'ies' })"
        
        return $safeDirs
    }
    catch {
        Write-FailMessage -Title "Git Safe Directory" -Message "Error retrieving safe directories"
        Write-Warn $_.Exception.Message -NoIcon
        return @()
    }
}

