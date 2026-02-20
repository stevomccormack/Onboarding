# .shared/variables/node.ps1

# -------------------------------------------------------------------------------------------------
# Node Variables
# -------------------------------------------------------------------------------------------------

$nodeInstallUrl = 'https://nodejs.org/en/download/'
$nodeDocsUrl = 'https://nodejs.org/en/docs/'

$Node = [pscustomobject]@{
    Id          = 'nodejs'
    Enabled     = $true                         # Enable Node.js installation
    Name        = 'Node.js'
    CommandName = 'node'
    TestCommand = 'node --version'
    Description = 'JavaScript runtime (includes npm)'
    WingetId    = 'OpenJS.NodeJS.LTS'           # winget install --exact --id OpenJS.NodeJS.LTS --source winget
    ChocoId     = 'nodejs'                      # choco install nodejs
    InstallUrl  = $nodeInstallUrl               # Installation page
    DocsUrl     = $nodeDocsUrl                  # Documentation
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Node` Variables:"
    $Node | Format-List
}
