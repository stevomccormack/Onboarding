# .shared/variables/npm.ps1

# -------------------------------------------------------------------------------------------------
# NPM (Node Package Manager) Configuration & Packages
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# NPM Global Package Commands
# -------------------------------------------------------------------------------------------------
# Install a global package:
#   npm install --global <package>
# Update a global package:
#   npm update --global <package>
# Uninstall a global package:
#   npm uninstall --global <package>
# List installed global packages:
#   npm list --global --depth=0
# -------------------------------------------------------------------------------------------------

$npmInstallUrl = 'https://docs.npmjs.com/downloading-and-installing-node-js-and-npm'
$npmDocsUrl = 'https://docs.npmjs.com/'
$npmPackagesUrl = 'https://npmjs.com/'

$Npm = [pscustomobject]@{
    Id          = 'npm'
    Enabled     = $true                            # Enable npm (included with Node.js)
    Name        = 'NPM'
    CommandName = 'npm'
    TestCommand = 'npm --version'
    Description = 'Node.js package manager (included with Node.js)'
    WingetId    = $null                            # Bundled with Node.js — no separate install
    ChocoId     = $null                            # Bundled with Node.js — no separate install
    InstallUrl  = $npmInstallUrl               # Installation instructions (comes with Node.js)
    DocsUrl     = $npmDocsUrl                  # Documentation
    PackagesUrl = $npmPackagesUrl              # Package registry
    
    # NPM Configuration Settings
    Yes         = $true                        # Assume yes to all prompts
    Silent      = $false                       # Silent output
    Verbose     = $false                       # Verbose output
    Force       = $false                       # Force installation
    
    Packages    = @(
        # API Development & Documentation
        @{ Id = '@openapitools/openapi-generator-cli'; Enabled = $true; Name = 'OpenAPI Generator CLI'; CommandName = 'openapi-generator-cli'; TestCommand = 'openapi-generator-cli version'; Url = 'https://npmjs.com/package/@openapitools/openapi-generator-cli' }
        @{ Id = '@redocly/cli'; Enabled = $true; Name = 'Redocly CLI'; CommandName = 'redocly'; TestCommand = 'redocly --version'; Url = 'https://npmjs.com/package/@redocly/cli' }
        @{ Id = 'swagger-cli'; Enabled = $true; Name = 'Swagger CLI'; CommandName = 'swagger-cli'; TestCommand = 'swagger-cli --version'; Url = 'https://npmjs.com/package/swagger-cli' }
        @{ Id = 'newman'; Enabled = $true; Name = 'Postman CLI (Newman)'; CommandName = 'newman'; TestCommand = 'newman --version'; Url = 'https://npmjs.com/package/newman' }
        
        # Code Quality & Formatting
        @{ Id = 'eslint'; Enabled = $true; Name = 'ESLint'; CommandName = 'eslint'; TestCommand = 'eslint --version'; Url = 'https://npmjs.com/package/eslint' }
        @{ Id = 'prettier'; Enabled = $true; Name = 'Prettier'; CommandName = 'prettier'; TestCommand = 'prettier --version'; Url = 'https://npmjs.com/package/prettier' }
        @{ Id = 'typescript'; Enabled = $true; Name = 'TypeScript'; CommandName = 'tsc'; TestCommand = 'tsc --version'; Url = 'https://npmjs.com/package/typescript' }
        
        # Build & Bundling
        @{ Id = 'vite'; Enabled = $false; Name = 'Vite'; CommandName = 'vite'; TestCommand = 'vite --version'; Url = 'https://npmjs.com/package/vite' }
        @{ Id = 'webpack-cli'; Enabled = $false; Name = 'Webpack CLI'; CommandName = 'webpack'; TestCommand = 'webpack --version'; Url = 'https://npmjs.com/package/webpack-cli' }
        
        # Monitoring & Observability
        @{ Id = '@datadog/datadog-ci'; Enabled = $false; Name = 'Datadog CLI'; CommandName = 'datadog-ci'; TestCommand = 'datadog-ci version'; Url = 'https://npmjs.com/package/@datadog/datadog-ci' }
        
        # Package Management
        @{ Id = 'yarn'; Enabled = $false; Name = 'Yarn'; CommandName = 'yarn'; TestCommand = 'yarn --version'; Url = 'https://npmjs.com/package/yarn' }
        @{ Id = 'pnpm'; Enabled = $false; Name = 'pnpm'; CommandName = 'pnpm'; TestCommand = 'pnpm --version'; Url = 'https://npmjs.com/package/pnpm' }
    )
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Npm` Variable:"
    $Npm | Format-List
}
