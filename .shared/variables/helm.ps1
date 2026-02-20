# .shared/variables/helm.ps1

# -------------------------------------------------------------------------------------------------
# Helm Variables
# -------------------------------------------------------------------------------------------------

$helmInstallUrl = 'https://helm.sh/docs/intro/install/'
$helmDocsUrl = 'https://helm.sh/docs/'

$Helm = [pscustomobject]@{
    Id          = 'helm'
    Enabled     = $true                         # Enable Helm installation
    Name        = 'Helm'
    CommandName = 'helm'
    TestCommand = 'helm version'
    Description = 'Kubernetes package manager'
    WingetId    = 'Helm.Helm'                   # winget install --exact --id Helm.Helm --source winget
    ChocoId     = 'kubernetes-helm'             # choco install kubernetes-helm
    InstallUrl  = $helmInstallUrl               # Installation page
    DocsUrl     = $helmDocsUrl                  # Documentation
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Helm` Variable:"
    $Helm | Format-List
}
