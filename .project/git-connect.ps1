# .project/git-connect.ps1

. ".shared\index.ps1"

$project = $Projects.Onboarding # select the project!

# ------------------------------------------------------------------------------------------------

Write-MastHead "$($project.Name) Project: Git Repository Connect"
Write-Status "Connecting local directory to existing Git repository:"
Write-Var -Name "Project Name" -Value $project.Name -NoIcon
Write-Var -Name "Project Path" -Value $project.LocalPath -NoIcon
Write-NewLine

# ------------------------------------------------------------------------------------------------

# Check if git repository is already initialized
if (Test-GitRepositoryIsInitialized -Path $project.LocalPath) {
    Write-FatalMessage -Title "Git Connect" -Message "Git repository is already initialized."
    exit 1
}

# Check if remote git repository exists
if (-not (Test-GitRepositoryExists -RepositoryUrl $project.GitUrl)) {
    Write-FatalMessage -Title "Git Connect" -Message "Remote Git repository does not exist."
    exit 1
}

# ------------------------------------------------------------------------------------------------

# Initialize local repository
git init --initial-branch=$($project.MainBranch)

# Connect to remote repository
git remote add origin $($project.GitUrl)
git fetch origin

# Align local branch with remote history (files already match)
git reset origin/$($project.MainBranch)
git branch --set-upstream-to=origin/$($project.MainBranch) $($project.MainBranch)

# ------------------------------------------------------------------------------------------------

Write-OkMessage -Title "Git Connect" -Message "Connected to existing GitHub repository: $($project.WebUrl)"
