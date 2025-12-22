# 51 - wsl.ps1

. ".shared\index.ps1"

# --------------------------------------------------------------------------------------------------------------------------------

# wsl
$wslFeatureName = "Microsoft-Windows-Subsystem-Linux"
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName $wslFeatureName
if (($wslFeature | Select-Object -ExpandProperty State) -ne "Enabled")
{
    Enable-WindowsOptionalFeature -Online -FeatureName $wslFeatureName -NoRestart
}
else{
    $wslFeature
}

# vm
$vmFeatureName = "Microsoft-Windows-Subsystem-Linux"
$vmFeature = Get-WindowsOptionalFeature -Online -FeatureName $vmFeatureName
if (($vmFeature | Select-Object -ExpandProperty State) -ne "Enabled")
{
    Enable-WindowsOptionalFeature -Online -FeatureName $vmFeatureName -NoRestart
}
else{
    $vmFeature
}

# --------------------------------------------------------------------------------------------------------------------------------

# check wsl
if (Get-Command -Name 'wsl' -ErrorAction Ignore){
    exit 0
}

# list
wsl
wsl --list
wsl -l -o

# update
wsl --update

# set default version
wsl --set-default-version 2

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