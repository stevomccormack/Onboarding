# 51 - wsl-config.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "Windows Subsystem for Linux (WSL) Configuration"

# --------------------------------------------------------------------------------------------------------------------------------

Write-Header "WSL Update"
Write-Status "Updating WSL..."

# Update WSL
Write-Command "wsl --update"                    
wsl --update

# Set default version to 2
Write-Command "wsl --set-default-version 2"     
wsl --set-default-version 2     

Write-OkMessage -Title "WSL Update" -Message "WSL has been updated"

# --------------------------------------------------------------------------------------------------------------------------------

Write-Header "WSL Distributions"
Write-Status "Listing installed WSL distributions..."

# List installed distros
Write-Command "wsl --list"       
wsl --list       

# List available distros in the Microsoft Store       
# Write-Command "wsl --list --online"     
# wsl --list --online  

# --------------------------------------------------------------------------------------------------------------------------------

Write-Header "WSL Configuration"
Write-Status "Configuring WSL..."

# copy config
Write-Status "Copying WSL config $($Wsl.ConfigSourcePath) to $($Wsl.ConfigTargetPath)." -ForegroundColor DarkGray
Copy-Item -Path $Wsl.ConfigSourcePath -Destination $Wsl.ConfigTargetPath -Force

# restart wsl
Write-Status "WSL has been shutdown and restarted!"
Write-Command "wsl --shutdown  && wsl --exec /bin/true" 
wsl --shutdown
wsl --exec /bin/true    # Start WSL without dropping into interactive terminal

Write-OkMessage -Title "WSL Configuration" -Message "WSL has been configured"

# --------------------------------------------------------------------------------------------------------------------------------

# open wsl filesystem
# https://learn.microsoft.com/en-us/windows/wsl/filesystems
# https://learn.microsoft.com/en-us/windows/wsl/filesystems#view-your-current-directory-in-windows-file-explorer
# explorer "\\wsl$"
# explorer "\\wsl$\docker-desktop"
# explorer "\\wsl$\ubuntu-24.04"