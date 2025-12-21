# project.ps1

# ------------------------------------------------------------------------------------------------
# Project:
# Strongly-typed project used for repository management and URL generation.
# ------------------------------------------------------------------------------------------------
class Project {

    [string]$Name
    [string]$Owner
    [string]$Repository
    [string]$HttpsUrl
    [string]$SshUrl
    [string]$WebUrl
    [string]$GitUrl
    [string]$LocalPath

    # Git Configuration
    [string]$UserName
    [string]$UserEmail
    [string]$SafePath
    [string]$Origin
    [string]$MainBranch
    [string]$MergeStrategy
    [string]$PullStrategy

    Project() {}

    Project(
        [string]$Name,
        [string]$Owner,
        [string]$Repository,
        [string]$HttpsUrl,
        [string]$SshUrl,
        [string]$WebUrl,
        [string]$GitUrl,
        [string]$LocalPath,
        [string]$UserName,
        [string]$UserEmail,
        [string]$SafePath,
        [string]$Origin,
        [string]$MainBranch,
        [string]$MergeStrategy,
        [string]$PullStrategy
    ) {
        $this.Name = $Name
        $this.Owner = $Owner
        $this.Repository = $Repository
        $this.HttpsUrl = $HttpsUrl
        $this.SshUrl = $SshUrl
        $this.WebUrl = $WebUrl
        $this.GitUrl = $GitUrl
        $this.LocalPath = $LocalPath

        # Git Configuration
        $this.UserName = $UserName
        $this.UserEmail = $UserEmail
        $this.SafePath = $SafePath
        $this.Origin = $Origin
        $this.MainBranch = $MainBranch
        $this.MergeStrategy = $MergeStrategy
        $this.PullStrategy = $PullStrategy
    }
}

# ------------------------------------------------------------------------------------------------
# New-Project:
# Creates a validated Project with provider-specific URLs and Git configuration settings.
# ------------------------------------------------------------------------------------------------
function New-Project {
    [CmdletBinding()]
    param(
        # Name:
        # Display name for the project.
        # Example: 'Pine Guard Security', 'Visual Studio Code', 'My Amazing Project'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Owner:
        # Repository owner/organization name.
        # Example: 'stevomccormack', 'microsoft', 'myorg'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Owner,

        # Repository:
        # Repository name.
        # Example: 'PineGuard', 'vscode', 'my-project'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Repository,

        # HttpsUrl:
        # HTTPS clone URL for the repository.
        # Example: 'https://github.com/owner/repo.git', 'https://dev.azure.com/org/project/_git/repo'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$HttpsUrl,

        # SshUrl:
        # SSH clone URL for the repository.
        # Example: 'git@github.com:owner/repo.git', 'git@ssh.dev.azure.com:v3/org/project/repo'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SshUrl,

        # WebUrl:
        # Web browser URL for the repository.
        # Example: 'https://github.com/owner/repo', 'https://dev.azure.com/org/project/_git/repo'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WebUrl,

        # GitUrl:
        # Git remote URL ending with .git for 'git remote add origin' commands.
        # Example: 'https://github.com/owner/repo.git', 'https://dev.azure.com/org/project/_git/repo.git'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$GitUrl,

        # LocalPath:
        # Local filesystem path where repository will be cloned.
        # Example: 'C:\Dev\PineGuard', '/home/user/projects/vscode'
        [Parameter()]
        [AllowEmptyString()]
        [string]$LocalPath = '',

        # UserName:
        # Git user.name for this project.
        # Example: 'Steve McCormack', 'John Doe'
        [Parameter()]
        [AllowEmptyString()]
        [string]$UserName = '',

        # UserEmail:
        # Git user.email for this project.
        # Example: 'steve@example.com', 'john@company.com'
        [Parameter()]
        [AllowEmptyString()]
        [string]$UserEmail = '',

        # MainBranch:
        # Default branch name.
        # Example: 'main', 'master', 'develop'
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$MainBranch = 'main',

        # MergeStrategy:
        # Default merge strategy.
        # Example: 'merge', 'rebase', 'squash'
        [Parameter()]
        [ValidateSet('merge', 'rebase', 'squash')]
        [string]$MergeStrategy = 'merge',

        # PullStrategy:
        # Default pull behavior.
        # Example: 'merge', 'rebase'
        [Parameter()]
        [ValidateSet('merge', 'rebase')]
        [string]$PullStrategy = 'merge'
    )

    # Guards
    $nameClean = $Name.Trim()
    $ownerClean = $Owner.Trim()
    $repoClean = $Repository.Trim()
    $httpsUrlClean = $HttpsUrl.Trim()
    $sshUrlClean = $SshUrl.Trim()
    $webUrlClean = $WebUrl.Trim()
    $gitUrlClean = $GitUrl.Trim()

    if (-not $nameClean) { throw "Name is empty" }
    if (-not $ownerClean) { throw "Owner is empty" }
    if (-not $repoClean) { throw "Repository is empty" }
    if (-not $httpsUrlClean) { throw "HttpsUrl is empty" }
    if (-not $sshUrlClean) { throw "SshUrl is empty" }
    if (-not $webUrlClean) { throw "WebUrl is empty" }
    if (-not $gitUrlClean) { throw "GitUrl is empty" }

    # Validate URLs
    if (-not ($httpsUrlClean -match '^https://')) {
        throw "HttpsUrl must start with 'https://': $httpsUrlClean"
    }
    if (-not ($sshUrlClean -match '^git@')) {
        throw "SshUrl must start with 'git@': $sshUrlClean"
    }
    if (-not ($webUrlClean -match '^https://')) {
        throw "WebUrl must start with 'https://': $webUrlClean"
    }
    if (-not ($gitUrlClean -match '\.git$')) {
        throw "GitUrl must end with '.git': $gitUrlClean"
    }

    # Validate LocalPath if provided
    $localPathClean = $LocalPath.Trim()
    if ($localPathClean -and -not (Test-Path -LiteralPath (Split-Path -Path $localPathClean -Parent) -PathType Container)) {
        throw "LocalPath parent directory does not exist: $(Split-Path -Path $localPathClean -Parent)"
    }

    # Set up Git configuration
    $safePath = if ($localPathClean) { $localPathClean } else { '' }
    $origin = $sshUrlClean  # Use SSH URL for origin

    return [Project]::new(
        $nameClean,
        $ownerClean,
        $repoClean,
        $httpsUrlClean,
        $sshUrlClean,
        $webUrlClean,
        $gitUrlClean,
        $localPathClean,
        $UserName.Trim(),
        $UserEmail.Trim(),
        $safePath,
        $origin,
        $MainBranch,
        $MergeStrategy,
        $PullStrategy
    )
}

