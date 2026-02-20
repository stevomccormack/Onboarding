# .shared/functions/common.ps1

# ------------------------------------------------------------------------------------------------
# Test-IsAdmin:
# Returns $true if the current PowerShell session is running as Administrator.
# Returns $false otherwise.
# ------------------------------------------------------------------------------------------------
function Test-IsAdmin {
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity

    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
