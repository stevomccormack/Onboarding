# 20 - ssh-init.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "SSH Configuration"

# ------------------------------------------------------------------------------------------------

$sshProfiles = @(
    $Ssh.Steve.GitHub
    $Ssh.Steve.AzureDevOps
    $Ssh.MWeb.GitHub
    $Ssh.MWeb.AzureDevOps
) | Where-Object { $_ -and $_.Enabled }

if (-not $sshProfiles -or @($sshProfiles).Count -eq 0) {
    Write-WarnMessage -Title "SSH Profiles" -Message "No enabled profiles found"
    return
}

# ------------------------------------------------------------------------------------------------
# SSH Directory: ensure exists + optional backup + optional clear
# ------------------------------------------------------------------------------------------------
Write-Header "SSH Directory"

# Ensure SSH directory
if (-not (Test-EnsureDirectory -Path $Ssh.Root)) { return $false }

# Backup SSH directory
if ($Ssh.BackupEnabled) {
    Write-StatusMessage -Title "SSH Directory" -Message "Backing up $($Ssh.Root)"
    $sshBackupDirName = ".ssh.bak.$((Get-Date).ToString('yyyyMMdd_HHmmss'))"
    $sshBackupDestPath = [System.IO.Path]::Combine($HOME, $sshBackupDirName)
    New-BackupDirectory -SourcePath $Ssh.Root -DestinationPath $sshBackupDestPath | Out-Null
    
    Write-OkMessage -Title "SSH Directory" -Message "Backed up to $sshBackupDestPath"
}
else {
    Write-StatusMessage -Title "SSH Directory" -Message "Skipped backup (not enabled)"
}

# Clear SSH directory
if ($Ssh.ClearEnabled) {
    Write-StatusMessage -Title "SSH Directory" -Message "Clearing SSH directory"
    Clear-Directory -Path $Ssh.Root | Out-Null
}

