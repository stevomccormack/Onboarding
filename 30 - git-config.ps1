# 30 - git-config.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "Git Initialisation"
Write-Status "Configuring projects..."

# ------------------------------------------------------------------------------------------------

# Configure global Git settings
git config --global core.editor $Git.Editor
git config --global core.autocrlf $Git.AutoCrlf
git config --global core.longpaths $Git.LongPaths
git config --global credential.helper $Git.CredentialHelper
git config --global fetch.prune $Git.FetchPrune
git config --global color.ui $Git.ColorUi
git config --global push.default $Git.PushDefault
git config --global push.autoSetupRemote $Git.PushAutoSetupRemote
git config --global rebase.autoStash $Git.RebaseAutoStash
git config --global rerere.enabled $Git.RerereEnabled

# ------------------------------------------------------------------------------------------------

$Projects.GetAll() | ForEach-Object {
    $project = $_

    # Safe directories
    $existingSafeDirs = git config --global --get-all safe.directory 2>$null
    if ($existingSafeDirs -notcontains $project.LocalPath) {
        git config --global --add safe.directory $project.LocalPath
    }
}

# ------------------------------------------------------------------------------------------------

Write-Var -Name "git --global config core.editor" -Value (git config --global core.editor) -NoIcon
Write-Var -Name "git --global config core.autocrlf" -Value (git config --global core.autocrlf) -NoIcon
Write-Var -Name "git --global config core.longpaths" -Value (git config --global core.longpaths) -NoIcon
Write-Var -Name "git --global config credential.helper" -Value (git config --global credential.helper) -NoIcon
Write-Var -Name "git --global config fetch.prune" -Value (git config --global fetch.prune) -NoIcon
Write-Var -Name "git --global config color.ui" -Value (git config --global color.ui) -NoIcon
Write-Var -Name "git --global config push.default" -Value (git config --global push.default) -NoIcon
Write-Var -Name "git --global config push.autoSetupRemote" -Value (git config --global push.autoSetupRemote) -NoIcon
Write-Var -Name "git --global config rebase.autoStash" -Value (git config --global rebase.autoStash) -NoIcon
Write-Var -Name "git --global config rerere.enabled" -Value (git config --global rerere.enabled) -NoIcon
Write-NewLine
Write-Host "git config --global --get-all safe.directory:`n" -ForegroundColor Green -NoNewLine
git config --global --get-all safe.directory | ForEach-Object { Write-Host "- $_" }
Write-NewLine


# ------------------------------------------------------------------------------------------------

Write-OkMessage -Title "Git Config" -Message "Global git settings configured."