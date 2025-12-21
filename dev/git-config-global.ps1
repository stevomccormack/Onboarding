. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "Global Git Configuration"
Write-Status "Configuring global git settings..."

# ------------------------------------------------------------------------------------------------

git config --global core.editor "code --wait"              # Set VS Code as default editor
git config --global core.autocrlf true                     # Line ending handling (Windows)
git config --global core.longpaths true                    # Long paths support (Windows)
git config --global credential.helper manager-core         # Credential helper
git config --global fetch.prune true                       # Auto-cleanup deleted remote branches
git config --global color.ui auto                          # Colorized output
git config --global push.default simple                    # Push only current branch
git config --global rebase.autoStash true                  # Auto-stash during rebase
git config --global rerere.enabled true                    # Reuse recorded conflict resolutions

# ------------------------------------------------------------------------------------------------

Write-Var -Name "git --global config core.editor" -Value (git config --global core.editor)
Write-Var -Name "git --global config core.autocrlf" -Value (git config --global core.autocrlf)
Write-Var -Name "git --global config core.longpaths" -Value (git config --global core.longpaths)
Write-Var -Name "git --global config credential.helper" -Value (git config --global credential.helper)
Write-Var -Name "git --global config fetch.prune" -Value (git config --global fetch.prune)
Write-Var -Name "git --global config color.ui" -Value (git config --global color.ui)
Write-Var -Name "git --global config push.default" -Value (git config --global push.default)
Write-Var -Name "git --global config rebase.autoStash" -Value (git config --global rebase.autoStash)
Write-Var -Name "git --global config rerere.enabled" -Value (git config --global rerere.enabled)

# ------------------------------------------------------------------------------------------------

Write-OkMessage -Title "Git Config" -Message "Global git settings configured."