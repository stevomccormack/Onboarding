# .shared/variables/docker.ps1

# -------------------------------------------------------------------------------------------------
# Docker Desktop Variables
# -------------------------------------------------------------------------------------------------

$dockerInstallUrl = 'https://www.docker.com/products/docker-desktop/'
$dockerDocsUrl = 'https://docs.docker.com/'

$Docker = [pscustomobject]@{
    Id          = 'docker'
    Enabled     = $true                         # Enable Docker Desktop installation
    Name        = 'Docker Desktop'
    CommandName = 'docker'
    TestCommand = 'docker --version'
    Description = 'Container platform for building and running applications'
    WingetId    = 'Docker.DockerDesktop'        # winget install --exact --id Docker.DockerDesktop --source winget
    ChocoId     = 'docker-desktop'              # choco install docker-desktop
    InstallUrl  = $dockerInstallUrl             # Installation page
    DocsUrl     = $dockerDocsUrl                # Documentation
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Docker` Variable:"
    $Docker | Format-List
}
