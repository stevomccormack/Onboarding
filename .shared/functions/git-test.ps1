# git-test.ps1

# ------------------------------------------------------------------------------------------------
# Test-GitRepository:
# Tests if a directory is a valid Git repository by checking for .git directory and validating
# with git rev-parse. Returns $true if valid repository, $false otherwise.
# ------------------------------------------------------------------------------------------------
function Test-GitRepository {
    [CmdletBinding()]
    param(
        # Path:
        # Path to the directory to check. Defaults to current directory if not specified.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Path = "."
    )

    # Resolve to absolute path
    $absolutePath = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
    if (-not $absolutePath) {
        return $false
    }

    # Check for .git directory
    $gitPath = Join-Path $absolutePath ".git"
    if (-not (Test-Path $gitPath)) {
        return $false
    }
    
    # Verify with git rev-parse
    try {
        Push-Location $absolutePath
        git rev-parse --git-dir 2>$null | Out-Null
        $result = $?
        Pop-Location
        return $result
    }
    catch {
        Pop-Location
        return $false
    }
}