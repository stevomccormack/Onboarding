# -------------------------------------------------------------------------------------------------
# SSH Variables
# -------------------------------------------------------------------------------------------------

$sshRootPath   = [System.IO.Path]::Combine($HOME, '.ssh')
$sshConfigPath = [System.IO.Path]::Combine($sshRootPath, 'config')
$sshKnownHostsPath = [System.IO.Path]::Combine($sshRootPath, 'known_hosts')

# -------------------------------------------------------------------------------------------------

$Ssh = [pscustomobject]@{
    Root                    = $sshRootPath         # SSH root directory
    ConfigPath              = $sshConfigPath       # Path to SSH config file
    KnownHostsPath          = $sshKnownHostsPath   # Path to known_hosts file
    UseKnownHosts           = $true                # Whether to ensure known_hosts entries
    BackupEnabled           = $true                # Whether to backup .ssh directory to local backups
    OneDriveBackupEnabled   = $true                # Whether to backup .ssh directory to OneDrive
    ClearEnabled            = $true                # Whether to clear existing SSH directory contents
    OpenInExplorer          = $true                # Whether to open the SSH directory in Explorer after setup
    UseSshAgent             = $true                # Whether to use the SSH agent for key management
    RegisterProviderKeys    = $true                # Whether to register SSH keys with providers (GitHub, ADO)
    TestConnection          = $true                # Whether to test SSH connection after setup
    DebugConnection         = $true                # Whether to run an interactive SSH debug session after setup

    Steve = [pscustomobject]@{
        GitHub = (& New-SshProfile `
            -Provider ([GitProvider]::GitHub) `
            -Org 'stevomccormack' `
            -Email 'hello@iamstevo.co' `
            -AccessToken $Env:STEVE_GITHUB_PAT `
            -HostAlias "$($GitHub.Alias.ToLower())-stevomccormack" `
            -HostName "$($GitHub.Ssh.Host)" `
            -KeyType $GitHub.Ssh.KeyType `
            -KeyPrefix "$($GitHub.Alias.ToLower())_stevomccormack" `
            -SshRootPath $sshRootPath `
            -KeyPassphrase '' `
            -ForceNewKey $false)

        AzureDevOps = (& New-SshProfile `
            -Provider ([GitProvider]::AzureDevOps) `
            -Org 'stevomccormack' `
            -Email 'stevomccormack@live.com' `
            -AccessToken $Env:STEVE_AZURE_DEVOPS_PAT `
            -HostAlias "$($AzureDevOps.Alias.ToLower())-stevomccormack" `
            -HostName "$($AzureDevOps.Ssh.Host)" `
            -KeyType $AzureDevOps.Ssh.KeyType `
            -KeyPrefix "$($AzureDevOps.Alias.ToLower())_stevomccormack" `
            -SshRootPath $sshRootPath `
            -KeyPassphrase '' `
            -ForceNewKey $false)
    }

    MWeb = [pscustomobject]@{
        GitHub = (& New-SshProfile `
            -Provider ([GitProvider]::GitHub) `
            -Org 'mwebsolutions' `
            -Email 'steve@mweb.co' `
            -AccessToken $Env:MWEB_GITHUB_PAT `
            -HostAlias "$($GitHub.Alias.ToLower())-mwebsolutions" `
            -HostName "$($GitHub.Ssh.Host)" `
            -KeyType $GitHub.Ssh.KeyType `
            -KeyPrefix "$($GitHub.Alias.ToLower())_mwebsolutions" `
            -SshRootPath $sshRootPath `
            -KeyPassphrase '' `
            -ForceNewKey $false)

        AzureDevOps = (& New-SshProfile `
            -Provider ([GitProvider]::AzureDevOps) `
            -Org 'mwebsolutions' `
            -Email 'steve@mweb.co' `
            -AccessToken $Env:MWEB_AZURE_DEVOPS_PAT `
            -HostAlias "$($AzureDevOps.Alias.ToLower())-mwebsolutions" `
            -HostName "$($AzureDevOps.Ssh.Host)" `
            -KeyType $AzureDevOps.Ssh.KeyType `
            -KeyPrefix "$($AzureDevOps.Alias.ToLower())_mwebsolutions" `
            -SshRootPath $sshRootPath `
            -KeyPassphrase '' `
            -ForceNewKey $false)
    }

    Global = [pscustomobject]@{
        Config = New-SshFallbackConfigBlock
    }
}

# -------------------------------------------------------------------------------------------------
# SSH Configuration
# ~/.ssh/config
# -------------------------------------------------------------------------------------------------

$SshConfig = [pscustomobject]@{
    Steve  = ( @($Ssh.Steve.GitHub, $Ssh.Steve.AzureDevOps) | ForEach-Object {
        New-SshHostConfigBlock -HostAlias $_.HostAlias -HostName $_.HostName -IdentityFileName $_.KeyFileName
    } ) -join "`n`n"

    MWeb   = ( @($Ssh.MWeb.GitHub, $Ssh.MWeb.AzureDevOps) | ForEach-Object {
        New-SshHostConfigBlock -HostAlias $_.HostAlias -HostName $_.HostName -IdentityFileName $_.KeyFileName
    } ) -join "`n`n"

    Global = $Ssh.Global.Config
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "SSH Variables (`$Ssh`):"
    Write-ObjectPathTree -Object $Ssh -RootPath '$Ssh'
}
