# 10 - cli-install.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "Chocolatey Installation"

# ------------------------------------------------------------------------------------------------
# Chocolatey
# ------------------------------------------------------------------------------------------------
Write-Header "Chocolatey Package Manager (Choco)"

# Detection: command lookup + registry + version check
# (choco may be installed but not yet in PATH if session hasn't been refreshed)
$chocoCommand = Get-Command -Name 'choco' -ErrorAction SilentlyContinue
$chocoRegistry = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Chocolatey' -ErrorAction SilentlyContinue
$chocoPath = if ($env:ChocolateyInstall) { Join-Path $env:ChocolateyInstall 'bin\choco.exe' } else { $null }

$chocoDetected = $chocoCommand -or $chocoRegistry -or ($chocoPath -and (Test-Path $chocoPath))

if ($chocoDetected -and -not $chocoCommand) {
    Write-WarnMessage -Title "Chocolatey" -Message "Installed but not in PATH — refreshing environment"
    # Refresh PATH from registry so subsequent commands find choco
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
    [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $chocoCommand = Get-Command -Name 'choco' -ErrorAction SilentlyContinue
}

if ($chocoCommand) {
    $chocoVersion = & choco --version 2>&1
    Write-OkMessage -Title "Chocolatey" -Message "Already installed"
    Write-Var -Name "Version" -Value $chocoVersion -NoIcon
}
else {
    Write-StatusMessage -Title "Chocolatey" -Message "Not found — installing"
    $chocoInstalled = Install-Chocolatey

    if (-not $chocoInstalled) {
        Write-FailMessage -Title "Chocolatey" -Message "Installation failed. See above for details."
        Write-Var -Name "Manual Install URL" -Value $Choco.InstallUrl -NoIcon
    }
}