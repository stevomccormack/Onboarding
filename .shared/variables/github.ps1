# -------------------------------------------------------------------------------------------------
# GitHub Variables
# -------------------------------------------------------------------------------------------------

$gitHubHost            = "github.com"
$gitHubHostUrl         = "https://$gitHubHost"
$gitHubSshHost         = 'github.com'
$gitHubSshKeyType      = 'ed25519'    # Options: 'ed25519' or 'rsa'
$gitHubSshKeyBits      = 4096         # Only used if sshKeyType is 'rsa'

# -------------------------------------------------------------------------------------------------

$GitHub = [pscustomobject]@{
    Alias           = 'GitHub'
    Name            = 'GitHub'
    Host            = $gitHubHost
    HostUrl         = $gitHubHostUrl
    NewSshKeyUrl    = "https://github.com/settings/ssh/new"
    NewPatTokenUrl  = "https://github.com/settings/personal-access-tokens/new"
    Ssh = [pscustomobject]@{
        Host        = $gitHubSshHost
        User        = 'git'
        KeyType     = $gitHubSshKeyType
        KeyBits     = $gitHubSshKeyBits        
    }
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled){

    Write-Header "$($GitHub.Name) Variables:"
    Write-ObjectPathTree -Object $GitHub.Ssh -RootPath '$GitHub'
}