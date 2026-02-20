# .shared/functions/choco-install.ps1

# ------------------------------------------------------------------------------------------------
# New-DownloadChocoInstallScript:
# Downloads the official Chocolatey install script to a local path.
# Downloads to a temporary location first, then moves to destination on success (atomic).
# Supports proxy configuration via HTTP_PROXY environment variable.
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function New-DownloadChocoInstallScript {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # DownloadUrl:
        # URL to download the Chocolatey install script from.
        # Default: $Choco.InstallScriptUrl
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DownloadUrl = $Choco.InstallScriptUrl,

        # DestinationPath:
        # Local path where the install script should be saved.
        # Default: $Choco.InstallScriptPath
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath = $Choco.InstallScriptPath,

        # Force:
        # Re-download even if the script already exists at DestinationPath.
        [Parameter()]
        [switch]$Force
    )

    # Guards
    $downloadUrlClean = $DownloadUrl.Trim()
    $destinationPathClean = $DestinationPath.Trim()

    # Check if script already exists and Force not specified
    if ((Test-Path -Path $destinationPathClean) -and -not $Force) {
        Write-InfoMessage -Title "Chocolatey Install Script" -Message "Script already exists (use -Force to re-download)"
        Write-Var -Name "DestinationPath" -Value $destinationPathClean -NoIcon
        return $true
    }

    # --------------------------------------------------------------------------------------------

    Write-StatusMessage -Title "Chocolatey Install Script" -Message "Downloading latest script"
    Write-Var -Name "DownloadUrl" -Value $downloadUrlClean -NoIcon
    Write-Var -Name "DestinationPath" -Value $destinationPathClean -NoIcon
    
    $tempDownloadPath = Join-Path $env:TEMP "chocolatey-install-$(Get-Random).ps1"

    try {
        $ProgressPreference = 'SilentlyContinue'  # Speeds up Invoke-WebRequest significantly
        
        # Build request parameters with conditional proxy configuration
        $webRequestParams = @{
            Uri         = $downloadUrlClean
            OutFile     = $tempDownloadPath
            ErrorAction = 'Stop'
        }
        
        # Add proxy parameters only if HTTP_PROXY is configured
        if ($env:HTTP_PROXY) {
            Write-Var -Name "Proxy" -Value $env:HTTP_PROXY -NoIcon
            $webRequestParams['Proxy'] = $env:HTTP_PROXY
            $webRequestParams['ProxyUseDefaultCredentials'] = $true
        }
        
        Invoke-WebRequest @webRequestParams
        $ProgressPreference = 'Continue'
        
        # Verify download succeeded and file has content
        if ((Test-Path $tempDownloadPath) -and (Get-Item $tempDownloadPath).Length -gt 0) {

            # Ensure target directory exists
            $targetDirectory = Split-Path -Parent $destinationPathClean
            if (-not (Test-Path $targetDirectory)) {
                New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
            }
            
            # Move successful download to final location
            Move-Item -Path $tempDownloadPath -Destination $destinationPathClean -Force
            Write-OkMessage -Title "Chocolatey Install Script" -Message "Successfully downloaded"
            return $true
        }
        else {
            throw "Download failed: File is empty or does not exist"
        }
    }
    catch {
        Write-FatalMessage -Title "Chocolatey Install Script" -Message "Failed to download: $_"
        Write-Status "Attempted download URL: $downloadUrlClean"
        Write-Status "Please download manually and place at: $destinationPathClean"
        Write-Status "Learn more at: $($Choco.InstallUrl)"
        
        # Clean up temp file if it exists
        if (Test-Path $tempDownloadPath) {
            Remove-Item $tempDownloadPath -Force -ErrorAction SilentlyContinue
        }
        
        Write-Status "Starting browser to download manually..."
        Start-Process -FilePath $downloadUrlClean

        return $false
    }
    finally {
        # Ensure temp file is removed if it still exists
        if (Test-Path $tempDownloadPath) {
            Remove-Item $tempDownloadPath -Force -ErrorAction SilentlyContinue
        }
    }
}

# ------------------------------------------------------------------------------------------------
# Install-Chocolatey:
# Installs Chocolatey package manager if not already present.
# Downloads install script if needed, then executes it.
# Returns $true if Chocolatey is available after installation, $false otherwise.
# ------------------------------------------------------------------------------------------------
function Install-Chocolatey {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # Force:
        # Force reinstallation even if Chocolatey is already installed.
        [Parameter()]
        [switch]$Force
    )

    # Check if Chocolatey is already available
    $chocoExists = Get-Command -Name 'choco' -ErrorAction SilentlyContinue

    if ($chocoExists -and -not $Force) {
        Write-OkMessage -Title "Chocolatey" -Message "Package manager already installed"
        Write-Var -Name "Version" -Value (& choco --version 2>$null) -NoIcon
        return $true
    }

    if ($Force) {
        Write-StatusMessage -Title "Chocolatey" -Message "Force reinstallation requested"
    }
    else {
        Write-StatusMessage -Title "Chocolatey" -Message "Not found. Installing Chocolatey..."
    }

    # --------------------------------------------------------------------------------------------
    # Download Chocolatey install script
    # --------------------------------------------------------------------------------------------

    $downloadSuccess = New-DownloadChocoInstallScript
    
    if (-not $downloadSuccess) {
        Write-FailMessage -Title "Chocolatey" -Message "Failed to download install script"
        return $false
    }

    # --------------------------------------------------------------------------------------------
    # Execute Chocolatey install script
    # --------------------------------------------------------------------------------------------

    Write-Status "Installing Chocolatey package manager"
    Write-Var -Name "Install Script" -Value $Choco.InstallScriptPath -NoIcon

    try {
        # Run install script
        & $Choco.InstallScriptPath

        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-OkMessage -Title "Chocolatey" -Message "Successfully installed"
            
            # Refresh environment to make choco available
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            # Verify installation
            $chocoExists = Get-Command -Name 'choco' -ErrorAction SilentlyContinue
            if ($chocoExists) {
                Write-OkMessage -Title "Verification" -Message "Chocolatey command is now available"
                Write-Var -Name "Version" -Value (& choco --version 2>$null) -NoIcon
                return $true
            }
            else {
                Write-WarnMessage -Title "Verification" -Message "Chocolatey installed but command not found"
                Write-Status "Restart PowerShell and try again"
                return $false
            }
        }
        else {
            Write-FailMessage -Title "Chocolatey" -Message "Installation failed (Exit Code: $LASTEXITCODE)"
            Write-Status "Manual installation URL: $($Choco.InstallUrl)"
            return $false
        }
    }
    catch {
        Write-FailMessage -Title "Chocolatey" -Message "Installation script execution failed"
        Write-Status "Error: $($_.Exception.Message)"
        Write-Status "Manual installation URL: $($Choco.InstallUrl)"
        return $false
    }
}
