# 10 - cli-install.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "Winget Installation"

# ------------------------------------------------------------------------------------------------
# Winget
# ------------------------------------------------------------------------------------------------
Write-Header "Windows Package Manager (Winget)"

# Detection: Try command lookup AND winget list to confirm it is functional
$wingetCommand = Get-Command -Name 'winget' -ErrorAction SilentlyContinue
$wingetFunctional = $false

if ($wingetCommand) {
    # Extra check: winget --version may still fail if App Installer is broken
    $wingetVersion = & winget --version 2>&1
    if ($LASTEXITCODE -eq 0 -and $wingetVersion) {
        $wingetFunctional = $true
    }
}

if ($wingetFunctional) {
    Write-OkMessage -Title "Winget" -Message "Already installed and functional"
    Write-Var -Name "Version" -Value $wingetVersion -NoIcon
}
else {
    Write-WarnMessage -Title "Winget" -Message "Not found or not functional"
    Write-Status "Winget is included with Windows 11 App Installer."
    Write-Status "To install manually, open the Microsoft Store and update 'App Installer'."
    Write-Var -Name "Install URL" -Value $Winget.InstallUrl -NoIcon

    # Attempt to install via Microsoft Store (ms-windows-store URI)
    Write-StatusMessage -Title "Winget" -Message "Attempting to open Microsoft Store to install App Installer..."
    Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1"

    Write-WarnMessage -Title "Winget" -Message "Please install App Installer from the Store, then re-run this script."
}