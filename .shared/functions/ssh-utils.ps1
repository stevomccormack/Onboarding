# .shared/functions/ssh-utils.ps1

# ------------------------------------------------------------------------------------------------
# Test-SshPreflight:
# Validates required SSH tooling is available for an SSH profile workflow.
# Currently checks: ssh, ssh-keygen (ssh-add intentionally optional).
# Returns $true when required commands are available, otherwise $false.
# ------------------------------------------------------------------------------------------------
function Test-SshPreflight {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        # SshProfile:
        # SSH profile object (currently unused but kept for future validations).
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        $SshProfile
    )

    # Guards
    if (-not $SshProfile) {
        Write-FailMessage -Title "Preflight" -Message "Profile is null"
        return $false
    }
    Write-OkMessage -Title "Preflight" -Message "Profile OK"

    if (-not (Test-Command -Name 'ssh')) {
        Write-FailMessage -Title "Preflight" -Message "ssh not found on PATH"
        return $false
    }
    Write-OkMessage -Title "Preflight" -Message "Command [ssh] OK"

    if (-not (Test-Command -Name 'ssh-keygen')) {
        Write-FailMessage -Title "Preflight" -Message "ssh-keygen not found on PATH"
        return $false
    }   
    Write-OkMessage -Title "Preflight" -Message "Command [ssh-keygen] OK"

    Write-StatusMessage -Title "Preflight" -Message "SSH tooling validated"
    return $true
}
