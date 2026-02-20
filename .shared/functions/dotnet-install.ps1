# .shared/functions/dotnet-install.ps1

# ------------------------------------------------------------------------------------------------
# New-DownloadDotNetInstallScript:
# Downloads the official .NET install script from Microsoft to a local path.
# Downloads to a temporary location first, then moves to destination on success (atomic).
# Supports proxy configuration via HTTP_PROXY environment variable.
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function New-DownloadDotNetInstallScript {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        # DownloadUrl:
        # URL to download the .NET install script from.
        # Default: $DotNet.InstallDownloadUrl
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DownloadUrl = $DotNet.InstallDownloadUrl,

        # DestinationPath:
        # Local path where the install script should be saved.
        # Default: $DotNet.InstallScriptPath
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath = $DotNet.InstallScriptPath,

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
        Write-InfoMessage -Title ".NET Install Script" -Message "Script already exists (use -Force to re-download)"
        Write-Var -Name "DestinationPath" -Value $destinationPathClean -NoIcon
        return $true
    }

    # --------------------------------------------------------------------------------------------

    Write-StatusMessage -Title ".NET Install Script" -Message "Downloading latest script"
    Write-Var -Name "DownloadUrl" -Value $downloadUrlClean -NoIcon
    Write-Var -Name "DestinationPath" -Value $destinationPathClean -NoIcon
    
    $tempDownloadPath = Join-Path $env:TEMP "dotnet-install-$(Get-Random).ps1"

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
            Write-OkMessage -Title ".NET Install Script" -Message "Successfully downloaded"
            return $true
        }
        else {
            throw "Download failed: File is empty or does not exist"
        }
    }
    catch {
        Write-FatalMessage -Title ".NET Install Script" -Message "Failed to download: $_"
        Write-Status "Attempted download URL: $downloadUrlClean"
        Write-Status "Please download manually and place at: $destinationPathClean"
        Write-Status "Learn more at: $($DotNet.InstallLearnUrl)"
        
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