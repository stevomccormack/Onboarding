# .shared/index.ps1

. ".shared\types\index.ps1"
. ".shared\variables\global.ps1"
. ".shared\functions\index.ps1"

# ----------------------------------------------------------------------------------------------------------------------

# Load Environment Variables
Write-MastHead "Environment Variables"
$dotEnvResult = Import-DotEnv -Path $Global.DotEnvPath -Scope $Global.DotEnvScope -Force:$Global.DotEnvForce

if (-not $dotEnvResult) {
    Write-FatalMessage -Title "Failed to load environment variables from" -Message $Global.DotEnvPath
    Write-Warn "Aborting further execution. Check the environment variable configuration." -NoIcon
    Write-Info "Opening .env file...." -NoIcon
    Start-Process -FilePath "notepad.exe" -ArgumentList "`"$($Global.DotEnvPath)`""
    exit 1
}

# ----------------------------------------------------------------------------------------------------------------------

. ".shared\variables\index.ps1"