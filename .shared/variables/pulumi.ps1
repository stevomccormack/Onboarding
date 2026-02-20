# .shared/variables/pulumi.ps1

# -------------------------------------------------------------------------------------------------
# Pulumi Variables
# -------------------------------------------------------------------------------------------------

$pulumiInstallUrl = 'https://www.pulumi.com/docs/iac/download-install/'
$pulumiDocsUrl = 'https://www.pulumi.com/docs/'

$Pulumi = [pscustomobject]@{
    Id          = 'pulumi'
    Enabled     = $true                         # Enable Pulumi installation
    Name        = 'Pulumi'
    CommandName = 'pulumi'
    TestCommand = 'pulumi version'
    Description = 'Modern Infrastructure as Code platform'
    WingetId    = 'Pulumi.Pulumi'               # winget install --exact --id Pulumi.Pulumi --source winget
    ChocoId     = 'pulumi'                      # choco install pulumi
    InstallUrl  = $pulumiInstallUrl             # Installation page
    DocsUrl     = $pulumiDocsUrl                # Documentation
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Pulumi` Variable:"
    $Pulumi | Format-List
}
