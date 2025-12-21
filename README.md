# Onboarding

> **Professional PowerShell automation toolkit for developer environment setup and project configuration**

A comprehensive collection of PowerShell scripts designed to streamline the onboarding process for developers, automating common tasks such as SSH configuration, Git setup, Azure subscriptions, Microsoft 365 mailboxes, and development environment initialization.

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
- [Usage Examples](#-usage-examples)
- [Available Scripts](#-available-scripts)
- [Core Functions](#-core-functions)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

- **🔐 SSH Management**: Complete SSH key generation, configuration, and known hosts management
- **🔧 Git Configuration**: Automated Git setup with repository initialization and configuration
- **☁️ Azure Integration**: Azure subscription and resource management automation
- **📧 Microsoft 365**: Mailbox creation and management scripts
- **🎯 Environment Variables**: Secure `.env` file support with automatic loading
- **📦 Modular Architecture**: Well-organized functions, types, and variables for reusability
- **🎨 Rich Console Output**: Professional console formatting with colors, icons, and structured logging
- **🛡️ Type Safety**: Strongly-typed PowerShell classes for projects, providers, and SSH configurations
- **⚙️ Extensible**: Easy to add new automation scripts and custom workflows

---

## 🔧 Prerequisites

- **Windows 10/11** or **Windows Server 2019+**
- **PowerShell 5.1** or higher (PowerShell 7+ recommended)
- **Git** for version control
- **OpenSSH Client** (included in Windows 10 1809+)
- **Azure CLI** (optional, for Azure-related scripts)
- **Microsoft 365 Admin Rights** (optional, for M365 scripts)

---

## 📦 Installation

### 1. Clone the Repository

```powershell
git clone https://github.com/stevomccormack/Onboarding.git
cd Onboarding
```

### 2. Configure Environment Variables

Copy the example environment file and configure your credentials:

```powershell
Copy-Item .env.example .env
notepad .env
```

Update the `.env` file with your personal access tokens:

```dotenv
# GitHub Personal Access Token
STEVE_GITHUB_PAT = 'ghp_your_token_here'

# Azure DevOps Personal Access Token
STEVE_AZURE_DEVOPS_PAT = 'your_azure_token_here'
```

> ⚠️ **Security**: Never commit the `.env` file to version control. It's already included in `.gitignore`.

### 3. Verify Installation

Load the shared functions and verify:

```powershell
. .\.shared\index.ps1
```

If successful, you'll see environment variables loaded and the shared modules initialized.

---

## 🚀 Quick Start

### Initialize Development Environment

```powershell
# Load the shared environment
. .\.shared\index.ps1

# Configure global Git settings
.\dev\git-config-global.ps1

# Initialize SSH for GitHub
.\dev\ssh-init.ps1
```

### Create Azure Resources

```powershell
# Create Azure subscriptions
.\azure\subscriptions-create.ps1
```

### Setup Microsoft 365 Mailboxes

```powershell
# Create M365 mailboxes
.\365\mailboxes-create.ps1
```

---

## 📁 Project Structure

```
Onboarding/
├── .shared/                    # Shared modules and utilities
│   ├── functions/              # Reusable PowerShell functions
│   │   ├── write.ps1          # Console output functions
│   │   ├── dotenv.ps1         # Environment variable loader
│   │   ├── ssh-*.ps1          # SSH management functions
│   │   ├── git-test.ps1       # Git repository testing
│   │   └── ...                # Other utility functions
│   ├── types/                  # Strongly-typed PowerShell classes
│   │   ├── project.ps1        # Project class and helpers
│   │   ├── provider.ps1       # Provider configuration
│   │   └── ssh.ps1            # SSH configuration types
│   ├── variables/              # Global and project variables
│   │   ├── global.ps1         # Global configuration
│   │   └── projects.ps1       # Project definitions
│   └── index.ps1              # Main loader for all shared resources
├── .project/                   # Project-specific scripts
│   ├── git-init.ps1           # Initialize Git repository
│   └── git-config.ps1         # Configure Git for project
├── 365/                        # Microsoft 365 automation
│   └── mailboxes-create.ps1   # Mailbox creation script
├── azure/                      # Azure automation
│   └── subscriptions-create.ps1
├── dev/                        # Developer environment setup
│   ├── git-config-global.ps1  # Global Git configuration
│   └── ssh-init.ps1           # SSH initialization
├── .env.example               # Example environment variables
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

---

## ⚙️ Configuration

### Environment Variables

The `.env` file is loaded automatically when you source `.shared\index.ps1`. It supports:

- **Personal Access Tokens** for GitHub and Azure DevOps
- **Custom variables** for your organization
- **Secure loading** with validation and error handling

**Example `.env` structure:**

```dotenv
# GitHub Configuration
STEVE_GITHUB_PAT = 'ghp_xxxxxxxxxxxx'

# Azure DevOps Configuration
STEVE_AZURE_DEVOPS_PAT = 'xxxxxxxxxxxx'

# Custom Variables
MY_CUSTOM_VARIABLE = 'value'
```

### Project Configuration

Projects are defined in `.shared\variables\projects.ps1`:

```powershell
$Projects = [pscustomobject]@{
    Onboarding = New-GitHubProject `
        -Owner 'stevomccormack' `
        -Repository 'Onboarding' `
        -LocalPath 'D:\Projects\Onboarding' `
        -UserName 'Steve McCormack' `
        -UserEmail 'hello@iamstevo.co'
}
```

Access project properties:

```powershell
$Projects.Onboarding.GitUrl
$Projects.Onboarding.LocalPath
$Projects.Onboarding.MainBranch
```

---

## 💡 Usage Examples

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

- **`Load-DotEnv`**: Load environment variables from `.env` file
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
