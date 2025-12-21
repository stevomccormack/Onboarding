# ssh-agent.ps1

# ------------------------------------------------------------------------------------------------
# New-SshAgentKey:
# Adds an SSH private key to the ssh-agent using ssh-add.
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function New-SshAgentKey {
    [CmdletBinding()]
    param (
        # KeyFilePath:
        # Full path to the SSH private key file to add (e.g. C:\Users\me\.ssh\id_ed25519).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyFilePath
    )

    # Guards
    if (-not (Test-Command -Name 'ssh-add')) {
        Write-WarnMessage -Title "ssh-add missing" -Message "Skipping"
        return $false
    }

    if (-not (Test-Path -LiteralPath $KeyFilePath -PathType Leaf)) {
        Write-FailMessage -Title "SSH key not found" -Message $KeyFilePath
        return $false
    }

    Write-StatusMessage -Title "SSH Agent" -Message "Adding key"
    Write-Var -Name "KeyFilePath" -Value $KeyFilePath
    Write-Host "ssh-add $KeyFilePath" -ForegroundColor Cyan

    try {
        $output = & ssh-add $KeyFilePath 2>&1
        $exit   = $LASTEXITCODE

        if ($exit -eq 0) {
            Write-OkMessage -Title "SSH key added" -Message $KeyFilePath
            return $true
        }

        Write-FailMessage -Title "ssh-add failed" -Message "Exit $exit"
        if ($output) { Write-Warn $output }
        return $false
    }
    catch {
        Write-FailMessage -Title "SSH agent failed" -Message $KeyFilePath
        Write-Warn $_.Exception.Message
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# Test-EnsureSshAgent:
# Validates the Windows ssh-agent service exists and optionally sets StartupType and/or starts it.
# Returns $true when ssh-agent is available and ready, otherwise $false.
# ------------------------------------------------------------------------------------------------
function Test-EnsureSshAgent {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # StartupType:
        # Optional startup type to apply to the ssh-agent service: Automatic, Manual, or Disabled.
        [Parameter()]
        [ValidateSet('Automatic','Manual','Disabled')]
        [string]$StartupType,

        # StartService:
        # Starts the ssh-agent service if it is not already running.
        [Parameter()]
        [switch]$StartService
    )

    # Guards
    if (-not (Test-Command -Name 'ssh-agent')) {
        Write-FailMessage -Title "SSH Agent" -Message "[ssh-agent] command missing. Try installing OpenSSH Client feature."
        return $false
    }

    $service = Get-Service -Name 'ssh-agent' -ErrorAction SilentlyContinue
    if (-not $service) {
        Write-FailMessage -Title "SSH Agent" -Message "[ssh-agent] service not found"
        return $false
    }

    Write-StatusMessage -Title "SSH Agent" -Message "Checking [ssjh-agent] service status..."
    Write-Var -Name "Service" -Value $service.Name -NoNewLine -NoIcon
    Write-Var -Name "Status"  -Value $service.Status -NoNewLine -NoIcon
    Write-Var -Name "Startup" -Value $service.StartType -NoNewLine -NoIcon

    if ($StartupType) {

        if ($PSCmdlet.ShouldProcess("ssh-agent", "Set StartupType to $StartupType")) {
            try {
                Set-Service -Name 'ssh-agent' -StartupType $StartupType -ErrorAction Stop
                Write-OkMessage -Title "SSH Agent" -Message "StartupType set to $StartupType"
            }
            catch {
                Write-FailMessage -Title "SSH Agent" -Message "Failed to set StartupType to $StartupType"
                Write-Warn $_.Exception.Message -NoIcon
                return $false
            }
        }
    }

    if ($StartService.IsPresent -and $service.Status -ne 'Running') {
        Write-StatusMessage -Title "SSH Agent" -Message "Starting service"

        if ($PSCmdlet.ShouldProcess("ssh-agent", "Start service")) {
            try {
                Start-Service -Name 'ssh-agent' -ErrorAction Stop
                Write-OkMessage -Title "SSH Agent" -Message "Service started and running"
            }
            catch {
                Write-FailMessage -Title "SSH Agent" -Message "Service start failed".
                Write-Warn $_.Exception.Message -NoIcon
                return $false
            }
        }
    }

    try {
        $service.Refresh()
        Write-OkMessage -Title "SSH Agent" -Message "Status: $($service.Status)"
        return $true
    }
    catch {
        Write-FailMessage -Title "SSH Agent refresh failed" -Message "Unexpected error"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# Clear-SshAgentKeys:
# Removes all SSH keys from the ssh-agent.
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function Clear-SshAgentKeys {
    [CmdletBinding()]
    param ()

    # Guards
    if (-not (Test-Command -Name 'ssh-add')) {
        Write-WarnMessage -Title "ssh-add missing" -Message "Cannot clear SSH agent keys"
        return $false
    }

    Write-StatusMessage -Title "SSH Agent" -Message "Removing all keys from agent"
    Write-Host "ssh-add -D" -ForegroundColor Cyan

    try {
        $output = & ssh-add -D 2>&1
        $exit   = $LASTEXITCODE

        if ($exit -eq 0) {
            Write-OkMessage -Title "SSH Agent" -Message "All keys removed from agent"
            return $true
        }

        Write-FailMessage -Title "ssh-add -D failed" -Message "Exit $exit"
        if ($output) { Write-Warn $output }
        return $false
    }
    catch {
        Write-FailMessage -Title "SSH Agent" -Message "Failed to clear keys"
        Write-Warn $_.Exception.Message
        return $false
    }
}
