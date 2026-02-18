# .shared/index.ps1

. ".shared\types\index.ps1"
. ".shared\variables\global.ps1"
. ".shared\functions\index.ps1"

# ----------------------------------------------------------------------------------------------------------------------

# Load Environment Variables
Write-MastHead "Environment Variables"
$dotEnvResult = Import-DotEnv -Path $Global.DotEnvPath -Scope $Global.DotEnvScope -Force:$Global.DotEnvForce

if (-not $dotEnvResult) {
    Write-FatalMessage -Title "Failed to load environment variables: " -Message $Global.DotEnvPath
    Write-Warn "Aborting further execution." -NoIcon
    exit 1
}

# ----------------------------------------------------------------------------------------------------------------------

. ".shared\variables\index.ps1"