# .shared/variables/github-cli.ps1

# -------------------------------------------------------------------------------------------------
# GitHub CLI Extensions Configuration & Management
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# GitHub CLI Extension Commands
# -------------------------------------------------------------------------------------------------
# List installed extensions:
#   gh extension list
# Install an extension:
#   gh extension install <owner/repo>
# Upgrade all extensions:
#   gh extension upgrade --all
# Remove an extension:
#   gh extension remove <owner/repo>
# Browse available extensions:
#   gh extension browse
# Search for extensions:
#   gh search repos --topic gh-extension
# -------------------------------------------------------------------------------------------------

$ghInstallUrl = 'https://cli.github.com/'
$ghDocsUrl = 'https://cli.github.com/manual/'
$ghExtensionsUrl = 'https://github.com/topics/gh-extension'

$Gh = [pscustomobject]@{
    InstallUrl          = $ghInstallUrl                # GitHub CLI installation
    DocsUrl             = $ghDocsUrl                   # Documentation
    ExtensionsUrl       = $ghExtensionsUrl             # Available extensions
    
    # GitHub CLI Configuration Settings
    Force               = $false                       # Force installation
    Pin                 = $false                       # Pin extension to specific version
    
    Extensions = @(
        # AI & Development
        @{ Id = 'github/gh-copilot';      Enabled = $true;  Name = 'GitHub Copilot CLI';           CommandName = 'gh'; TestCommand = 'gh copilot --version';               Url = 'https://github.com/github/gh-copilot' }
        
        # Repository Management
        @{ Id = 'dlvhdr/gh-dash';         Enabled = $true;  Name = 'GitHub Dashboard';             CommandName = 'gh'; TestCommand = 'gh dash --version';                  Url = 'https://github.com/dlvhdr/gh-dash' }
        @{ Id = 'mislav/gh-branch';       Enabled = $false; Name = 'Branch Manager';               CommandName = 'gh'; TestCommand = 'gh branch --help';                   Url = 'https://github.com/mislav/gh-branch' }
        
        # Actions & Workflows
        @{ Id = 'github/gh-actions-cache'; Enabled = $true; Name = 'GitHub Actions Cache';         CommandName = 'gh'; TestCommand = 'gh actions-cache --help';            Url = 'https://github.com/github/gh-actions-cache' }
        
        # Security
        @{ Id = 'github/gh-sbom';         Enabled = $true;  Name = 'SBOM Generator';               CommandName = 'gh'; TestCommand = 'gh sbom --help';                     Url = 'https://github.com/github/gh-sbom' }
    )
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Gh` Variable:"
    $Gh | Format-List
}
