# .shared/functions/dotenv.ps1

# ------------------------------------------------------------------------------------------------
# Import-DotEnv:
# Loads key/value pairs from a .env file into environment variables at the specified scope.
# Supports lines in the form KEY=VALUE, ignores blanks and comments (#), and unquotes '...' or "..."
# values. Returns $true if all variables were applied successfully, otherwise $false.
# ------------------------------------------------------------------------------------------------
function Import-DotEnv {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Path:
        # Path to the .env file to load.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        # Scope:
        # Target scope to set variables in: Process, User, or Machine.
        [Parameter()]
        [ValidateSet('Process','User','Machine')]
        [string]$Scope = 'User',

        # Force:
        # Overwrite existing variables if they already exist.
        [Parameter()]
        [switch]$Force
    )

    # Guards
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-FailMessage -Title "Loading DotEnv" -Message "File not found: $Path"
        return $false
    }

    if (-not $PSCmdlet.ShouldProcess("[$Scope] variables", "Load .env file")) {
        return $true
    }

    $hadFailures = $false

    try {
        $resolved = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
        Write-StatusMessage -Title "Loading DotEnv" -Message "Loading $Scope environment variables - $($resolved)`n"
        
        foreach ($rawLine in Get-Content -LiteralPath $Path -ErrorAction Stop) {
            $line = $rawLine.Trim()
            if (-not $line -or $line.StartsWith('#')) { continue }
            if ($line -notmatch '^\s*([^=]+?)\s*=\s*(.*)\s*$') { continue }

            $name  = $matches[1].Trim().Trim([char]0xFEFF)
            $value = $matches[2].Trim()

            if (($value.Length -ge 2) -and ((($value.StartsWith("'") -and $value.EndsWith("'"))) -or (($value.StartsWith('"') -and $value.EndsWith('"'))))) {
                $value = $value.Substring(1, $value.Length - 2)
            }

            if (-not $name) { continue }

            $ok = Set-EnvironmentVariable -Name $name -Value $value -Scope $Scope -Force:$Force
            if (-not $ok) { $hadFailures = $true }
        }

        return (-not $hadFailures)
    }
    catch {
        Write-FailMessage -Title "Load DotEnv" -Message "Failed to load .env file: $Path"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }
}
