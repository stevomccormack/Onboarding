# .shared/variables/powershell.ps1

# -------------------------------------------------------------------------------------------------
# PowerShell Core Variables
# -------------------------------------------------------------------------------------------------

$powershellInstallUrl = 'https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows'
$powershellDocsUrl = 'https://learn.microsoft.com/en-us/powershell/'

$Powershell = [pscustomobject]@{
    Id          = 'powershell-core'
    Enabled     = $true                         # Enable PowerShell Core installation
    Name        = 'PowerShell Core'
    CommandName = 'pwsh'
    TestCommand = 'pwsh --version'
    Description = 'Cross-platform PowerShell (pwsh)'
    WingetId    = 'Microsoft.PowerShell'        # winget install --exact --id Microsoft.PowerShell --source winget
    ChocoId     = 'powershell-core'             # choco install powershell-core
    InstallUrl  = $powershellInstallUrl         # Installation page
    DocsUrl     = $powershellDocsUrl            # Documentation
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Powershell` Variable:"
    $Powershell | Format-List
}
