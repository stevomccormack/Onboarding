# 10 - cli-install.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "CLI Tool Installation"

# ------------------------------------------------------------------------------------------------
# CLI Tools: Filter enabled tools
# ------------------------------------------------------------------------------------------------
Write-Header "CLI Tools Configuration"

$cliTools = $Cli.Tools | Where-Object { $_ -and $_.Enabled }

if (-not $cliTools -or @($cliTools).Count -eq 0) {
    Write-WarnMessage -Title "CLI Tools" -Message "No enabled CLI tools found"
    return
}

Write-Status "Found $($cliTools.Count) enabled CLI tool(s) to install"
Write-NewLine

# ------------------------------------------------------------------------------------------------
# Display CLI Tools Summary
# ------------------------------------------------------------------------------------------------
Write-Header "CLI Tools Summary"

foreach ($tool in $cliTools) {
    Write-Var -Name $tool.Name -Value "$($tool.Id) ($($tool.CommandName))" -NoIcon
}
Write-NewLine

# ------------------------------------------------------------------------------------------------
# Check Existing Installations
# ------------------------------------------------------------------------------------------------
Write-Header "Checking Existing Installations"

foreach ($tool in $cliTools) {
    $commandExists = Get-Command -Name $tool.CommandName -ErrorAction SilentlyContinue
    
    if ($commandExists) {
        Write-OkMessage -Title $tool.Name -Message "Already installed: $($tool.CommandName)"
    }
    else {
        Write-StatusMessage -Title $tool.Name -Message "Not found: $($tool.CommandName)"
    }
}
Write-NewLine

# ------------------------------------------------------------------------------------------------
# Install Chocolatey Package Manager (if needed)
# ------------------------------------------------------------------------------------------------
Write-Header "Chocolatey Package Manager"

$chocoInstalled = Install-Chocolatey
if (-not $chocoInstalled) {
    Write-FailMessage -Title "CLI Installation" -Message "Cannot proceed without Chocolatey package manager"
    return
}
Write-NewLine

# ------------------------------------------------------------------------------------------------
# Install CLI Tools via Chocolatey
# ------------------------------------------------------------------------------------------------
Write-Header "Installing CLI Tools"

# Install each CLI tool
foreach ($tool in $cliTools) {
    # Skip if already installed
    $commandExists = Get-Command -Name $tool.CommandName -ErrorAction SilentlyContinue
    
    if ($commandExists) {
        Write-StatusMessage -Title $tool.Name -Message "Skipping (already installed)"
        continue
    }
    
    Write-Status -Title "Installing" -Message "$($tool.Name) ($($tool.Id))"
    
    # Build Chocolatey install command arguments
    $chocoArgs = @('install', $tool.Id)
    
    if ($Choco.Yes) { $chocoArgs += '--yes' }
    if ($Choco.AcceptLicense) { $chocoArgs += '--accept-license' }
    if ($Choco.Force) { $chocoArgs += '--force' }
    if ($Choco.Verbose) { $chocoArgs += '--verbose' }
    
    # Execute installation
    & choco @chocoArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-OkMessage -Title $tool.Name -Message "Successfully installed"
    }
    else {
        Write-FailMessage -Title $tool.Name -Message "Installation failed (Exit Code: $LASTEXITCODE)"
        Write-Status "Manual installation URL: $($tool.InstallUrl)"
    }
    
    Write-NewLine
}

# ------------------------------------------------------------------------------------------------
# Verify Installations
# ------------------------------------------------------------------------------------------------
Write-Header "Verifying CLI Tool Installations"

foreach ($tool in $cliTools) {
    $commandExists = Get-Command -Name $tool.CommandName -ErrorAction SilentlyContinue
    
    if ($commandExists) {
        Write-Status -Title $tool.Name -Message "Testing: $($tool.TestCommand)"
        
        try {
            $output = Invoke-Expression $tool.TestCommand 2>&1
            Write-OkMessage -Title $tool.Name -Message "Verified: $($tool.CommandName) is working"
        }
        catch {
            Write-WarnMessage -Title $tool.Name -Message "Command exists but test failed"
        }
    }
    else {
        Write-FailMessage -Title $tool.Name -Message "Not found: $($tool.CommandName)"
    }
}

Write-NewLine
Write-OkMessage -Title "CLI Installation" -Message "Completed"