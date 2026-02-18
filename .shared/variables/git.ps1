# .shared/variables/git.ps1

# -------------------------------------------------------------------------------------------------
# Git Variables
# -------------------------------------------------------------------------------------------------

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
    Write-Header "`$GitConfig` Variables:"
    $GitConfig | Format-List
}
