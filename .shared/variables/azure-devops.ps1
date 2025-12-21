# .shared/variables/azure-devops.ps1

# -------------------------------------------------------------------------------------------------
# Azure DevOps Variables
# -------------------------------------------------------------------------------------------------

$azureDevOpsHost            = "dev.azure.com"
$azureDevOpsHostUrl         = "https://$azureDevOpsHost"
$azureDevOpsSshHost         = 'ssh.dev.azure.com'
$azureDevOpsSshKeyType      = 'rsa'    # Must be rsa!
$azureDevOpsSshKeyBits      = 4096     # Only used if sshKeyType is 'rsa'

# -------------------------------------------------------------------------------------------------

$AzureDevOps = [pscustomobject]@{
    Alias       = 'AzureDevOps'
    Name        = 'Azure DevOps'
    Host        = $azureDevOpsHost
    HostUrl     = $azureDevOpsHostUrl    
    NewSshKeyUrlFormat   = "$azureDevOpsHostUrl/{0}/_usersSettings/keys"
    NewPatTokenUrlFormat = "$azureDevOpsHostUrl/{0}/_usersSettings/tokens"
    Ssh = [pscustomobject]@{
        Host     = $azureDevOpsSshHost
        User     = 'git'
        KeyType  = $azureDevOpsSshKeyType
        KeyBits  = $azureDevOpsSshKeyBits        
    }
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled){

    Write-Header "`$AzureDevOps` Variable:"
    $AzureDevOps | Format-List
}