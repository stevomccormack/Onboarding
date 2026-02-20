# 30 - git-clone.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "Projects: Git Clone"

# ------------------------------------------------------------------------------------------------
# For each project in $Projects:
#   - If local .git does not exist → clone from SSH remote
#   - If local .git exists         → fetch (connect/verify only, no commits)
# ------------------------------------------------------------------------------------------------

$projects = $Projects.PSObject.Properties.Value | Where-Object { $_ }

if (-not $projects -or @($projects).Count -eq 0) {
    Write-WarnMessage -Title "Projects" -Message "No projects found in `$Projects"
    return
}

$results = @{ Cloned = 0; Connected = 0; Failed = 0 }

foreach ($project in @($projects)) {

    Write-Header "Project: $($project.Name)"
    Write-Var -Name "Local Path" -Value $project.LocalPath -NoIcon
    Write-Var -Name "Remote"     -Value $project.SshUrl    -NoIcon

    # ----------------------------------------------------------------
    # Case 1: Repo does not exist locally → clone
    # ----------------------------------------------------------------
    if (-not (Test-GitRepositoryIsInitialized -Path $project.LocalPath)) {

        Write-StatusMessage -Title $project.Name -Message "Not found locally — cloning..."

        # Ensure parent directory exists
        $parent = Split-Path $project.LocalPath -Parent
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }

        $cloneArgs = @('clone', $project.SshUrl, $project.LocalPath)
        if ($project.MainBranch) { $cloneArgs += '--branch'; $cloneArgs += $project.MainBranch }

        & git @cloneArgs 2>&1 | ForEach-Object { Write-Host "  $_" }

        if ($LASTEXITCODE -eq 0) {
            Write-OkMessage -Title $project.Name -Message "Cloned successfully"
            $results.Cloned++
        }
        else {
            Write-FailMessage -Title $project.Name -Message "Clone failed (exit $LASTEXITCODE)"
            $results.Failed++
            Write-NewLine
            continue
        }
    }

    # ----------------------------------------------------------------
    # Case 2: Repo exists → fetch to verify connection (read-only)
    # ----------------------------------------------------------------
    else {

        Write-Status "$($project.Name) already exists!"
        Write-Status "Lets confirm the remote connection is working" -ForegroundColor DarkGray

        Push-Location $project.LocalPath

        # Show configured remote URL — no changes made
        $currentRemote = git remote get-url origin 2>$null
        Write-Var -Name "Remote URL" -Value $currentRemote -NoIcon

        # ls-remote: pure SSH connectivity test — reads remote HEAD, writes nothing locally
        $lsOutput = & git ls-remote origin HEAD 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-OkMessage -Title $project.Name -Message "Connected — remote reachable"
            $results.Connected++
        }
        else {
            Write-FailMessage -Title $project.Name -Message "Remote unreachable (exit $LASTEXITCODE) — check SSH keys / remote URL"
            if ($lsOutput) { Write-Host "  $lsOutput" }
            $results.Failed++
        }

        Pop-Location
    }

    Write-NewLine
}