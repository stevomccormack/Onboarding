# 14 - cli-install.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "CLI Installation"

# ------------------------------------------------------------------------------------------------

$cliTools = $Cli.Tools | Where-Object { $_ -and $_.Enabled }
if (-not $cliTools -or @($cliTools).Count -eq 0) {
    Write-WarnMessage -Title 'CLI Tools' -Message 'No enabled CLI found in $Cli.Tools'
    return
}

Write-Status "Listing CLI to install:"
$cliTools | Select-Object Id, Name, WingetId, ChocoId | Format-Table -AutoSize | Out-Host
Write-NewLine

# ------------------------------------------------------------------------------------------------
# Pre-flight: check existing installations
# ------------------------------------------------------------------------------------------------
Write-Status "Preflight: Checking if already installed..."

$toInstall = [System.Collections.Generic.List[object]]::new()
$alreadyDone = [System.Collections.Generic.List[object]]::new()

foreach ($tool in $cliTools) {

    # npm and pip are bundled — detect only, never install separately
    $bundled = $tool.Id -in @('npm', 'pip', 'gem')

    $installed = Test-ToolInstalled `
        -CommandName $tool.CommandName `
        -Name        $tool.Name `
        -WingetId    $tool.WingetId `
        -ChocoId     $tool.ChocoId

    if ($installed) {
        try {
            $version = Invoke-Expression $tool.TestCommand 2>&1 | Select-Object -First 1
            Write-OkMessage -Title $tool.Name -Message $version
        }
        catch {
            Write-OkMessage -Title $tool.Name -Message "Already installed"
        }
        $alreadyDone.Add($tool)
    }
    elseif ($bundled) {
        Write-WarnMessage -Title $tool.Name -Message "Not found — install its parent runtime first ($($tool.Description))"
        $alreadyDone.Add($tool)   # don't queue for install
    }
    else {
        Write-StatusMessage -Title $tool.Name -Message "Not installed — queued"
        $toInstall.Add($tool)
    }
}

Write-NewLine

if ($toInstall.Count -eq 0) {
    Write-OkMessage -Title "CLI Tools" -Message "All enabled tools are already installed"
    Write-NewLine
    return
}

# ------------------------------------------------------------------------------------------------
# Install
# ------------------------------------------------------------------------------------------------
Write-Header "Installing CLI Tools"

$results = @{ Succeeded = 0; Failed = 0; Skipped = 0 }
foreach ($tool in $toInstall) {

    Write-Header $tool.Name

    # Standard install: Winget → Chocolatey
    $success = Install-CliTool `
        -Name        $tool.Name `
        -CommandName $tool.CommandName `
        -WingetId    $tool.WingetId `
        -ChocoId     $tool.ChocoId `
        -InstallUrl  $tool.InstallUrl

    if ($success) { $results.Succeeded++ } else { $results.Failed++ }

    Write-NewLine
}

# ------------------------------------------------------------------------------------------------
# Refresh PATH before verification (captures anything installed above)
# ------------------------------------------------------------------------------------------------
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
[System.Environment]::GetEnvironmentVariable('Path', 'User')

# ------------------------------------------------------------------------------------------------
# Verify all enabled tools
# ------------------------------------------------------------------------------------------------
Write-Header "Confirm Installations"

foreach ($tool in $cliTools) {
    $installed = Test-ToolInstalled `
        -CommandName $tool.CommandName `
        -Name        $tool.Name `
        -WingetId    $tool.WingetId `
        -ChocoId     $tool.ChocoId

    if ($installed) {
        try {
            $versionOutput = Invoke-Expression $tool.TestCommand 2>&1 | Select-Object -First 1
            Write-OkMessage -Title $tool.Name -Message $versionOutput
        }
        catch {
            Write-OkMessage -Title $tool.Name -Message "Installed (version check failed)"
        }
    }
    else {
        Write-FailMessage -Title $tool.Name -Message "Not found after install — restart session and re-run"
        Write-Var -Name "Manual URL" -Value $tool.InstallUrl -NoIcon
    }
}

Write-NewLine

# ------------------------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------------------------
Write-Header "Installation Summary"
Write-Var -Name "Succeeded" -Value $results.Succeeded -NoIcon
Write-Var -Name "Failed"    -Value $results.Failed    -NoIcon
Write-Var -Name "Skipped"   -Value $results.Skipped   -NoIcon
Write-NewLine

if ($results.Failed -gt 0) {
    Write-WarnMessage -Title "CLI Tools" -Message "$($results.Failed) tool(s) failed — check output above for manual install URLs"
}
else {
    Write-OkMessage -Title "CLI Tools" -Message "All installations completed successfully"
}
