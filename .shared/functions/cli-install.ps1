# .shared/functions/cli-install.ps1

# -------------------------------------------------------------------------------------------------
# CLI Install Helper Functions
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Test-ToolInstalled
# -------------------------------------------------------------------------------------------------
# Combines multiple detection methods so a tool isn't reinstalled just because the
# current session PATH hasn't been refreshed after a prior install.
#
# Detection order:
#   1. Command exists in current session PATH
#   2. Refresh PATH from registry and retry
#   3. winget list (handles apps that don't register a PATH entry, e.g. Docker Desktop)
#   4. choco list (local packages)
# -------------------------------------------------------------------------------------------------
function Test-ToolInstalled {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string]$CommandName,
        [Parameter()][string]$Name,
        [Parameter()][string]$WingetId,
        [Parameter()][string]$ChocoId
    )

    # Method 1: Command exists in current session PATH
    if (Get-Command -Name $CommandName -ErrorAction SilentlyContinue) {
        return $true
    }

    # Method 2: Refresh PATH from registry and retry
    # (catches tools installed earlier in this session that haven't propagated)
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
    [System.Environment]::GetEnvironmentVariable('Path', 'User')
    if (Get-Command -Name $CommandName -ErrorAction SilentlyContinue) {
        return $true
    }

    # Method 3: Registry uninstall keys — instant, covers MSI/winget/EXE installs
    # (catches GUI apps like Docker Desktop that don't register a PATH entry)
    if ($Name) {
        $uninstallPaths = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
            'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
            'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
        )
        $found = Get-ItemProperty -Path $uninstallPaths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -and $_.DisplayName -match [regex]::Escape($Name) }
        if ($found) { return $true }
    }

    # Method 4: Chocolatey local package list
    if ($ChocoId -and (Get-Command -Name 'choco' -ErrorAction SilentlyContinue)) {
        $chocoList = & choco list --local-only --exact $ChocoId 2>&1
        if ($chocoList -match $ChocoId) {
            return $true
        }
    }

    return $false
}

# -------------------------------------------------------------------------------------------------
# Install-CliTool
# -------------------------------------------------------------------------------------------------
# Tries Winget first, then Chocolatey as a fallback. Returns $true on success.
# Reads $Winget.Silent, $Choco.Yes/.AcceptLicense/.Force/.Verbose from variable files.
# -------------------------------------------------------------------------------------------------
function Install-CliTool {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$CommandName,
        [Parameter()][string]$WingetId,
        [Parameter()][string]$ChocoId,
        [Parameter()][string]$InstallUrl
    )

    $wingetAvailable = [bool](Get-Command -Name 'winget' -ErrorAction SilentlyContinue)
    $chocoAvailable = [bool](Get-Command -Name 'choco' -ErrorAction SilentlyContinue)

    # ----- Winget (preferred) -----
    if ($WingetId -and $wingetAvailable) {
        Write-StatusMessage -Title $Name -Message "Installing via Winget ($WingetId)"

        $wingetArgs = @('install', '--exact', '--id', $WingetId, '--source', 'winget', '--accept-package-agreements', '--accept-source-agreements')
        if ($Winget.Silent) { $wingetArgs += '--silent' }

        & winget @wingetArgs
        if ($LASTEXITCODE -eq 0) {
            Write-OkMessage -Title $Name -Message "Installed via Winget"
            return $true
        }
        Write-WarnMessage -Title $Name -Message "Winget install failed (exit $LASTEXITCODE) — trying Chocolatey"
    }
    elseif ($WingetId -and -not $wingetAvailable) {
        Write-WarnMessage -Title $Name -Message "Winget not available — skipping to Chocolatey"
    }

    # ----- Chocolatey (fallback) -----
    if ($ChocoId -and $chocoAvailable) {
        Write-StatusMessage -Title $Name -Message "Installing via Chocolatey ($ChocoId)"

        $chocoArgs = @('install', $ChocoId)
        if ($Choco.Yes) { $chocoArgs += '--yes' }
        if ($Choco.AcceptLicense) { $chocoArgs += '--accept-license' }
        if ($Choco.Force) { $chocoArgs += '--force' }
        if ($Choco.Verbose) { $chocoArgs += '--verbose' }

        & choco @chocoArgs
        if ($LASTEXITCODE -eq 0) {
            Write-OkMessage -Title $Name -Message "Installed via Chocolatey"
            return $true
        }
        Write-FailMessage -Title $Name -Message "Chocolatey install also failed (exit $LASTEXITCODE)"
    }
    elseif ($ChocoId -and -not $chocoAvailable) {
        Write-WarnMessage -Title $Name -Message "Chocolatey not available"
    }

    # ----- Both failed -----
    if ($InstallUrl) {
        Write-Var -Name "Manual Install" -Value $InstallUrl -NoIcon
    }
    return $false
}
