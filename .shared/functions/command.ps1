# command.ps1

# ------------------------------------------------------------------------------------------------
# Test-Command:
# Checks whether a command is available in the current PowerShell session.
# Returns $true if the command exists, otherwise $false.
# ------------------------------------------------------------------------------------------------
function Test-Command {
    [CmdletBinding()]
    param (
        # Name:
        # The name of the command to test for availability.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $nameClean = $Name.Trim()

    return [bool](Get-Command -Name $nameClean -ErrorAction SilentlyContinue)
}