# Open in Explorer
if ($Ssh.OpenInExplorer) {
    Write-StatusMessage -Title "SSH Directory" -Message "Opening SSH directory"
    Start-Process -FilePath "explorer.exe" -ArgumentList "`"$($Ssh.Root)`""
}

# ------------------------------------------------------------------------------------------------
# SSH Known Hosts: ensure known_hosts file + optional pre-seed
# ------------------------------------------------------------------------------------------------
Write-Header "SSH Known Hosts"

# Ensure known_hosts file
if (-not (Test-EnsureSshKnownHosts -SshRootPath $Ssh.Root)) { return $false }

# Configure known hosts
if ($Ssh.UseKnownHosts) {
    $hosts = @($sshProfiles | ForEach-Object { $_.HostName } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
    foreach ($h in $hosts) {
        New-SshKnownHostKey -HostName $h -KnownHostsPath $Ssh.KnownHostsPath | Out-Null
    }
}
else {
    Write-StatusMessage -Title "SSH Known Hosts" -Message "Skipped: known_hosts configuration (not enabled)"
}

# ------------------------------------------------------------------------------------------------
# SSH Agent: clear all existing keys if enabled
# ------------------------------------------------------------------------------------------------
if ($Ssh.UseSshAgent) {
    if ($Ssh.ClearSshAgentKeys) {
        if (Clear-SshAgentKeys  ) {
            Write-OkMessage -Title "SSH Agent" -Message "Cleared existing keys from ssh-agent"
        }
        else {
            Write-WarnMessage -Title "SSH Agent" -Message "Failed to clear existing keys from ssh-agent"
        }
    }
}

# ------------------------------------------------------------------------------------------------
# SSH Profiles: key generation, agent addition, provider registration, connection test
# ------------------------------------------------------------------------------------------------
Write-Header "SSH Profiles"

foreach ($p in @($sshProfiles)) {

    if ($null -eq $p) { continue }

    Write-StatusMessage -Title "SSH Profile" -Message "Loading profile alias: $($p.HostAlias)"
    Write-Var -Name "Provider" -Value $p.Provider -NoNewLine -NoIcon
    Write-Var -Name "Org" -Value $p.Org -NoNewLine -NoIcon
    Write-Var -Name "Host" -Value $p.HostName -NoNewLine -NoIcon
    Write-Var -Name "KeyType" -Value $p.KeyType -NoIcon

    # Preflight Tests
    if (-not (Test-SshPreflight -SshProfile $p)) { continue }

    # Key Generation
    Write-StatusMessage -Title "SSH KeyGen:" -Message "Generating ssh key (overwrite=$($p.ForceNewKey))"
    $pub = New-SshKey -KeyFilePath $p.KeyFilePath -KeyType $p.KeyType -KeyComment "$($p.Email) ($env:USERNAME@$env:COMPUTERNAME)" -Force:$p.ForceNewKey -CopyPublicKeyToClipboard
    if (-not $pub) { Write-WarnMessage -Title "SSH KeyGen" -Message "Failed! Skipping key gen"; continue }

    # SSH Agent
    if ($Ssh.UseSshAgent) {
        Write-StatusMessage -Title "SSH Agent" -Message "Adding key to agent service"
        if (Test-EnsureSshAgent -StartupType Automatic -StartService) {
            New-SshAgentKey -KeyFilePath $p.KeyFilePath | Out-Null
        }
        else {
            Write-WarnMessage -Title "SSH Agent" -Message "Unavailable! Ensure the ssh-agent service is running."
        }
    }

    # Register SSH Key with provider
    if ($Ssh.RegisterProviderKeys) {
        Write-StatusMessage -Title "SSH Register" -Message "Registering provider key"

        switch ($p.Provider) {
            ([GitProvider]::GitHub) {
                Register-GitHubSshKey -PublicKeyPath $pub -Title $p.HostAlias -PersonalAccessToken $p.AccessToken | Out-Null
            }
            ([GitProvider]::AzureDevOps) {
                Register-AzureDevOpsSshKey -PublicKeyPath $pub -OrgName $p.Org -FriendlyName $p.HostAlias | Out-Null
            }
            default {
                Write-WarnMessage -Title "SSH Register" -Message "Unknown provider '$($p.Provider)'. Skipping registration."
                Write-Warn "Available providers: GitHub, AzureDevOps." -NoIcon  
                Write-Warn "Ensure you upload the public key manually." -NoIcon
            }
        }
    }

    # Test SSH Connection
    if ($Ssh.TestConnection) {
        Write-StatusMessage -Title "SSH Test" -Message "Testing SSH connection to host name $($p.HostName)"
        Test-SshConnection -UserName 'git' -HostName $p.HostName -IdentityFilePath $p.KeyFilePath -Description $p.HostAlias | Out-Null
    }

    # Debug SSH Connection
    if ($Ssh.DebugConnection) {
        Write-StatusMessage -Title "SSH Debug" -Message "Debugging SSH connection to host name $($p.HostName)"
        Test-SshDebug -HostName $p.HostName -UserName 'git' -IdentityFilePath $p.KeyFilePath | Out-Null
    }
}

# ------------------------------------------------------------------------------------------------
# Write SSH config
# ------------------------------------------------------------------------------------------------
Write-Header "SSH Config"
Write-Var -Name "SSH Config Path" -Value $Ssh.ConfigPath

if (Test-Path -LiteralPath $Ssh.ConfigPath -PathType Leaf) {
    Write-StatusMessage -Title "SSH Config" -Message "Backing up SSH config file"
    New-BackupFile -Path $Ssh.ConfigPath | Out-Null
}

$blocks = New-SshConfigBlocks -SshProfiles $sshProfiles
if (-not $blocks -or @($blocks).Count -eq 0) {
    Write-FailMessage -Title "SSH Config" -Message "No configuration generated"
    return $false
}

Write-StatusMessage -Title "SSH Config" -Message "Writing SSH config file"
if (-not (Set-SshConfigFile -ConfigPath $Ssh.ConfigPath -ConfigBlocks $blocks)) { return $false }

Write-OkMessage -Title "SSH Config" -Message "Completed SSH config: $($Ssh.ConfigPath)"


# ------------------------------------------------------------------------------------------------
# OneDrive Directory: backup .ssh to OneDrive
# ------------------------------------------------------------------------------------------------
Write-Header "SSH Backup to OneDrive"

if ($Ssh.OneDriveBackupEnabled) {

    # Ensure OneDrive directory
    if (-not (Test-EnsureDirectory -Path $OneDrive.SshDir)) { return $false }

    # Clear OneDrive directory
    if ($OneDrive.ClearEnabled) {
        Write-StatusMessage -Title "OneDrive" -Message "Clearing SSH in OneDrive"
        Clear-Directory -Path $OneDrive.SshDir | Out-Null
    } 
    # Backup .ssh to OneDrive
    Write-StatusMessage -Title "OneDrive" -Message "Backing up SSH to OneDrive"
    $oneDriveBackupDestPath = [System.IO.Path]::Combine($OneDrive.SshDir, "$((Get-Date).ToString('yyyyMMdd_HHmmss')).bak")
    New-BackupDirectory -SourcePath $Ssh.Root -DestinationPath $oneDriveBackupDestPath | Out-Null

    # Open in Explorer
    if ($OneDrive.OpenInExplorer) {
        Write-StatusMessage -Title "OneDrive" -Message "Opening SSH OneDrive directory..."
        Start-Process -FilePath "explorer.exe" -ArgumentList "`"$($OneDrive.SshDir)`""
    }
}
else {
    Write-StatusMessage -Title "OneDrive" -Message "Skipped backup to OneDrive (not enabled)"
}