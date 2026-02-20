# 30 - git-config.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "Git Config (Global)"
Write-Status "Configuring git global settings..."

# ------------------------------------------------------------------------------------------------

# Configure global Git settings
git config --global core.editor $GitConfig.Editor
git config --global core.autocrlf $GitConfig.AutoCrlf
git config --global core.longpaths $GitConfig.LongPaths
git config --global credential.helper $GitConfig.CredentialHelper
git config --global fetch.prune $GitConfig.FetchPrune
git config --global color.ui $GitConfig.ColorUi
git config --global push.default $GitConfig.PushDefault
git config --global push.autoSetupRemote $GitConfig.PushAutoSetupRemote
git config --global rebase.autoStash $GitConfig.RebaseAutoStash
git config --global rerere.enabled $GitConfig.RerereEnabled

# ------------------------------------------------------------------------------------------------

# Safe directories
$Projects.PSObject.Properties.Value | ForEach-Object {
    $project = $_

    $existingSafeDirs = git config --global --get-all safe.directory 2>$null
    if ($existingSafeDirs -notcontains $project.LocalPath) {
        git config --global --add safe.directory $project.LocalPath
        Write-OkMessage -Title "Git Config" -Message "Added safe.directory: $($project.LocalPath)"
    }
}

# ------------------------------------------------------------------------------------------------

# Per-repo user identity (--local takes precedence over --global)
$Projects.PSObject.Properties.Value | ForEach-Object {
    $project = $_

    if (Test-Path (Join-Path $project.LocalPath '.git')) {
        Push-Location $project.LocalPath
        if ($project.UserName) { git config --local user.name  $project.UserName }
        if ($project.UserEmail) { git config --local user.email $project.UserEmail }
        Pop-Location
    }
    else {
        Write-WarnMessage -Title $project.Name -Message "Repo not found at $($project.LocalPath) — skipping local identity config"
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

Write-Host "git config --global --get-all safe.directory:`n" -ForegroundColor Cyan -NoNewLine
git config --global --get-all safe.directory | ForEach-Object { Write-Host " + $_" }
Write-NewLine

Write-Host "git config --local user.name / user.email (per project):`n" -ForegroundColor Cyan -NoNewLine
$Projects.PSObject.Properties.Value | ForEach-Object {
    if (Test-Path (Join-Path $_.LocalPath '.git')) {
        Push-Location $_.LocalPath
        $localName = git config --local user.name  2>$null
        $localEmail = git config --local user.email 2>$null
        Write-Host " + $($_.Name): $localName <$localEmail>"
        Pop-Location
    }
}
Write-NewLine


# ------------------------------------------------------------------------------------------------

Write-OkMessage -Title "Git Config" -Message "Global git settings configured."