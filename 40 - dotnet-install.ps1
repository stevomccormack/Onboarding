# 41 - dotnet-install.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead ".NET SDK Install"
Write-Status "Installing .NET SDKs as defined in configuration"
Write-Var -Name "Install Directory" -Value $($DotNet.InstallDir) -NoIcon
Write-Var -Name "Install Script Path" -Value $($DotNet.InstallScriptPath) -NoIcon
Write-Var -Name "Install Versions" -Value ($DotNet.InstallVersions | ForEach-Object { "$($_.Channel) ($($_.Type))" } -Join-String ", ") -NoIcon
Write-NewLine

# ------------------------------------------------------------------------------------------------
# Download Install Script
# ------------------------------------------------------------------------------------------------
New-DownloadDotNetInstallScript -DownloadUrl $DotNet.InstallDownloadUrl -DestinationPath $DotNet.InstallScriptPath -Force

# ------------------------------------------------------------------------------------------------
# Install SDK Versions
# ------------------------------------------------------------------------------------------------
# Installs each SDK version defined in $DotNet.InstallVersions array.
# To add versions: Edit .shared/variables/dotnet.ps1
# To remove versions: Comment out or delete from array
# ------------------------------------------------------------------------------------------------

Write-Header "Installing .NET SDKs"

foreach ($version in $DotNet.InstallVersions) {
    Write-Status -Title "Installing .NET" -Message "Version: $($version.Channel), Type: $($version.Type)"
    
    & $DotNet.InstallScriptPath -Channel $version.Channel -InstallDir $DotNet.InstallDir
    
    if ($LASTEXITCODE -eq 0) {
        Write-OkMessage -Title ".NET $($version.Channel) ($($version.Type))" -Message "Successfully installed"
    }
    else {
        Write-FailMessage -Title ".NET $($version.Channel) ($($version.Type))" -Message "Installation failed"
    }
}

# ------------------------------------------------------------------------------------------------
# Verify Installation
# ------------------------------------------------------------------------------------------------
Write-Header "Verifying .NET Installation"

Write-Status "Installed .NET SDKs:"
dotnet --list-sdks

Write-Status "Installed .NET Runtimes:"
dotnet --list-runtimes