# ------------------------------------------------------------------------------------------------
# New-GitHubProject:
# Creates a GitHub project with properly formatted URLs for GitHub repositories.
# ------------------------------------------------------------------------------------------------
function New-GitHubProject {
    [CmdletBinding()]
    param(
        # Owner:
        # GitHub username or organization name.
        # Example: 'stevomccormack', 'microsoft', 'octocat'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Owner,

        # Repository:
        # GitHub repository name.
        # Example: 'PineGuard', 'vscode', 'Hello-World'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Repository,

        # Name:
        # Display name for the project (defaults to repository name if not provided).
        # Example: 'Pine Guard Security', 'Visual Studio Code'
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # LocalPath:
        # Local filesystem path where repository will be cloned.
        # Example: 'C:\Dev\PineGuard', '/home/user/projects/vscode'
        [Parameter()]
        [AllowEmptyString()]
        [string]$LocalPath = '',

        # UserName:
        # Git user.name for this project.
        # Example: 'Steve McCormack', 'John Doe'
        [Parameter()]
        [AllowEmptyString()]
        [string]$UserName = '',

        # UserEmail:
        # Git user.email for this project.
        # Example: 'steve@example.com', 'john@company.com'
        [Parameter()]
        [AllowEmptyString()]
        [string]$UserEmail = '',

        # MainBranch:
        # Default branch name.
        # Example: 'main', 'master', 'develop'
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$MainBranch = 'main',

        # MergeStrategy:
        # Default merge strategy.
        # Example: 'merge', 'rebase', 'squash'
        [Parameter()]
        [ValidateSet('merge', 'rebase', 'squash')]
        [string]$MergeStrategy = 'merge',

        # PullStrategy:
        # Default pull behavior.
        # Example: 'merge', 'rebase'
        [Parameter()]
        [ValidateSet('merge', 'rebase')]
        [string]$PullStrategy = 'merge'
    )

    # Guards
    $ownerClean = $Owner.Trim()
    $repoClean = $Repository.Trim()

    if (-not $ownerClean) { throw "Owner is empty" }
    if (-not $repoClean) { throw "Repository is empty" }

    # Default name to repository if not provided
    $nameClean = if ($Name) { $Name.Trim() } else { $repoClean }
    if (-not $nameClean) { throw "Name cannot be empty" }

    # Generate GitHub URLs
    $httpsUrl = "https://github.com/$ownerClean/$repoClean.git"
    $sshUrl = "git@github.com:$ownerClean/$repoClean.git"
    $webUrl = "https://github.com/$ownerClean/$repoClean"
    $gitUrl = "https://github.com/$ownerClean/$repoClean.git"

    return New-Project -Name $nameClean -Owner $ownerClean -Repository $repoClean `
        -HttpsUrl $httpsUrl -SshUrl $sshUrl -WebUrl $webUrl -GitUrl $gitUrl `
        -LocalPath $LocalPath -UserName $UserName -UserEmail $UserEmail `
        -MainBranch $MainBranch -MergeStrategy $MergeStrategy -PullStrategy $PullStrategy
}

# ------------------------------------------------------------------------------------------------
# New-AzureDevOpsProject:
# Creates an Azure DevOps project with properly formatted URLs for Azure DevOps repositories.
# ------------------------------------------------------------------------------------------------
function New-AzureDevOpsProject {
    [CmdletBinding()]
    param(
        # Organization:
        # Azure DevOps organization name.
        # Example: 'mycompany', 'contoso', 'fabrikam'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Organization,

        # Project:
        # Azure DevOps project name.
        # Example: 'MyProject', 'WebApp', 'Infrastructure'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Project,

        # Repository:
        # Azure DevOps repository name.
        # Example: 'MyRepo', 'Frontend', 'API'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Repository,

        # Name:
        # Display name for the project (defaults to repository name if not provided).
        # Example: 'My Web Application', 'Frontend App'
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # LocalPath:
        # Local filesystem path where repository will be cloned.
        # Example: 'C:\Dev\MyRepo', '/home/user/projects/myrepo'
        [Parameter()]
        [AllowEmptyString()]
        [string]$LocalPath = '',

        # UserName:
        # Git user.name for this project.
        # Example: 'Steve McCormack', 'John Doe'
        [Parameter()]
        [AllowEmptyString()]
        [string]$UserName = '',

        # UserEmail:
        # Git user.email for this project.
        # Example: 'steve@example.com', 'john@company.com'
        [Parameter()]
        [AllowEmptyString()]
        [string]$UserEmail = '',

        # MainBranch:
        # Default branch name.
        # Example: 'main', 'master', 'develop'
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$MainBranch = 'main',

        # MergeStrategy:
        # Default merge strategy.
        # Example: 'merge', 'rebase', 'squash'
        [Parameter()]
        [ValidateSet('merge', 'rebase', 'squash')]
        [string]$MergeStrategy = 'merge',

        # PullStrategy:
        # Default pull behavior.
        # Example: 'merge', 'rebase'
        [Parameter()]
        [ValidateSet('merge', 'rebase')]
        [string]$PullStrategy = 'merge'
    )

    # Guards
    $orgClean = $Organization.Trim()
    $projectClean = $Project.Trim()
    $repoClean = $Repository.Trim()

    if (-not $orgClean) { throw "Organization is empty" }
    if (-not $projectClean) { throw "Project is empty" }
    if (-not $repoClean) { throw "Repository is empty" }

    # Default name to repository if not provided
    $nameClean = if ($Name) { $Name.Trim() } else { $repoClean }
    if (-not $nameClean) { throw "Name cannot be empty" }

    # Generate Azure DevOps URLs
    $httpsUrl = "https://dev.azure.com/$orgClean/$projectClean/_git/$repoClean"
    $sshUrl = "git@ssh.dev.azure.com:v3/$orgClean/$projectClean/$repoClean"
    $webUrl = "https://dev.azure.com/$orgClean/$projectClean/_git/$repoClean"
    $gitUrl = "https://dev.azure.com/$orgClean/$projectClean/_git/$repoClean.git"

    return New-Project -Name $nameClean -Owner $orgClean -Repository $repoClean `
        -HttpsUrl $httpsUrl -SshUrl $sshUrl -WebUrl $webUrl -GitUrl $gitUrl `
        -LocalPath $LocalPath -UserName $UserName -UserEmail $UserEmail `
        -MainBranch $MainBranch -MergeStrategy $MergeStrategy -PullStrategy $PullStrategy
}

# ------------------------------------------------------------------------------------------------
# Get-ProjectByName:
# Retrieves a project from the $Projects variable by name.
# ------------------------------------------------------------------------------------------------
function Get-ProjectByName {
    [CmdletBinding()]
    param(
        # Name:
        # The name of the project to retrieve.
        # Example: 'Onboarding', 'MyProject'
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Projects:
        # The projects collection to search in (defaults to $Projects if available).
        [Parameter()]
        [pscustomobject]$Projects = $null
    )

    # Use global $Projects if not provided
    if (-not $Projects) {
        if (-not (Get-Variable -Name 'Projects' -Scope Global -ErrorAction SilentlyContinue)) {
            throw "Projects variable not found. Please ensure `$Projects is defined."
        }
        $Projects = $Global:Projects
    }

    # Search for project by name
    $project = $Projects.PSObject.Properties | Where-Object { $_.Name -eq $Name } | Select-Object -ExpandProperty Value

    if (-not $project) {
        throw "Project '$Name' not found in Projects collection."
    }

    return $project
}