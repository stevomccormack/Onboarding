# .shared/variables/choco.ps1

# -------------------------------------------------------------------------------------------------
# Chocolatey Configuration & Packages
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Chocolatey Package Commands
# -------------------------------------------------------------------------------------------------
# Install a package:
#   choco install <package-id>
# Upgrade a package:
#   choco upgrade <package-id>
# Uninstall a package:
#   choco uninstall <package-id>
# List installed packages:
#   choco list --local-only
# Search for packages:
#   choco search <keyword>
# -------------------------------------------------------------------------------------------------

$chocoInstallUrl = 'https://chocolatey.org/install'
$chocoInstallScriptUrl = 'https://community.chocolatey.org/install.ps1'
$chocoInstallScriptPath = [System.IO.Path]::Combine($PWD, '.shared\files\chocolatey-install.ps1')
$chocoDocsUrl = 'https://docs.chocolatey.org/'
$chocoPackagesUrl = 'https://community.chocolatey.org/packages'

$Choco = [pscustomobject]@{
    InstallUrl               = $chocoInstallUrl           # Installation instructions page
    InstallScriptUrl         = $chocoInstallScriptUrl     # Direct install script URL
    InstallScriptPath        = $chocoInstallScriptPath    # Local install script path
    DocsUrl                  = $chocoDocsUrl              # Documentation
    PackagesUrl              = $chocoPackagesUrl          # Package repository
    
    # Chocolatey Configuration Settings
    Force                    = $false                      # Force reinstall
    Yes                      = $true                       # Assume yes to all prompts
    AcceptLicense            = $true                       # Accept license agreements
    AllowGlobalConfirmation  = $true                       # Allow global confirmation
    Verbose                  = $false                      # Verbose output
    Debug                    = $false                      # Debug output
    IgnoreChecksums          = $false                      # Ignore checksums (not recommended)
    Source                   = 'https://community.chocolatey.org/api/v2/'  # Package source
    Timeout                  = 2700                        # Timeout in seconds (45 min)
    UseSystemProxy           = $false                      # Use system proxy settings
    CacheLocation            = 'C:\ProgramData\chocolatey\cache'  # Cache directory
    LimitOutput              = $false                      # Limit output
    NoProgress               = $false                      # Disable progress bar
    RequireChecksums         = $true                       # Require checksums
    AllowEmptyChecksums      = $false                      # Allow empty checksums
    UpgradeAll               = $false                      # Upgrade all packages
    ExcludePrerelease        = $true                       # Exclude pre-release versions
    
    Packages = @(
        # Version Control & Collaboration
        @{ Id = 'git';                    Enabled = $true;  Name = 'Git';                          CommandName = 'git';           TestCommand = 'git --version';                      Url = 'https://git-scm.com/downloads' }
        @{ Id = 'gh';                     Enabled = $true;  Name = 'GitHub CLI';                   CommandName = 'gh';            TestCommand = 'gh --version';                       Url = 'https://cli.github.com/' }
        @{ Id = 'glab';                   Enabled = $false; Name = 'GitLab CLI';                   CommandName = 'glab';          TestCommand = 'glab --version';                     Url = 'https://gitlab.com/gitlab-org/cli' }
        
        # Cloud Platforms
        @{ Id = 'azure-cli';              Enabled = $true;  Name = 'Azure CLI';                    CommandName = 'az';            TestCommand = 'az --version';                       Url = 'https://learn.microsoft.com/en-us/cli/azure/install-azure-cli' }
        @{ Id = 'awscli';                 Enabled = $true;  Name = 'AWS CLI';                      CommandName = 'aws';           TestCommand = 'aws --version';                      Url = 'https://aws.amazon.com/cli/' }
        @{ Id = 'gcloudsdk';              Enabled = $false; Name = 'Google Cloud SDK';             CommandName = 'gcloud';        TestCommand = 'gcloud --version';                   Url = 'https://cloud.google.com/sdk/docs/install' }
        @{ Id = 'terraform';              Enabled = $true;  Name = 'Terraform';                    CommandName = 'terraform';     TestCommand = 'terraform --version';                Url = 'https://developer.hashicorp.com/terraform/install' }
        @{ Id = 'pulumi';                 Enabled = $true;  Name = 'Pulumi';                       CommandName = 'pulumi';        TestCommand = 'pulumi version';                     Url = 'https://pulumi.com/docs/install/' }
        
        # Containers & Orchestration
        @{ Id = 'kubernetes-cli';         Enabled = $true;  Name = 'kubectl';                      CommandName = 'kubectl';       TestCommand = 'kubectl version --client';           Url = 'https://kubernetes.io/docs/tasks/tools/' }
        @{ Id = 'kubernetes-helm';        Enabled = $true;  Name = 'Helm';                         CommandName = 'helm';          TestCommand = 'helm version';                       Url = 'https://helm.sh/docs/intro/install/' }
        
        # API Development & Documentation
        @{ Id = 'postman';                Enabled = $true;  Name = 'Postman';                      CommandName = 'postman';       TestCommand = 'postman --version';                  Url = 'https://postman.com/downloads/' }
        @{ Id = 'insomnia-rest-api-client'; Enabled = $false; Name = 'Insomnia';                   CommandName = 'insomnia';      TestCommand = 'insomnia --version';                 Url = 'https://insomnia.rest/download' }
        @{ Id = 'httpie';                 Enabled = $true;  Name = 'HTTPie';                       CommandName = 'http';          TestCommand = 'http --version';                     Url = 'https://httpie.io/docs/cli/installation' }
        
        # Code Quality & Security
        @{ Id = 'sonarscanner-msbuild-net'; Enabled = $true; Name = 'SonarScanner for .NET';       CommandName = 'dotnet';        TestCommand = 'dotnet sonarscanner --version';      Url = 'https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/dotnet/' }
        @{ Id = 'sonar-scanner-cli';      Enabled = $true;  Name = 'SonarScanner CLI';             CommandName = 'sonar-scanner'; TestCommand = 'sonar-scanner --version';            Url = 'https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/sonarscanner/' }
        @{ Id = 'trivy';                  Enabled = $true;  Name = 'Trivy Security Scanner';       CommandName = 'trivy';         TestCommand = 'trivy --version';                    Url = 'https://trivy.dev/latest/getting-started/installation/' }
        @{ Id = 'dependency-check';       Enabled = $true;  Name = 'OWASP Dependency Check';       CommandName = 'dependency-check'; TestCommand = 'dependency-check --version';      Url = 'https://jeremylong.github.io/DependencyCheck/dependency-check-cli/index.html' }
        
        # Build & Package Management
        @{ Id = 'nodejs';                 Enabled = $true;  Name = 'Node.js';                      CommandName = 'node';          TestCommand = 'node --version';                     Url = 'https://nodejs.org/en/download/' }
        @{ Id = 'python';                 Enabled = $true;  Name = 'Python';                       CommandName = 'python';        TestCommand = 'python --version';                   Url = 'https://python.org/downloads/' }
        @{ Id = 'nuget.commandline';      Enabled = $true;  Name = 'NuGet CLI';                    CommandName = 'nuget';         TestCommand = 'nuget';                              Url = 'https://nuget.org/downloads' }
        @{ Id = 'maven';                  Enabled = $false; Name = 'Apache Maven';                 CommandName = 'mvn';           TestCommand = 'mvn --version';                      Url = 'https://maven.apache.org/download.cgi' }
        @{ Id = 'gradle';                 Enabled = $false; Name = 'Gradle';                       CommandName = 'gradle';        TestCommand = 'gradle --version';                   Url = 'https://gradle.org/install/' }
        @{ Id = 'ruby';                   Enabled = $false; Name = 'Ruby';                         CommandName = 'ruby';          TestCommand = 'ruby --version';                     Url = 'https://rubyinstaller.org/' }
        @{ Id = 'golang';                 Enabled = $false; Name = 'Go';                           CommandName = 'go';            TestCommand = 'go version';                         Url = 'https://go.dev/dl/' }
        
        # Database CLIs
        @{ Id = 'postgresql';             Enabled = $true;  Name = 'PostgreSQL CLI';               CommandName = 'psql';          TestCommand = 'psql --version';                     Url = 'https://postgresql.org/download/' }
        @{ Id = 'mysql.cli';              Enabled = $false; Name = 'MySQL CLI';                    CommandName = 'mysql';         TestCommand = 'mysql --version';                    Url = 'https://dev.mysql.com/downloads/shell/' }
        @{ Id = 'mongodb-shell';          Enabled = $false; Name = 'MongoDB Shell';                CommandName = 'mongosh';       TestCommand = 'mongosh --version';                  Url = 'https://mongodb.com/try/download/shell' }
        @{ Id = 'redis';                  Enabled = $true;  Name = 'Redis CLI';                    CommandName = 'redis-cli';     TestCommand = 'redis-cli --version';                Url = 'https://redis.io/docs/getting-started/installation/' }
        
        # Monitoring & Observability
        @{ Id = 'newrelic-cli';           Enabled = $false; Name = 'New Relic CLI';                CommandName = 'newrelic';      TestCommand = 'newrelic version';                   Url = 'https://github.com/newrelic/newrelic-cli#installation' }
        
        # Utilities
        @{ Id = 'jq';                     Enabled = $true;  Name = 'JQ (JSON Processor)';          CommandName = 'jq';            TestCommand = 'jq --version';                       Url = 'https://jqlang.github.io/jq/download/' }
        @{ Id = 'yq';                     Enabled = $true;  Name = 'YQ (YAML Processor)';          CommandName = 'yq';            TestCommand = 'yq --version';                       Url = 'https://github.com/mikefarah/yq#install' }
        @{ Id = 'powershell-core';        Enabled = $true;  Name = 'PowerShell Core';              CommandName = 'pwsh';          TestCommand = 'pwsh --version';                     Url = 'https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell' }
        @{ Id = 'curl';                   Enabled = $true;  Name = 'cURL';                         CommandName = 'curl';          TestCommand = 'curl --version';                     Url = 'https://curl.se/download.html' }
        @{ Id = 'wget';                   Enabled = $false; Name = 'Wget';                         CommandName = 'wget';          TestCommand = 'wget --version';                     Url = 'https://eternallybored.org/misc/wget/' }
    )
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Choco` Variable:"
    $Choco | Format-List
}
