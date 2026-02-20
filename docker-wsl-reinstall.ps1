# 52 - docker-wsl-reinstall.ps1

# --------------------------------------------------------------------------------------------------------------------------------
# Setup Variables
# --------------------------------------------------------------------------------------------------------------------------------



# Uninstall Docker & WSL
# --------------------------------------------------------------------------------------------------------------------------------

# nuke all
docker kill $(docker ps -q)
docker rm $(docker ps -q)
docker rmi $(docker ps -q)

# uninstall docker desktop
winget list | Select-String "Docker"
winget uninstall --id "Docker.DockerDesktop" --exact

# remove distros
wsl --list
wsl --unregister docker-desktop
wsl --unregister docker-desktop-data

# uninstall wsl
winget list --name "Windows Subsystem for Linux" #| Select-String "Windows Subsystem for Linux"
winget uninstall --id "MicrosoftCorporationII.WindowsSubsystemForLinux_8wekyb3d8bbwe"
winget uninstall --id "{F8474A47-8B5D-4466-ACE3-78EAB3BF21A8}"

# disable wsl & virtualisation
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

# --------------------------------------------------------------------------------------------------------------------------------

# enable wsl & virtualisation
Enable-WindowsOptionalFeature -Online -Feature VirtualMachinePlatform -NoRestart
Enable-WindowsOptionalFeature -Online -Feature Microsoft-Windows-Subsystem-Linux -NoRestart

# dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# check wsl
wsl
wsl --list
wsl -l -o

# update - otherwise WSL2 will not install = "requires update to kernel"
wsl --update

# set wsl2
wsl --set-default-version 2

# install docker-desktop (installs its own distro)
winget install --id Docker.DockerDesktop --exact

# find system type (used to install distros)
systeminfo | find "System Type"

# install wsl
# $windowsDistro = "Ubuntu"
# wsl --install #iff fails, run next
# wsl --install -d $windowsDistro
# wsl --unregister $windowsDistro

# config
Copy-Item -Path $wslConfigSourcePath -Destination $wslConfigTargetPath -Force
wsl --shutdown
wsl

# open distros
explorer "\\wsl$"
explorer "\\wsl$\docker-desktop"
explorer "\\wsl$\docker-desktop-data"

# --------------------------------------------------------------------------------------------------------------------------------

# Health check - diagnose
& "$env:ProgramFiles\Docker\Docker\resources\com.docker.diagnose.exe" check

    # [FAIL] DD00029: is the WSL 2 Linux filesystem corrupt?
    wsl --shutdown # fixes error, shutdown and restart PC will run the disc check and fix error