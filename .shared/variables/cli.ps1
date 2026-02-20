# .shared/variables/cli.ps1

# -------------------------------------------------------------------------------------------------
# CLI Tools Configuration
# -------------------------------------------------------------------------------------------------
# Defines CLI tools installed during onboarding.
# Each entry references its respective variable file for all properties.
# Ordering reflects install dependency: runtimes before their package managers,
# foundational tools (Git) before tools that depend on them.
#
# Winget is preferred for installation; Chocolatey is the fallback.
# Chocolatey and Winget themselves are handled by cli-install.ps1, not this list.
# -------------------------------------------------------------------------------------------------

$Cli = [pscustomobject]@{
    Tools = @(

        # ------------------------------------------------------------------------------------------
        # Shell
        # PowerShell Core first — improves subsequent installs by using pwsh features.
        # ------------------------------------------------------------------------------------------
        @{
            Id          = $Powershell.Id
            Enabled     = $Powershell.Enabled
            Name        = $Powershell.Name
            CommandName = $Powershell.CommandName
            TestCommand = $Powershell.TestCommand
            WingetId    = $Powershell.WingetId
            ChocoId     = $Powershell.ChocoId
            InstallUrl  = $Powershell.InstallUrl
            Variable    = '$Powershell'
            Description = $Powershell.Description
        }

        # ------------------------------------------------------------------------------------------
        # Version Control
        # Git must come before GitHub CLI (gh auth depends on git).
        # ------------------------------------------------------------------------------------------
        @{
            Id          = $Git.Id
            Enabled     = $Git.Enabled
            Name        = $Git.Name
            CommandName = $Git.CommandName
            TestCommand = $Git.TestCommand
            WingetId    = $Git.WingetId
            ChocoId     = $Git.ChocoId
            InstallUrl  = $Git.InstallUrl
            Variable    = '$Git'
            Description = $Git.Description
        }
        @{
            Id          = $Gh.Id
            Enabled     = $Gh.Enabled
            Name        = $Gh.Name
            CommandName = $Gh.CommandName
            TestCommand = $Gh.TestCommand
            WingetId    = $Gh.WingetId
            ChocoId     = $Gh.ChocoId
            InstallUrl  = $Gh.InstallUrl
            Variable    = '$Gh'
            Description = $Gh.Description
        }

        # ------------------------------------------------------------------------------------------
        # Language Runtimes
        # Runtimes before their bundled package managers (npm, pip, gem depend on runtime install).
        # ------------------------------------------------------------------------------------------
        @{
            Id          = $Node.Id
            Enabled     = $Node.Enabled
            Name        = $Node.Name
            CommandName = $Node.CommandName
            TestCommand = $Node.TestCommand
            WingetId    = $Node.WingetId
            ChocoId     = $Node.ChocoId
            InstallUrl  = $Node.InstallUrl
            Variable    = '$Node'
            Description = $Node.Description
        }
        @{
            Id          = $Npm.Id
            Enabled     = $Npm.Enabled
            Name        = $Npm.Name
            CommandName = $Npm.CommandName
            TestCommand = $Npm.TestCommand
            WingetId    = $Npm.WingetId
            ChocoId     = $Npm.ChocoId
            InstallUrl  = $Npm.InstallUrl
            Variable    = '$Npm'
            Description = $Npm.Description
        }
        @{
            Id          = $Python.Id
            Enabled     = $Python.Enabled
            Name        = $Python.Name
            CommandName = $Python.CommandName
            TestCommand = $Python.TestCommand
            WingetId    = $Python.WingetId
            ChocoId     = $Python.ChocoId
            InstallUrl  = $Python.InstallUrl
            Variable    = '$Python'
            Description = $Python.Description
        }
        @{
            Id          = $Pip.Id
            Enabled     = $Pip.Enabled
            Name        = $Pip.Name
            CommandName = $Pip.CommandName
            TestCommand = $Pip.TestCommand
            WingetId    = $Pip.WingetId
            ChocoId     = $Pip.ChocoId
            InstallUrl  = $Pip.InstallUrl
            Variable    = '$Pip'
            Description = $Pip.Description
        }
        @{
            Id          = $Ruby.Id
            Enabled     = $Ruby.Enabled
            Name        = $Ruby.Name
            CommandName = $Ruby.CommandName
            TestCommand = $Ruby.TestCommand
            WingetId    = $Ruby.WingetId
            ChocoId     = $Ruby.ChocoId
            InstallUrl  = $Ruby.InstallUrl
            Variable    = '$Ruby'
            Description = $Ruby.Description
        }
        @{
            Id          = $Gem.Id
            Enabled     = $Gem.Enabled
            Name        = $Gem.Name
            CommandName = $Gem.CommandName
            TestCommand = $Gem.TestCommand
            WingetId    = $Gem.WingetId
            ChocoId     = $Gem.ChocoId
            InstallUrl  = $Gem.InstallUrl
            Variable    = '$Gem'
            Description = $Gem.Description
        }

        # ------------------------------------------------------------------------------------------
        # Containers & Orchestration
        # Docker before kubectl (kubectl may target local Docker Desktop cluster).
        # kubectl before Helm (Helm requires a configured kubectl context).
        # ------------------------------------------------------------------------------------------
        @{
            Id          = $Docker.Id
            Enabled     = $Docker.Enabled
            Name        = $Docker.Name
            CommandName = $Docker.CommandName
            TestCommand = $Docker.TestCommand
            WingetId    = $Docker.WingetId
            ChocoId     = $Docker.ChocoId
            InstallUrl  = $Docker.InstallUrl
            Variable    = '$Docker'
            Description = $Docker.Description
        }
        @{
            Id          = $Kubectl.Id
            Enabled     = $Kubectl.Enabled
            Name        = $Kubectl.Name
            CommandName = $Kubectl.CommandName
            TestCommand = $Kubectl.TestCommand
            WingetId    = $Kubectl.WingetId
            ChocoId     = $Kubectl.ChocoId
            InstallUrl  = $Kubectl.InstallUrl
            Variable    = '$Kubectl'
            Description = $Kubectl.Description
        }
        @{
            Id          = $Helm.Id
            Enabled     = $Helm.Enabled
            Name        = $Helm.Name
            CommandName = $Helm.CommandName
            TestCommand = $Helm.TestCommand
            WingetId    = $Helm.WingetId
            ChocoId     = $Helm.ChocoId
            InstallUrl  = $Helm.InstallUrl
            Variable    = '$Helm'
            Description = $Helm.Description
        }

        # ------------------------------------------------------------------------------------------
        # Infrastructure as Code
        # ------------------------------------------------------------------------------------------
        @{
            Id          = $Terraform.Id
            Enabled     = $Terraform.Enabled
            Name        = $Terraform.Name
            CommandName = $Terraform.CommandName
            TestCommand = $Terraform.TestCommand
            WingetId    = $Terraform.WingetId
            ChocoId     = $Terraform.ChocoId
            InstallUrl  = $Terraform.InstallUrl
            Variable    = '$Terraform'
            Description = $Terraform.Description
        }
        @{
            Id          = $Pulumi.Id
            Enabled     = $Pulumi.Enabled
            Name        = $Pulumi.Name
            CommandName = $Pulumi.CommandName
            TestCommand = $Pulumi.TestCommand
            WingetId    = $Pulumi.WingetId
            ChocoId     = $Pulumi.ChocoId
            InstallUrl  = $Pulumi.InstallUrl
            Variable    = '$Pulumi'
            Description = $Pulumi.Description
        }

        # ------------------------------------------------------------------------------------------
        # Cloud Platforms
        # ------------------------------------------------------------------------------------------
        @{
            Id          = $Az.Id
            Enabled     = $Az.Enabled
            Name        = $Az.Name
            CommandName = $Az.CommandName
            TestCommand = $Az.TestCommand
            WingetId    = $Az.WingetId
            ChocoId     = $Az.ChocoId
            InstallUrl  = $Az.InstallUrl
            Variable    = '$Az'
            Description = $Az.Description
        }
    )
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Cli` Variable:"
    $Cli | Format-List
}