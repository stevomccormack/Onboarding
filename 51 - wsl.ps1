# 51 - wsl.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "Windows Subsystem for Linux (WSL)"

# --------------------------------------------------------------------------------------------------------------------------------

Write-Header "Windows Optional Feature: Windows Subsystem for Linux (WSL)"

$wslFeatureName = "Microsoft-Windows-Subsystem-Linux"
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName $wslFeatureName
if (($wslFeature | Select-Object -ExpandProperty State) -ne "Enabled")
{
    Write-Status "Enabling $wslFeatureName..."
    Enable-WindowsOptionalFeature -Online -FeatureName $wslFeatureName -NoRestart
}
else{
    $wslFeature
}
Write-OkMessage -Title "Windows Optional Feature" -Message "$wslFeatureName is enabled"

# --------------------------------------------------------------------------------------------------------------------------------

Write-Header "Windows Optional Feature: Virtual Machine Platform (WSL 2)"

$vmFeatureName = "VirtualMachinePlatform"
$vmFeature = Get-WindowsOptionalFeature -Online -FeatureName $vmFeatureName
if (($vmFeature | Select-Object -ExpandProperty State) -ne "Enabled")
{
    Write-Status "Enabling $vmFeatureName..."
    Enable-WindowsOptionalFeature -Online -FeatureName $vmFeatureName -NoRestart
}
else{
    $vmFeature
}
Write-OkMessage -Title "Windows Optional Feature" -Message "$vmFeatureName is enabled"

# --------------------------------------------------------------------------------------------------------------------------------

Write-Header "WSL Update & Configuration"

wsl --update                    
wsl --set-default-version 2

# --------------------------------------------------------------------------------------------------------------------------------

wsl --list          # List installed distros
wsl -l -o           # List available distros in the Microsoft Store

# --------------------------------------------------------------------------------------------------------------------------------

# system type
systeminfo | find "System Type" # e.g. x64-based PC

# --------------------------------------------------------------------------------------------------------------------------------

# config
Copy-Item -Path $Wsl.ConfigSourcePath -Destination $Wsl.ConfigTargetPath -Force
wsl --shutdown
wsl

# --------------------------------------------------------------------------------------------------------------------------------

# open wsl filesystem
# https://learn.microsoft.com/en-us/windows/wsl/filesystems
# https://learn.microsoft.com/en-us/windows/wsl/filesystems#view-your-current-directory-in-windows-file-explorer
explorer "\\wsl$"
explorer "\\wsl$\docker-desktop"