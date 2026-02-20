# .shared/functions/modules.ps1

# ------------------------------------------------------------------------------------------------
# Test-Module:
# Checks whether a PowerShell module is installed and available locally.
# Returns $true if found, otherwise $false.
# ------------------------------------------------------------------------------------------------
function Test-Module {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # ModuleName:
        # Name of the PowerShell module to test (e.g. 'ExchangeOnlineManagement').
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName
    )

    # Guard: keep this helper quiet and predictable (no throws)
    if (-not $ModuleName.Trim()) { return $false }

    $commandText = "Get-Module -ListAvailable -Name $ModuleName"
    Write-Status -Title "Module" -Message $commandText

    try {
        $found = Get-Module -ListAvailable -Name $ModuleName -ErrorAction Stop
        return ($null -ne $found)
    }
    catch {
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# Install-Module:
# Ensures a PowerShell module is installed locally.
# Optionally imports the module after install (or if already installed).
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function Install-Module {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # ModuleName:
        # Name of the PowerShell module to install.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName,

        # Scope:
        # Installation scope (CurrentUser or AllUsers).
        [Parameter()]
        [ValidateSet('CurrentUser', 'AllUsers')]
        [string]$Scope = 'CurrentUser',

        # Repository:
        # PowerShell repository name (default: PSGallery).
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Repository = 'PSGallery',

        # Force:
        # Forces reinstallation if the module already exists.
        [Parameter()]
        [switch]$Force,

        # AllowClobber:
        # Allows overwriting existing commands if name conflicts exist.
        [Parameter()]
        [switch]$AllowClobber,

        # ImportAfterInstall:
        # Imports the module after install (or if already installed).
        [Parameter()]
        [switch]$ImportAfterInstall
    )

    # Sanitize
    $moduleNameClean = $ModuleName.Trim()

    # --------------------------------------------------------------------------------------------

    if (-not (Get-Command -Name 'PowerShellGet\Install-Module' -ErrorAction SilentlyContinue)) {
        Write-Fail -Title "Install Module" -Message "PowerShellGet Install-Module not available"
        return $false
    }

    if (Test-Module -ModuleName $moduleNameClean) {
        Write-Ok -Title "Install Module" -Message "Module already installed: $moduleNameClean"
    }
    else {
        $commandText = "PowerShellGet\Install-Module -Name $moduleNameClean -Scope $Scope -Repository $Repository"
        if ($Force) { $commandText += " -Force" }
        if ($AllowClobber) { $commandText += " -AllowClobber" }

        Write-Status -Title "Install Module" -Message "Installing module: $commandText..."

        try {
            $installParams = @{
                Name        = $moduleNameClean
                Scope       = $Scope
                Repository  = $Repository
                ErrorAction = 'Stop'
            }

            if ($Force) { $installParams['Force'] = $true }
            if ($AllowClobber) { $installParams['AllowClobber'] = $true }

            PowerShellGet\Install-Module @installParams

            Write-Ok -Title "Install Module" -Message "Module installed: $moduleNameClean"
        }
        catch {
            Write-Fail -Title "Install Module" -Message "Module install failed: $moduleNameClean"
            Write-Warn $_.Exception.Message -NoIcon
            return $false
        }
    }

    if ($ImportAfterInstall.IsPresent) {
        return (Import-ModuleSafe -ModuleName $moduleNameClean)
    }

    return $true
}

# ------------------------------------------------------------------------------------------------
# Import-ModuleSafe:
# Imports a PowerShell module with consistent logging and error handling.
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function Import-ModuleSafe {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # ModuleName:
        # Name of the PowerShell module to import.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName
    )

    # Guard
    $moduleNameClean = $ModuleName.Trim()

    $commandText = "Import-Module $moduleNameClean"
    Write-Status -Title "Import Module" -Message "Importing module: $commandText..."

    try {
        Import-Module $moduleNameClean -ErrorAction Stop
        Write-Ok -Title "Import Module" -Message "Module imported: $moduleNameClean"
        return $true
    }
    catch {
        Write-Fail -Title "Import Module" -Message "Module import failed: $moduleNameClean"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# Install-ModuleAndImport:
# Convenience wrapper that ensures a module is installed and immediately imported.
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function Install-ModuleAndImport {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # ModuleName:
        # Name of the PowerShell module to install and import.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName
    )

    # Guard
    $moduleNameClean = $ModuleName.Trim()

    return (Install-Module -ModuleName $moduleNameClean -Force -AllowClobber -ImportAfterInstall)
}
