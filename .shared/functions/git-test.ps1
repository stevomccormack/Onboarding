# .shared/functions/git-test.ps1

# ------------------------------------------------------------------------------------------------
# Test-GitRepositoryIsInitialized:
# Tests if a directory is a valid Git repository by checking for .git directory and validating
# with git rev-parse. Returns $true if valid repository, $false otherwise.
# ------------------------------------------------------------------------------------------------
function Test-GitRepositoryIsInitialized {
    [CmdletBinding()]
    [OutputType([bool])]
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

# ------------------------------------------------------------------------------------------------
# Test-RepositoryExists:
# Tests if a Git repository exists and is accessible using git ls-remote.
# Works with GitHub, Azure DevOps, GitLab, and any Git provider.
# Returns $true if repository exists and is accessible, otherwise $false.
# ------------------------------------------------------------------------------------------------
function Test-GitRepositoryExists {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        # RepositoryUrl:
        # Git repository URL (HTTPS or SSH format).
        # Example: 'https://github.com/owner/repo.git', 'git@github.com:owner/repo.git'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RepositoryUrl,

        # Timeout:
        # Connection timeout in seconds (default 10).
        [Parameter()]
        [ValidateRange(1, 120)]
        [int]$Timeout = 10
    )

    # Guards
    if (-not (Test-Command -Name 'git')) {
        Write-FailMessage -Title "Git Not Found" -Message "Git is not installed or not in PATH"
        return $false
    }

    $urlClean = $RepositoryUrl.Trim()

    Write-StatusMessage -Title "Repository Test" -Message "Checking if repository exists and is accessible"
    Write-Var -Name "Repository URL" -Value $urlClean -NoIcon

    try {
        # Use git ls-remote to check if repository exists
        # This command lists remote references without cloning
        $output = & git ls-remote --exit-code $urlClean HEAD 2>&1
        $exit = $LASTEXITCODE

        if ($exit -eq 0) {
            Write-OkMessage -Title "Repository Test" -Message "Repository exists and is accessible"
            return $true
        }

        # Exit code 2 typically means repository not found or not accessible
        if ($exit -eq 2) {
            Write-FailMessage -Title "Repository Test" -Message "Repository does not exist or is not accessible"
        }
        else {
            Write-FailMessage -Title "Repository Test" -Message "Failed with exit code $exit"
        }

        if ($output) { Write-Warn ($output | Out-String).Trim() -NoIcon }
        return $false
    }
    catch {
        Write-FailMessage -Title "Repository Test" -Message "Error checking repository"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# Test-EnsureGitRepository:
# Ensures a GitHub repository exists, creating it if necessary using GitHub CLI.
# Requires GitHub CLI (gh) to be installed and authenticated.
# Returns $true if repository exists or was created successfully, otherwise $false.
# ------------------------------------------------------------------------------------------------
function Test-EnsureGitRepository {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        # Owner:
        # Repository owner (username or organization).
        # Example: 'stevomccormack', 'microsoft'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Owner,

        # Repository:
        # Repository name.
        # Example: 'Onboarding', 'MyProject'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Repository,

        # IsPrivate:
        # When set, creates a private repository. Default is public.
        [Parameter()]
        [switch]$IsPrivate,

        # Description:
        # Optional repository description.
        [Parameter()]
        [AllowEmptyString()]
        [string]$Description = '',

        # CreateIfMissing:
        # When set, creates the repository if it doesn't exist.
        [Parameter()]
        [switch]$CreateIfMissing
    )

    # Guards
    if (-not (Test-Command -Name 'gh')) {
        Write-FailMessage -Title "GitHub CLI Not Found" -Message "Install GitHub CLI from https://cli.github.com/"
        return $false
    }

    $ownerClean = $Owner.Trim()
    $repoClean = $Repository.Trim()
    $fullName = "$ownerClean/$repoClean"
    $gitUrl = "https://github.com/$ownerClean/$repoClean.git"

    Write-Header "GitHub Repository Check"
    Write-Var -Name "Repository" -Value $fullName -NoIcon

    # Check if repository exists using git ls-remote
    $exists = Test-GitRepositoryExists -RepositoryUrl $gitUrl

    if ($exists) {
        Write-OkMessage -Title "Repository Status" -Message "Repository already exists"
        return $true
    }

    if (-not $CreateIfMissing) {
        Write-FailMessage -Title "Repository Status" -Message "Repository does not exist and -CreateIfMissing not specified"
        return $false
    }

    # Create repository using GitHub CLI
    Write-StatusMessage -Title "Repository Create" -Message "Creating new GitHub repository"
    Write-Var -Name "Repository" -Value $fullName -NoIcon
    Write-Var -Name "Visibility" -Value $(if ($IsPrivate) { "Private" } else { "Public" }) -NoIcon
    if ($Description) { Write-Var -Name "Description" -Value $Description -NoIcon }

    try {
        $ghArgs = @('repo', 'create', $fullName)
        
        if ($IsPrivate) {
            $ghArgs += '--private'
        }
        else {
            $ghArgs += '--public'
        }

        if ($Description) {
            $ghArgs += '--description'
            $ghArgs += $Description
        }

        Write-Host "gh $($ghArgs -join ' ')" -ForegroundColor Cyan

        $output = & gh @ghArgs 2>&1
        $exit = $LASTEXITCODE

        if ($exit -eq 0) {
            Write-OkMessage -Title "Repository Create" -Message "Successfully created repository"
            if ($output) { Write-Info ($output | Out-String).Trim() -NoIcon }
            return $true
        }

        Write-FailMessage -Title "Repository Create" -Message "Failed with exit code $exit"
        if ($output) { Write-Warn ($output | Out-String).Trim() -NoIcon }
        return $false
    }
    catch {
        Write-FailMessage -Title "Repository Create" -Message "Error creating repository"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }
}
