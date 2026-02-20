# .shared/variables/terraform.ps1

# -------------------------------------------------------------------------------------------------
# Terraform Variables
# -------------------------------------------------------------------------------------------------

$terraformInstallUrl = 'https://developer.hashicorp.com/terraform/install'
$terraformDocsUrl = 'https://developer.hashicorp.com/terraform/docs'

$Terraform = [pscustomobject]@{
    Id          = 'terraform'
    Enabled     = $true                         # Enable Terraform installation
    Name        = 'Terraform'
    CommandName = 'terraform'
    TestCommand = 'terraform --version'
    Description = 'Infrastructure as Code tool by HashiCorp'
    WingetId    = 'Hashicorp.Terraform'         # winget install --exact --id Hashicorp.Terraform --source winget
    ChocoId     = 'terraform'                   # choco install terraform
    InstallUrl  = $terraformInstallUrl          # Installation page
    DocsUrl     = $terraformDocsUrl             # Documentation
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Terraform` Variable:"
    $Terraform | Format-List
}
