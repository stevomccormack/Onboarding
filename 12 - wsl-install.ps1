# 12 - wsl-install.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "Windows Subsystem for Linux (WSL) Installation"

# --------------------------------------------------------------------------------------------------------------------------------

Write-Header "Windows Optional Feature: Windows Subsystem for Linux (WSL)"

$wslFeatureName = "Microsoft-Windows-Subsystem-Linux"
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName $wslFeatureName
if (($wslFeature | Select-Object -ExpandProperty State) -ne "Enabled") {
    Write-Status "Enabling $wslFeatureName..."
    Enable-WindowsOptionalFeature -Online -FeatureName $wslFeatureName -NoRestart
    Write-WarnMessage -Title "Reboot Required" -Message "Restart Windows is required to use WSL CLI and WSL distributions."
}
else {
    $wslFeature
}
Write-OkMessage -Title "Windows Optional Feature" -Message "$wslFeatureName is enabled"

# --------------------------------------------------------------------------------------------------------------------------------

Write-Header "Windows Optional Feature: Virtual Machine Platform (WSL 2)"

$vmFeatureName = "VirtualMachinePlatform"
$vmFeature = Get-WindowsOptionalFeature -Online -FeatureName $vmFeatureName
if (($vmFeature | Select-Object -ExpandProperty State) -ne "Enabled") {
    Write-Status "Enabling $vmFeatureName..."
    Enable-WindowsOptionalFeature -Online -FeatureName $vmFeatureName -NoRestart
    Write-WarnMessage -Title "Reboot Required" -Message "Restart Windows is required to use WSL CLI and WSL distributions."
}
else {
    $vmFeature
}
Write-OkMessage -Title "Windows Optional Feature" -Message "$vmFeatureName is enabled"

# --------------------------------------------------------------------------------------------------------------------------------

