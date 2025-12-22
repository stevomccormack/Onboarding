# 03 - ms-windows-update.ps1

# ------------------------------------------------------------------------------------------------
# Windows Update
# ------------------------------------------------------------------------------------------------
# Automates Windows Update operations using the PSWindowsUpdate module.
# This script checks for available updates, installs them, and provides update history.
#
# References:
# - https://winstall.app/
# - https://adamtheautomator.com/pswindowsupdate/
#
# Prerequisites:
# - PowerShell 5.1 or higher
# - Administrator privileges
# - Internet connection
# ------------------------------------------------------------------------------------------------

Write-MastHead "Windows Update"

# ------------------------------------------------------------------------------------------------
# Install Windows Update Module
# ------------------------------------------------------------------------------------------------

if (-not (Get-Module -ListAvailable -Name PowerShellGet)) {
    Write-Error "PowerShellGet module is not available. Please install PowerShell 5.1 or higher."
    exit 1
}

Import-Module -Name PowerShellGet -ErrorAction Stop
Install-Module -Name PSWindowsUpdate -Repository PSGallery -Force -Scope CurrentUser
Write-Ok "Installed PSWindowsUpdate module"

# ------------------------------------------------------------------------------------------------
# Check for available Windows updates
# ------------------------------------------------------------------------------------------------

Write-Status "Checking for available Windows updates (may take some time)..."
$AvailableUpdates = Get-WindowsUpdate

if ($null -eq $AvailableUpdates -or $AvailableUpdates.Count -eq 0) {
    Write-Host "No updates available. System is up to date." -ForegroundColor Green
    exit 0
}

Write-Status "Available Windows Updates:"
$AvailableUpdates | Format-Table -Property Title, Size, Status -AutoSize

# ------------------------------------------------------------------------------------------------
# Download and install all available Windows updates
# ------------------------------------------------------------------------------------------------
if ($AvailableUpdates.Count -gt 0) {
    Write-Status "Installing available updates..."
    Install-WindowsUpdate -AcceptAll -AutoReboot
    Write-Ok "Windows updates installed successfully."
}

# ------------------------------------------------------------------------------------------------
# List Windows update history
# ------------------------------------------------------------------------------------------------
# Get-WUHistory

# Remove a specific update by KB article ID (uncomment and modify as needed)
# Remove-WindowsUpdate -KBArticleID KB2267602 