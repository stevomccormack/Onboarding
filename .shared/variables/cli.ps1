# .shared/variables/cli.ps1

# -------------------------------------------------------------------------------------------------
# CLI Tools Configuration
# -------------------------------------------------------------------------------------------------
# This file defines the primary CLI tools to be installed during onboarding.
# Each CLI tool references configuration from its respective variable file.
# -------------------------------------------------------------------------------------------------

$Cli = [pscustomobject]@{
    Tools = @(
        # Package Managers
        @{ 
            Id              = 'chocolatey'
            Enabled         = $true
            Name            = 'Chocolatey Package Manager'
            CommandName     = 'choco'
            TestCommand     = 'choco --version'
            InstallUrl      = $Choco.InstallScriptUrl
            Variable        = '$Choco'
            Description     = 'Windows package manager for automated software installation'
        }
        @{ 
            Id              = 'winget'
            Enabled         = $false
            Name            = 'Windows Package Manager'
            CommandName     = 'winget'
            TestCommand     = 'winget --version'
            InstallUrl      = $Winget.InstallUrl
            Variable        = '$Winget'
            Description     = 'Native Windows package manager (included in Windows 11+)'
        }
        
        # Version Control
        @{ 
            Id              = 'git'
            Enabled         = $true
            Name            = 'Git'
            CommandName     = 'git'
            TestCommand     = 'git --version'
            InstallUrl      = 'https://git-scm.com/downloads'
            Variable        = 'N/A'
            Description     = 'Distributed version control system'
        }
        @{ 
            Id              = 'github-cli'
            Enabled         = $true
            Name            = 'GitHub CLI'
            CommandName     = 'gh'
            TestCommand     = 'gh --version'
            InstallUrl      = $Gh.InstallUrl
            Variable        = '$Gh'
            Description     = 'GitHub command line tool'
        }
        
        # Cloud Platforms
        @{ 
            Id              = 'azure-cli'
            Enabled         = $true
            Name            = 'Azure CLI'
            CommandName     = 'az'
            TestCommand     = 'az --version'
            InstallUrl      = $Az.InstallUrl
            Variable        = '$Az'
            Description     = 'Azure command-line interface'
        }
        
        # Language Runtimes & Package Managers
        @{ 
            Id              = 'nodejs'
            Enabled         = $true
            Name            = 'Node.js'
            CommandName     = 'node'
            TestCommand     = 'node --version'
            InstallUrl      = 'https://nodejs.org/en/download/'
            Variable        = 'N/A'
            Description     = 'JavaScript runtime (includes npm)'
        }
        @{ 
            Id              = 'npm'
            Enabled         = $true
            Name            = 'NPM'
            CommandName     = 'npm'
            TestCommand     = 'npm --version'
            InstallUrl      = $Npm.InstallUrl
            Variable        = '$Npm'
            Description     = 'Node.js package manager (included with Node.js)'
        }
        @{ 
            Id              = 'python'
            Enabled         = $true
            Name            = 'Python'
            CommandName     = 'python'
            TestCommand     = 'python --version'
            InstallUrl      = 'https://python.org/downloads/'
            Variable        = 'N/A'
            Description     = 'Python programming language (includes pip)'
        }
        @{ 
            Id              = 'pip'
            Enabled         = $true
            Name            = 'Pip'
            CommandName     = 'pip'
            TestCommand     = 'pip --version'
            InstallUrl      = $Pip.InstallUrl
            Variable        = '$Pip'
            Description     = 'Python package manager (included with Python 3.4+)'
        }
        @{ 
            Id              = 'ruby'
            Enabled         = $false
            Name            = 'Ruby'
            CommandName     = 'ruby'
            TestCommand     = 'ruby --version'
            InstallUrl      = 'https://rubyinstaller.org/'
            Variable        = 'N/A'
            Description     = 'Ruby programming language (includes gem)'
        }
        @{ 
            Id              = 'gem'
            Enabled         = $false
            Name            = 'RubyGems'
            CommandName     = 'gem'
            TestCommand     = 'gem --version'
            InstallUrl      = $Gem.InstallUrl
            Variable        = '$Gem'
            Description     = 'Ruby package manager (included with Ruby)'
        }
        
        # Containers & Orchestration
        @{ 
            Id              = 'docker'
            Enabled         = $true
            Name            = 'Docker Desktop'
            CommandName     = 'docker'
            TestCommand     = 'docker --version'
            InstallUrl      = 'https://docker.com/products/docker-desktop/'
            Variable        = 'N/A'
            Description     = 'Container platform for building and running applications'
        }
        @{ 
            Id              = 'kubectl'
            Enabled         = $true
            Name            = 'kubectl'
            CommandName     = 'kubectl'
            TestCommand     = 'kubectl version --client'
            InstallUrl      = 'https://kubernetes.io/docs/tasks/tools/'
            Variable        = 'N/A'
            Description     = 'Kubernetes command-line tool'
        }
        @{ 
            Id              = 'helm'
            Enabled         = $true
            Name            = 'Helm'
            CommandName     = 'helm'
            TestCommand     = 'helm version'
            InstallUrl      = 'https://helm.sh/docs/intro/install/'
            Variable        = 'N/A'
            Description     = 'Kubernetes package manager'
        }
        
        # Infrastructure as Code
        @{ 
            Id              = 'terraform'
            Enabled         = $true
            Name            = 'Terraform'
            CommandName     = 'terraform'
            TestCommand     = 'terraform --version'
            InstallUrl      = 'https://developer.hashicorp.com/terraform/install'
            Variable        = 'N/A'
            Description     = 'Infrastructure as Code tool'
        }
        @{ 
            Id              = 'pulumi'
            Enabled         = $true
            Name            = 'Pulumi'
            CommandName     = 'pulumi'
            TestCommand     = 'pulumi version'
            InstallUrl      = 'https://pulumi.com/docs/install/'
            Variable        = 'N/A'
            Description     = 'Modern Infrastructure as Code platform'
        }
        
        # Development Environments
        @{ 
            Id              = 'wsl'
            Enabled         = $true
            Name            = 'WSL (Windows Subsystem for Linux)'
            CommandName     = 'wsl'
            TestCommand     = 'wsl --version'
            InstallUrl      = 'https://learn.microsoft.com/en-us/windows/wsl/install'
            Variable        = '$Wsl'
            Description     = 'Run Linux environment on Windows'
        }
        @{ 
            Id              = 'powershell-core'
            Enabled         = $true
            Name            = 'PowerShell Core'
            CommandName     = 'pwsh'
            TestCommand     = 'pwsh --version'
            InstallUrl      = 'https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell'
            Variable        = 'N/A'
            Description     = 'Cross-platform PowerShell'
        }
    )
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Cli` Variable:"
    $Cli | Format-List
}