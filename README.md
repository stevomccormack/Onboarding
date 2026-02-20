# Onboarding

> PowerShell automation toolkit for Windows developer environment setup

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)

---

## Prerequisites

- Windows 10/11 or Windows Server 2019+
- PowerShell 5.1+ (7+ recommended)
- Administrator privileges for some scripts

---

## Setup

```powershell
# 1. Clone and enter the repo
git clone https://github.com/stevomccormack/Onboarding.git
cd Onboarding

# 2. Copy and populate environment variables
Copy-Item .env.example .env

# 3. Load the shared environment (run before any script)
. .\.shared\index.ps1
```

### Environment Variables

| Variable                  | Description                      |
| ------------------------- | -------------------------------- |
| `STEVE_GITHUB_PAT`        | GitHub Personal Access Token     |
| `STEVE_AZURE_DEVOPS_PAT`  | Azure DevOps Personal Access Token |

> The `.env` file is git-ignored. Never commit credentials.

---

## Scripts

### System

| Script                         | Description                                      |
| ------------------------------ | ------------------------------------------------ |
| `00 - init.ps1`                | Bootstrap environment initialisation             |
| `01 - system.ps1`              | Display system information (CPU, RAM, GPU, disk) |
| `02 - ms-active-directory.ps1` | Force Group Policy refresh (`gpupdate /force`)   |
| `03 - ms-windows-update.ps1`   | Install Windows updates via PSWindowsUpdate      |

### Package Managers & CLI Tools

| Script                    | Description                              |
| ------------------------- | ---------------------------------------- |
| `10 - winget-install.ps1` | Install and configure Winget             |
| `11 - choco-install.ps1`  | Install Chocolatey                       |
| `12 - wsl-install.ps1`    | Install WSL2                             |
| `13 - wsl-config.ps1`     | Configure WSL2 resource limits           |
| `14 - cli-install.ps1`    | Install CLI tools (Git, Node.js, Python) |

### SSH & Git

| Script               | Description                                      |
| -------------------- | ------------------------------------------------ |
| `20 - ssh-init.ps1`  | Generate SSH keys, configure agent, test connections |
| `30 - git-clone.ps1` | Clone all repositories defined in `$Projects`   |
| `31 - git-config.ps1`| Configure Git globally (user, email, safe.directory) |

### .NET

| Script                      | Description                                    |
| --------------------------- | ---------------------------------------------- |
| `40 - dotnet-install.ps1`   | Install .NET SDKs                              |
| `41 - dotnet-nuget.ps1`     | Manage NuGet package sources                   |
| `42 - dotnet-workloads.ps1` | Install workloads (Aspire, MAUI, WASM)         |
| `43 - dotnet-tools.ps1`     | Install global tools (EF Core, diagnostics)    |
| `44 - dotnet-dev-certs.ps1` | Configure HTTPS development certificates       |
| `45 - dotnet-build.ps1`     | Restore & build projects tagged `dotnet`       |
| `46 - dotnet-ef.ps1`        | Configure Entity Framework Core tools          |

### Other

| Script                     | Description                                    |
| -------------------------- | ---------------------------------------------- |
| `90 - ollama.ps1`          | Install and configure Ollama AI models         |
| `docker-wsl-reinstall.ps1` | Reinstall Docker Desktop with WSL2 integration |

### Project Automation (.project/)

| Script           | Description                                      |
| ---------------- | ------------------------------------------------ |
| `git-init.ps1`   | Initialize a new Git repository                  |
| `git-connect.ps1`| Connect a local directory to an existing remote  |
| `git-config.ps1` | Configure local Git settings and safe.directory  |

---

## Configuration

All configuration lives in `.shared/variables/`. Edit files there to customise behaviour.

### Project Definitions (`projects.ps1`)

Projects are defined with optional tags. The `dotnet` tag targets a project for `45 - dotnet-build.ps1`.

```powershell
$Projects = [pscustomobject]@{
    Onboarding = (New-GitHubProject `
        -Owner      'stevomccormack' `
        -Repository 'Onboarding' `
        -LocalPath  'D:\Repos\Onboarding')

    PineGuard = (New-GitHubProject `
        -Owner      'stevomccormack' `
        -Repository 'PineGuard' `
        -LocalPath  'D:\Repos\PineGuard' `
        -Tags       @('dotnet'))
}
```

### .NET Versions & Tools (`dotnet.ps1`)

```powershell
$DotNet = [pscustomobject]@{
    InstallVersions = @(
        @{ Channel = '8.0';  Type = 'sdk' }
        @{ Channel = '10.0'; Type = 'sdk' }
    )
    Workloads = @('aspire', 'maui', 'wasm-tools')
    Tools     = @('dotnet-ef', 'dotnet-trace', 'httprepl')
}
```

### WSL Resources (`.shared/files/.wslconfig`)

```ini
[wsl2]
memory=16GB
processors=10
swap=4GB
```

### SSH Profiles (`ssh.ps1`)

```powershell
$Ssh = [pscustomobject]@{
    UseKnownHosts  = $true
    UseSshAgent    = $true
    TestConnection = $true
    Steve = [pscustomobject]@{
        GitHub     = (New-SshProfile ...)
        AzureDevOps = (New-SshProfile ...)
    }
}
```

---

## License

MIT — see [LICENSE](LICENSE).
