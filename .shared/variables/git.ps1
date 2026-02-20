# .shared/variables/git.ps1

# -------------------------------------------------------------------------------------------------
# Git Variables
# -------------------------------------------------------------------------------------------------

$gitInstallUrl = 'https://git-scm.com/downloads'
$gitDocsUrl = 'https://git-scm.com/docs'

$Git = [pscustomobject]@{
    Id          = 'git'
    Enabled     = $true                         # Enable Git installation
    Name        = 'Git'
    CommandName = 'git'
    TestCommand = 'git --version'
    Description = 'Distributed version control system'
    WingetId    = 'Git.Git'                     # winget install --exact --id Git.Git --source winget
    ChocoId     = 'git'                         # choco install git
    InstallUrl  = $gitInstallUrl                # Installation page
    DocsUrl     = $gitDocsUrl                   # Documentation
}

$GitConfig = [pscustomobject]@{
    Editor              = 'code --wait'     # Default editor for commit messages, etc.
    AutoCrlf            = 'true'            # Automatic line-ending conversion
    LongPaths           = 'true'            # Support paths longer than 260 characters
    CredentialHelper    = 'manager'         # Credential storage manager
    FetchPrune          = 'true'            # Prune deleted remote branches on fetch
    ColorUi             = 'auto'            # Coloured terminal output
    PushDefault         = 'current'         # Push current branch to same-named remote branch
    PushAutoSetupRemote = 'true'            # Automatically set upstream on first push
    RebaseAutoStash     = 'true'            # Auto-stash before rebase and pop after
    RerereEnabled       = 'true'            # Remember resolved merge conflicts
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Git` Variables:"
    $Git | Format-List

    Write-Header "`$GitConfig` Variables:"
    $GitConfig | Format-List
}
