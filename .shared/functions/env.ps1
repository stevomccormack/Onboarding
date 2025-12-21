# env.ps1

# ------------------------------------------------------------------------------------------------
# Set-EnvironmentVariable:
# Sets an environment variable at the specified scope (Process/User/Machine) and updates the current
# PowerShell session (Env: drive) so it is immediately available in this shell.
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function Set-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Name:
        # Environment variable name. Must be non-empty (whitespace/BOM is trimmed).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Value:
        # Environment variable value. Empty string is allowed.
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Value,

        # Scope:
        # Target scope to persist the variable to: Process, User, or Machine.
        [Parameter()]
        [ValidateSet('Process','User','Machine')]
        [string]$Scope = 'User',

        # Force:
        # Overwrite an existing variable if it already exists.
        [Parameter()]
        [switch]$Force
    )

    # Sanitize
    $nameClean = $Name.Trim().Trim([char]0xFEFF)

    $existing = [Environment]::GetEnvironmentVariable($nameClean, $Scope)

    if (-not $Force -and $null -ne $existing) {
        if ($existing -ceq $Value) {
            Write-Var -Name "[$Scope] $nameClean" -Value $Value -NoIcon -NoNewLine
            Write-Host " (unchanged)" -ForegroundColor DarkYellow
        }
        else {
            Write-Var -Name "[$Scope] $nameClean" -Value $existing -NoIcon -NoNewLine
            Write-Host " (exists)" -ForegroundColor DarkYellow
        }

        return ($existing -ceq $Value)
    }

    if (-not $PSCmdlet.ShouldProcess("[$Scope] $nameClean", "Set environment variable")) {
        return $true
    }

    try {
        Write-StatusMessage -Title "Setting" -Message "[$Scope] $nameClean" -NoIcon

        # Persist to requested scope
        [Environment]::SetEnvironmentVariable($nameClean, $Value, $Scope)

        # Always update current session (Env: drive)
        Set-Item -Path "Env:$nameClean" -Value $Value -ErrorAction Stop
        
        Write-Var -Name "[$Scope] $nameClean" -Value $Value -NoIcon -NoNewLine
        Write-Host " (new)" -ForegroundColor Green

        return $true
    }
    catch {
        Write-FailMessage -Title "Failed" -Message "[$Scope] $nameClean"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# Remove-EnvironmentVariable:
# Removes an environment variable from the specified scope (Process/User/Machine) and also removes
# it from the current PowerShell session (Env: drive) if present.
# Returns $true on success (including when the variable does not exist), $false on failure.
# ------------------------------------------------------------------------------------------------
function Remove-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Name:
        # Environment variable name. Must be non-empty (whitespace/BOM is trimmed).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Scope:
        # Target scope to remove the variable from: Process, User, or Machine.
        [Parameter()]
        [ValidateSet('Process','User','Machine')]
        [string]$Scope = 'User'
    )

    # Sanitize
    $nameClean = $Name.Trim().Trim([char]0xFEFF)

    # --------------------------------------------------------------------------------------------

    $existing = [Environment]::GetEnvironmentVariable($nameClean, $Scope)
    if ($null -eq $existing) {
        Write-WarnMessage -Title "Environment Variable" -Message "Remove failed. [$Scope] $nameClean not found" -NoIcon
        return $true
    }

    if (-not $PSCmdlet.ShouldProcess("[$Scope] $nameClean", "Remove environment variable")) {
        return $true
    }

    try {
        Write-StatusMessage -Title "Environment Variable" -Message "Removing [$Scope] $nameClean" -NoIcon

        # Remove at requested scope
        [Environment]::SetEnvironmentVariable($nameClean, $null, $Scope)

        # Always remove from current session too (if present)
        if (Test-Path -LiteralPath "Env:$nameClean") {
            Remove-Item -Path "Env:$nameClean" -Force -ErrorAction Stop
        }

        Write-OkMessage -Title "Environment Variable" -Message "Removed [$Scope] $nameClean" -NoIcon
        return $true
    }
    catch {
        Write-FailMessage -Title "Environment Variable" -Message "Failed to remove [$Scope] $nameClean"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }
}