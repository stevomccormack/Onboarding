# Onboarding

> **Professional PowerShell automation toolkit for developer environment setup and configuration**

A comprehensive collection of PowerShell scripts for automating Windows developer environment setup, including SSH configuration, Git initialization, .NET SDK installation, Docker/WSL management, and Microsoft 365 integration.

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)

---

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Configuration](#-configuration)
- [Available Scripts](#-available-scripts)
- [Core Functions](#-core-functions)
- [License](#-license)

---

## ✨ Features

- **🪟 Windows Management**: Active Directory policies and Windows Update automation
- **🔧 CLI Tools**: Automated installation of development tools (Git, Node.js, Python, etc.)
- **🔐 SSH Management**: Complete SSH key generation, agent configuration, and provider integration
- **📦 Git Configuration**: Global and project-level Git setup with safe.directory management
- **🌐 .NET Development**: SDK installation, workloads, global tools, and certificate configuration
- **🐳 WSL & Docker**: WSL configuration and Docker Desktop management
- **📧 Microsoft 365**: Mailbox creation and management (optional)
- **🎯 Environment Variables**: Secure `.env` file support with automatic loading
- **📂 Modular Architecture**: Reusable functions, types, and variables
- **🎨 Rich Console Output**: Professional formatting with colors, icons, and structured logging

---

## 🔧 Prerequisites

- **Windows 10/11** (version 1809+) or **Windows Server 2019+**
- **PowerShell 5.1+** (PowerShell 7+ recommended for best performance)
- **Administrator privileges** (required for some operations)
- **Internet connection** (for downloading tools and SDKs)

### Optional Components

- **OpenSSH Client** (included in Windows 10 1809+)
- **Git** (can be installed via script)
- **WSL 2** (for Docker Desktop)
- **.NET SDK** (can be installed via script)
- **Azure CLI** (for Azure-related scripts)
- **Microsoft 365 Admin Rights** (for M365 scripts)

---

## 📦 Installation

### 1. Clone the Repository

```powershell
git clone https://github.com/stevomccormack/Onboarding.git
cd Onboarding
```

### 2. Configure Environment Variables

Copy the example environment file and add your credentials:

```powershell
Copy-Item .env.example .env
notepad .env
```

Update the `.env` file with your personal access tokens:

```dotenv
# GitHub Personal Access Token
STEVE_GITHUB_PAT=ghp_your_token_here

# Azure DevOps Personal Access Token
STEVE_AZURE_DEVOPS_PAT=your_azure_token_here
```

> ⚠️ **Security**: The `.env` file is already in `.gitignore`. Never commit credentials to version control.

### 3. Load Shared Environment

```powershell
. .\.shared\index.ps1
```

If successful, you'll see variables and modules loaded automatically.

---

## 🚀 Quick Start

### Complete Developer Setup (Recommended Order)

```powershell
# 1. Load environment
. .\.shared\index.ps1

# 2. Check system information
.\01 - system.ps1

# 3. Update Active Directory policies (domain-joined machines)
.\02 - ms-active-directory.ps1

# 4. Update Windows (requires admin)
.\03 - ms-windows-update.ps1

# 5. Install CLI tools
.\10 - cli-install.ps1

# 6. Configure SSH
.\20 - ssh-init.ps1

# 7. Configure Git
.\30 - git-config.ps1

# 8. Install .NET SDKs
.\41 - dotnet-install.ps1
.\42 - dotnet-tools.ps1
.\43 - dotnet-workloads.ps1

# 9. Configure WSL (if using Docker)
.\51 - wsl.ps1
```

### Quick SSH Setup

```powershell
. .\.shared\index.ps1
.\20 - ssh-init.ps1  # Generates keys, configures agent, tests connections
```

### Quick .NET Setup

```powershell
. .\.shared\index.ps1
.\41 - dotnet-install.ps1    # Install SDKs (.NET 8, 10)
.\42 - dotnet-tools.ps1      # Install global tools (EF, diagnostics)
.\43 - dotnet-workloads.ps1  # Install workloads (Aspire, MAUI)
```

---

## 📁 Project Structure

```
Onboarding/
├── .shared/                         # Shared modules and configuration
│   ├── files/                       # Configuration file templates
│   │   ├── .gitconfig              # Git global configuration template
│   │   ├── .wslconfig              # WSL2 configuration (16GB RAM, 10 CPUs)
│   │   └── dotnet-install.ps1      # Cached .NET install script
│   ├── functions/                   # Reusable PowerShell functions
│   │   ├── write.ps1               # Console output (MastHead, Status, OK, Fail)
│   │   ├── dotenv.ps1              # Environment variable loader (.env support)
│   │   ├── ssh-*.ps1               # SSH management (keygen, agent, config, test)
│   │   ├── git-*.ps1               # Git operations (safe.directory, test)
│   │   ├── dotnet-install.ps1      # .NET install script downloader
│   │   └── ...                     # Other utilities
│   ├── types/                       # PowerShell classes and enums
│   │   ├── project.ps1             # Project class definition
│   │   ├── provider.ps1            # GitProvider enum (GitHub, AzureDevOps)
│   │   └── ssh.ps1                 # SshProfile class
│   ├── variables/                   # Global configuration variables
│   │   ├── global.ps1              # Global settings (logging, paths)
│   │   ├── ssh.ps1                 # SSH profiles (GitHub, Azure DevOps)
│   │   ├── projects.ps1            # Project definitions
│   │   ├── dotnet.ps1              # .NET versions, tools, workloads
│   │   └── wsl.ps1                 # WSL configuration paths
│   └── index.ps1                    # Main loader (loads all shared resources)
│
├── .project/                        # Project-specific automation
│   ├── git-init.ps1                # Initialize Git repository
│   └── git-config.ps1              # Configure local Git settings
│
├── 01 - system.ps1                 # Display comprehensive system information
├── 02 - ms-active-directory.ps1    # Force AD Group Policy refresh
├── 03 - ms-windows-update.ps1      # Install Windows updates
├── 10 - cli-install.ps1            # Install CLI tools (Git, Node, Python, etc.)
├── 20 - ssh-init.ps1               # Complete SSH setup (keys, agent, config)
├── 30 - git-config.ps1             # Configure Git globally
├── 41 - dotnet-install.ps1         # Install .NET SDKs (8.0, 10.0)
├── 42 - dotnet-tools.ps1           # Install global tools (dotnet-ef, trace, etc.)
├── 43 - dotnet-workloads.ps1       # Install workloads (Aspire, MAUI, WASM)
├── 44 - dotnet-dev-certs.ps1       # Configure HTTPS dev certificates
├── 44 - dotnet-nuget.ps1           # Manage NuGet sources
├── 45 - dotnet-build.ps1           # Build all .NET solutions in repos directory
├── 46 - dotnet-ef.ps1              # Install and configure Entity Framework tools
├── 51 - wsl.ps1                    # Copy WSL config to user profile
├── 52 - docker-wsl-reinstall.ps1   # Reinstall Docker Desktop with WSL2
│
├── .env.example                     # Example environment variables
├── .gitignore                       # Git ignore rules
├── LICENSE                          # MIT License
└── README.md                        # This file
```

---

## ⚙️ Configuration

### Environment Variables (.env)

The `.env` file is automatically loaded when sourcing `.shared\index.ps1`:

```dotenv
# GitHub Personal Access Token (for SSH key registration)
STEVE_GITHUB_PAT=ghp_xxxxxxxxxxxx

# Azure DevOps Personal Access Token
STEVE_AZURE_DEVOPS_PAT=xxxxxxxxxxxx

# Custom Variables
MY_CUSTOM_VAR=value
```

### Global Configuration

Edit `.shared\variables\global.ps1`:

```powershell
$Global = [pscustomobject]@{
    Log = [pscustomobject]@{
        Enabled = $true     # Enable verbose logging
    }
}
```

### SSH Configuration

Edit `.shared\variables\ssh.ps1` to customize SSH profiles:

```powershell
$Ssh = [pscustomobject]@{
    UseKnownHosts = $true           # Auto-add known hosts
    UseSshAgent = $true             # Use SSH agent
    TestConnection = $true          # Test connections after setup

    Steve = [pscustomobject]@{
        GitHub = (New-SshProfile ...)
        AzureDevOps = (New-SshProfile ...)
    }
}
```

### .NET Configuration

Edit `.shared\variables\dotnet.ps1`:

```powershell
$DotNet = [pscustomobject]@{
    InstallVersions = @(
        @{ Channel = '8.0'; Type = 'sdk' }      # .NET 8 LTS
        @{ Channel = '10.0'; Type = 'sdk' }     # .NET 10 LTS
    )

    Workloads = @(
        'aspire'          # Cloud-native orchestration
        'maui'            # Cross-platform apps
        'wasm-tools'      # WebAssembly
    )

    Tools = @(
        'dotnet-ef'                 # Entity Framework CLI
        'dotnet-trace'              # Performance profiling
        'httprepl'                  # HTTP API testing
        # ... 15+ tools available
    )
}
```

### WSL Configuration

Edit `.shared\files\.wslconfig` for WSL2 resource limits:

```ini
[wsl2]
memory=16GB          # 50% of system RAM (32GB available)
processors=10        # 50% of logical processors (20 available)
swap=4GB
nestedVirtualization=true
dnsTunneling=true
firewall=true
```

### Project Definitions

Edit `.shared\variables\projects.ps1`:

```powershell
$Projects = [pscustomobject]@{
    Onboarding = (New-GitHubProject `
        -Owner 'stevomccormack' `
        -Repository 'Onboarding' `
        -LocalPath 'D:\Repos\Onboarding')
}
```

---

## 📜 Available Scripts

### System Management

| Script                         | Description                                                       |
| ------------------------------ | ----------------------------------------------------------------- |
| `01 - system.ps1`              | Display comprehensive system information (CPU, RAM, GPU, storage) |
| `02 - ms-active-directory.ps1` | Force immediate Group Policy refresh (`gpupdate /force`)          |
| `03 - ms-windows-update.ps1`   | Check and install Windows updates using PSWindowsUpdate           |

### Development Tools

| Script                 | Description                                              |
| ---------------------- | -------------------------------------------------------- |
| `10 - cli-install.ps1` | Install essential CLI tools (Git, Node.js, Python, etc.) |

### SSH & Git

| Script                | Description                                                  |
| --------------------- | ------------------------------------------------------------ |
| `20 - ssh-init.ps1`   | Generate SSH keys, configure agent, test connections         |
| `30 - git-config.ps1` | Configure Git globally (user, email, editor, safe.directory) |

### .NET Development

| Script                      | Description                                             |
| --------------------------- | ------------------------------------------------------- |
| `41 - dotnet-install.ps1`   | Install .NET SDKs (versions defined in variables)       |
| `42 - dotnet-tools.ps1`     | Install global tools (EF, diagnostics, code generators) |
| `43 - dotnet-workloads.ps1` | Install workloads (Aspire, MAUI, WebAssembly)           |
| `44 - dotnet-dev-certs.ps1` | Configure HTTPS development certificates                |
| `44 - dotnet-nuget.ps1`     | Manage NuGet package sources                            |
| `45 - dotnet-build.ps1`     | Build all defined solutions                             |
| `46 - dotnet-ef.ps1`        | Install and configure Entity Framework Core tools       |

### WSL & Docker

| Script                          | Description                                    |
| ------------------------------- | ---------------------------------------------- |
| `51 - wsl.ps1`                  | Copy `.wslconfig` to user profile              |
| `52 - docker-wsl-reinstall.ps1` | Reinstall Docker Desktop with WSL2 integration |

### Project Automation

| Script                    | Description                                     |
| ------------------------- | ----------------------------------------------- |
| `.project/git-init.ps1`   | Initialize Git repository for current project   |
| `.project/git-config.ps1` | Configure local Git settings and safe.directory |

---

## 🔨 Core Functions

### Environment & Configuration

| Function               | Description                                 |
| ---------------------- | ------------------------------------------- |
| `Import-DotEnv`        | Load environment variables from `.env` file |
| `Test-Command`         | Check if a command exists in PATH           |
| `Test-Module`          | Check if a PowerShell module is installed   |
| `Test-EnsureDirectory` | Create directory if it doesn't exist        |

### Console Output

| Function            | Description                      |
| ------------------- | -------------------------------- |
| `Write-MastHead`    | Display large section header     |
| `Write-Header`      | Display subsection header        |
| `Write-Status`      | Display status message           |
| `Write-Ok`          | Display success message (green)  |
| `Write-OkMessage`   | Display titled success message   |
| `Write-WarnMessage` | Display warning message (yellow) |
| `Write-FailMessage` | Display error message (red)      |
| `Write-InfoMessage` | Display info message (cyan)      |
| `Write-Var`         | Display variable name-value pair |
| `Write-NewLine`     | Output blank lines               |

### SSH Management

| Function              | Description                             |
| --------------------- | --------------------------------------- |
| `New-SshKey`          | Generate ED25519 or RSA key pairs       |
| `New-SshProfile`      | Create SSH profile configuration object |
| `New-SshAgentKey`     | Add SSH key to Windows SSH agent        |
| `Clear-SshAgentKeys`  | Remove all keys from SSH agent          |
| `Test-SshConnection`  | Test SSH authentication to a host       |
| `Test-EnsureSshAgent` | Ensure SSH agent service is running     |
| `Test-SshKeyExists`   | Check if SSH key file exists            |
| `Add-SshKnownHost`    | Add host to SSH known_hosts file        |

### Git Operations

| Function                          | Description                                      |
| --------------------------------- | ------------------------------------------------ |
| `New-GitSafeDirectory`            | Add directory to Git safe.directory (idempotent) |
| `Remove-GitSafeDirectory`         | Remove directory from Git safe.directory         |
| `Get-GitSafeDirectories`          | List all Git safe directories                    |
| `Test-GitRepositoryIsInitialized` | Check if directory is a Git repository           |

### .NET Management

| Function                          | Description                                 |
| --------------------------------- | ------------------------------------------- |
| `New-DownloadDotNetInstallScript` | Download official .NET install script       |
| `New-DownloadChocoInstallScript`  | Download official Chocolatey install script |
| `Install-Chocolatey`              | Install Chocolatey package manager          |

### Microsoft 365 (Optional)

| Function                | Description                  |
| ----------------------- | ---------------------------- |
| `Test-365MailboxExists` | Check if M365 mailbox exists |
| `New-365Mailbox`        | Create new user mailbox      |
| `New-365SharedMailbox`  | Create new shared mailbox    |
| `New-365MailboxAlias`   | Add email alias to mailbox   |

---

## 🎯 Usage Examples

### SSH Setup Example

```powershell
# Load environment
. .\.shared\index.ps1

# Generate SSH key for GitHub
New-SshKey `
    -KeyFilePath "$env:USERPROFILE\.ssh\id_ed25519_github" `
    -KeyType 'ed25519' `
    -KeyComment 'hello@iamstevo.co' `
    -Force

# Add to SSH agent
New-SshAgentKey -KeyFilePath "$env:USERPROFILE\.ssh\id_ed25519_github"

# Test connection
Test-SshConnection -UserName 'git' -HostName 'github.com'
```

### Git Configuration Example

```powershell
# Add current directory to Git safe.directory
New-GitSafeDirectory -Path $PWD -Scope 'global'

# List all safe directories
Get-GitSafeDirectories -Scope 'global'

# Check if directory is a Git repository
if (Test-GitRepositoryIsInitialized -Path "C:\MyProject") {
    Write-Ok "Valid Git repository"
}
```

### .NET Installation Example

```powershell
# Download latest install script
Get-DotNetInstallScript -Force

# Install specific SDK version
& $DotNet.InstallScriptPath -Channel '8.0' -InstallDir $DotNet.InstallDir

# Install global tool
dotnet tool install --global dotnet-ef

# Install workload
dotnet workload install aspire
```

### Console Output Example

```powershell
Write-MastHead "Project Setup"
Write-Status "Initializing environment..."

Write-OkMessage -Title "SSH" -Message "Keys generated successfully"
Write-WarnMessage -Title "Config" -Message "No .env file found"
Write-FailMessage -Title "Connection" -Message "Unable to reach server"

Write-Var -Name "SDK Version" -Value "8.0.416"
Write-NewLine -Count 2
```

---

## 🛡️ Security Best Practices

1. **Never commit `.env` file** - Contains sensitive tokens
2. **Use SSH keys instead of passwords** - More secure for Git operations
3. **Rotate PATs regularly** - Update GitHub and Azure DevOps tokens
4. **Use SSH agent** - Avoid typing passphrases repeatedly
5. **Keep SDKs updated** - Run update scripts periodically
6. **Review script contents** - Understand what each script does before running

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

For issues, questions, or suggestions:

- **Issues**: [GitHub Issues](https://github.com/stevomccormack/Onboarding/issues)
- **Email**: hello@iamstevo.co
- **Website**: [iamstevo.co](https://iamstevo.co)

---

<div align="center">

**Made with ❤️ by [Steve McCormack](https://github.com/stevomccormack)**

⭐ Star this repository if you find it helpful!

</div>

### SSH Configuration

```powershell
# Load shared environment
. .\.shared\index.ps1

# Generate SSH key
New-SshKey -Provider 'GitHub' -Email 'hello@iamstevo.co'

# Add key to SSH agent
New-SshAgentKey -KeyFilePath "$env:USERPROFILE\.ssh\id_ed25519"

# Test SSH connection
Test-SshConnection -Host 'github.com'
```

### Git Repository Management

```powershell
# Check if directory is a Git repository
Test-GitRepository -Path "C:\MyProject"

# Get project by name
$project = Get-ProjectByName -Name 'Onboarding'

# Access project properties
Write-Host "Git URL: $($project.GitUrl)"
Write-Host "Branch: $($project.MainBranch)"
```

### Console Output Functions

```powershell
# Status messages
Write-Status "Initializing environment..."

# Success messages
Write-OkMessage -Title "Setup Complete" -Message "All systems ready"

# Warning messages
Write-WarnMessage -Title "Missing Config" -Message "Please configure .env file"

# Error messages
Write-FailMessage -Title "Connection Failed" -Message "Unable to reach server"

# Variables
Write-Var -Name "Project Name" -Value $Projects.Onboarding.Name
```

---

## 📜 Available Scripts

### Development Environment

| Script                      | Description                                           |
| --------------------------- | ----------------------------------------------------- |
| `dev/git-config-global.ps1` | Configure global Git settings (user, editor, aliases) |
| `dev/ssh-init.ps1`          | Initialize SSH keys and configure SSH agent           |

### Project Management

| Script                    | Description                                  |
| ------------------------- | -------------------------------------------- |
| `.project/git-init.ps1`   | Initialize Git repository for the project    |
| `.project/git-config.ps1` | Configure local Git settings for the project |

### Azure

| Script                           | Description                                    |
| -------------------------------- | ---------------------------------------------- |
| `azure/subscriptions-create.ps1` | Automate Azure subscription creation and setup |

### Microsoft 365

| Script                     | Description                                  |
| -------------------------- | -------------------------------------------- |
| `365/mailboxes-create.ps1` | Create and configure Microsoft 365 mailboxes |

---

## 🔨 Core Functions

### Environment & Configuration

- **`Import-DotEnv`**: Load environment variables from `.env` file
- **`Test-Command`**: Check if a command exists in PATH
- **`Test-Module`**: Check if a PowerShell module is available

### SSH Management

- **`New-SshKey`**: Generate SSH key pairs for different providers
- **`New-SshAgentKey`**: Add SSH keys to the SSH agent
- **`Clear-SshAgentKeys`**: Remove all keys from SSH agent
- **`Test-SshConnection`**: Test SSH connectivity to a host
- **`Test-EnsureSshAgent`**: Ensure SSH agent service is running

### Git Operations

- **`Test-GitRepository`**: Check if directory is a Git repository
- **`Get-ProjectByName`**: Retrieve project configuration by name
- **`New-GitHubProject`**: Create GitHub project configuration
- **`New-AzureDevOpsProject`**: Create Azure DevOps project configuration

### Console Output

- **`Write-MastHead`**: Display section headers
- **`Write-Status`**: Display status messages
- **`Write-OkMessage`**: Display success messages
- **`Write-WarnMessage`**: Display warnings
- **`Write-FailMessage`**: Display error messages
- **`Write-Var`**: Display variable name-value pairs
- **`Write-NewLine`**: Output blank lines

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow existing code style and conventions
- Add comments to complex logic
- Update documentation for new features
- Test scripts thoroughly before submitting
- Use meaningful commit messages

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Inspired by modern DevOps automation practices
- Built with PowerShell best practices
- Designed for enterprise and personal use

---

## 📞 Support

For issues, questions, or suggestions:

- **Issues**: [GitHub Issues](https://github.com/stevomccormack/Onboarding/issues)
- **Email**: hello@iamstevo.co
- **Website**: [iamstevo.co](https://iamstevo.co)

---

<div align="center">

**Made with ❤️ by [Steve McCormack](https://github.com/stevomccormack)**

⭐ Star this repository if you find it helpful!

</div>
