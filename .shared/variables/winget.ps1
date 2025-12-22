# .shared/variables/winget.ps1

# -------------------------------------------------------------------------------------------------
# WinGet (Windows Package Manager) Configuration & Packages
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# WinGet Package Commands
# -------------------------------------------------------------------------------------------------
# Install a package:
#   winget install <package-id>
# Upgrade a package:
#   winget upgrade <package-id>
# Uninstall a package:
#   winget uninstall <package-id>
# List installed packages:
#   winget list
# Search for packages:
#   winget search <keyword>
# -------------------------------------------------------------------------------------------------

$wingetInstallUrl = 'https://learn.microsoft.com/en-us/windows/package-manager/winget/'
$wingetDocsUrl = 'https://learn.microsoft.com/en-us/windows/package-manager/winget/'
$wingetPackagesUrl = 'https://winget.run/'

$Winget = [pscustomobject]@{
    InstallUrl          = $wingetInstallUrl            # Installation instructions (included in Windows 11+)
    DocsUrl             = $wingetDocsUrl               # Documentation
    PackagesUrl         = $wingetPackagesUrl           # Package search
    
    # WinGet Configuration Settings
    Silent              = $true                        # Silent installation
    AcceptPackageAgreements = $true                    # Accept package agreements
    AcceptSourceAgreements  = $true                    # Accept source agreements
    DisableInteractivity    = $true                    # Disable interactive prompts
    Verbose             = $false                       # Verbose output
    
    Packages = @(
        # Only include packages not available in Chocolatey or where WinGet is preferred
        @{ Id = 'Docker.DockerDesktop';   Enabled = $true;  Name = 'Docker Desktop';               CommandName = 'docker';        TestCommand = 'docker --version';                   Url = 'https://docker.com/products/docker-desktop/' }
    )
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Winget`t Variable:"
    $Winget | Format-List
}
