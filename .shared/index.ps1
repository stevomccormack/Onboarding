# .shared/index.ps1

. ".shared\types\index.ps1"
. ".shared\variables\global.ps1"
. ".shared\functions\index.ps1"

# ----------------------------------------------------------------------------------------------------------------------

# Load Environment Variables
Write-MastHead "Environment Variables"
$dotEnvResult = Import-DotEnv -Path $Global.DotEnvPath -Scope $Global.DotEnvScope -Force:$Global.DotEnvForce

if (-not $dotEnvResult) {
    Write-WarnMessage -Title "Environment variables" -Message "One or more variables already exist with different values and -Force is not set."
    $choice = Write-Choice -Prompt "Force overwrite existing environment variables?"
    switch ($choice) {
        'Yes' {
            $dotEnvResult = Import-DotEnv -Path $Global.DotEnvPath -Scope $Global.DotEnvScope -Force
            if (-not $dotEnvResult) {
                Write-FatalMessage -Title "Failed to load environment variables" -Message $Global.DotEnvPath
                Write-Fatal "Aborting further execution." -NoIcon
                exit 1
            }
        }
        'Skip' {
            Write-Warn "Skipping environment variable failure. Some variables may be outdated." -NoIcon
        }
        default {
            Write-FatalMessage -Title "Failed to load environment variables" -Message $Global.DotEnvPath
            Write-Fatal "Aborting further execution." -NoIcon
            exit 1
        }
    }
}

# ----------------------------------------------------------------------------------------------------------------------

. ".shared\variables\index.ps1"