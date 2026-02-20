# .shared/variables/kubectl.ps1

# -------------------------------------------------------------------------------------------------
# kubectl Variables
# -------------------------------------------------------------------------------------------------

$kubectlInstallUrl = 'https://kubernetes.io/docs/tasks/tools/'
$kubectlDocsUrl = 'https://kubernetes.io/docs/reference/kubectl/'

$Kubectl = [pscustomobject]@{
    Id          = 'kubectl'
    Enabled     = $true                         # Enable kubectl installation
    Name        = 'kubectl'
    CommandName = 'kubectl'
    TestCommand = 'kubectl version --client'
    Description = 'Kubernetes command-line tool'
    WingetId    = 'Kubernetes.kubectl'          # winget install --exact --id Kubernetes.kubectl --source winget
    ChocoId     = 'kubernetes-cli'              # choco install kubernetes-cli
    InstallUrl  = $kubectlInstallUrl            # Installation page
    DocsUrl     = $kubectlDocsUrl               # Documentation
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Kubectl` Variable:"
    $Kubectl | Format-List
}
