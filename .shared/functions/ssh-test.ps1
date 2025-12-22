# .shared/functions/ssh-test.ps1

# ------------------------------------------------------------------------------------------------
# Test-SshConnection:
# Tests SSH authentication to a host using ssh in batch mode (non-interactive).
# Supports an optional identity file. Returns $true on auth success, otherwise $false.
#
# Fixes:
# - Azure DevOps returns "Shell access is not supported." when auth is OK (and may exit 255). Treat as success.
# - Success detection is output-based (GitHub/Azure) rather than exit-code based.
# - Optional KEX fallback for known Windows/OpenSSH KEX mismatch issues.
# ------------------------------------------------------------------------------------------------
function Test-SshConnection {
    [CmdletBinding()]
    param (
        # UserName:
        # SSH username (e.g. 'git').
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$UserName,

        # HostName:
        # SSH host (e.g. 'github.com' or 'ssh.dev.azure.com').
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$HostName,

        # IdentityFilePath:
        # Optional full path to a private key file to use (-i). Empty means default SSH identity search.
        [Parameter()]
        [AllowEmptyString()]
        [string]$IdentityFilePath = '',

        # Description:
        # Optional friendly label for logging (defaults to UserName@HostName).
        [Parameter()]
        [AllowEmptyString()]
        [string]$Description = '',

        # EnableKexFallback:
        # When true, retries once with a conservative KEX list if a KEX mismatch is detected.
        [Parameter()]
        [switch]$EnableKexFallback
    )

    # Guards
    if (-not (Test-Command -Name 'ssh')) {
        throw "ssh command not found - install OpenSSH"
    }

    $userClean = $UserName.Trim()
    $hostClean = $HostName.Trim()
    $target = "$userClean@$hostClean"

    # --------------------------------------------------------------------------------------------

    $label = $target
    if (-not [string]::IsNullOrWhiteSpace($Description)) {
        $label = $Description.Trim()
        if (-not $label) { $label = $target }
    }

    $identityClean = $IdentityFilePath
    if (-not [string]::IsNullOrWhiteSpace($identityClean)) {
        $identityClean = $identityClean.Trim()
        if (-not (Test-Path -LiteralPath $identityClean -PathType Leaf)) {
            Write-FailMessage -Title "Identity missing" -Message $identityClean
            return $false
        }
    }
    else {
        $identityClean = ''
    }

    Write-Header "SSH Test"
    Write-Var -Name "Target" -Value $target
    Write-Var -Name "Label"  -Value $label
    if ($identityClean) { Write-Var -Name "IdentityFilePath" -Value $identityClean }
    Write-Var -Name "EnableKexFallback" -Value $EnableKexFallback.IsPresent

    $baseArgs = @(
        '-T', $target,
        '-o', 'BatchMode=yes',
        '-o', 'StrictHostKeyChecking=accept-new',
        '-o', 'ConnectTimeout=8'
    )

    if ($identityClean) {
        $baseArgs += @('-i', $identityClean, '-o', 'IdentitiesOnly=yes')
    }

    function Invoke-SshTest {
        # ArgsList:
        # Fully constructed argument list to pass directly to ssh.
        # Example:
        # @('-T','git@ssh.dev.azure.com','-o','BatchMode=yes','-o','StrictHostKeyChecking=accept-new','-o','ConnectTimeout=8','-i','C:\Users\me\.ssh\id_azuredevops_myorg','-o','IdentitiesOnly=yes')
        param([string[]]$ArgsList)

        $echoArgs = @('ssh') + ($ArgsList | ForEach-Object { if ($_ -match '\s') { "`"$_`"" } else { $_ } })
        Write-StatusMessage -Title "SSH Test" -Message "Running authentication test"
        Write-Host ($echoArgs -join ' ') -ForegroundColor Cyan

        $output = & ssh @ArgsList 2>&1
        $exit   = $LASTEXITCODE

        return [pscustomobject]@{
            Output = ($output | Out-String).Trim()
            Exit   = $exit
        }
    }

    try {
        $result = Invoke-SshTest -ArgsList $baseArgs

        $output = $result.Output
        $exit   = $result.Exit

        $isKexMismatch =
            ($output -match 'unsupported KEX method') -or
            ($output -match 'no matching key exchange method found') -or
            ($output -match 'kex_exchange_identification') -or
            ($output -match 'Unable to negotiate')

        if ($EnableKexFallback.IsPresent -and $isKexMismatch) {
            Write-WarnMessage -Title "SSH Test" -Message "KEX mismatch detected. Retrying with conservative KexAlgorithms..."

            $kexFallback = 'curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group14-sha256,diffie-hellman-group14-sha1'
            $fallbackArgs = @($baseArgs) + @('-o', "KexAlgorithms=$kexFallback")

            $result = Invoke-SshTest -ArgsList $fallbackArgs
            $output = $result.Output
            $exit   = $result.Exit
        }

        $isGitHubSuccess =
            ($output -match 'successfully authenticated') -or
            ($output -match 'Hi\s+.+!\s+You''ve successfully authenticated')

        # Azure DevOps "success" signals:
        # - "Welcome to Azure DevOps" (sometimes)
        # - "remote: Shell access is not supported." (common; key accepted, but no interactive shell)
        $isAzureSuccess =
            ($output -match 'Welcome to Azure DevOps') -or
            ($output -match 'remote:\s*Shell access is not supported\.') -or
            ($output -match 'shell request failed on channel 0') -or
            ($output -match 'Authentication succeeded') -or
            ($output -match 'Signed in')

        $isSuccess = $isGitHubSuccess -or $isAzureSuccess

        if ($isSuccess) {
            if ($output) { Write-Warn $output }
            Write-OkMessage -Title "SSH auth ok" -Message $label
            return $true
        }

        if ($output) { Write-Warn $output }
        Write-FailMessage -Title "SSH auth failed" -Message "$label (exit $exit)"
        return $false
    }
    catch {
        Write-Warn $_.Exception.Message
        Write-FailMessage -Title "SSH test failed" -Message $label
        return $false
    }
}


# ------------------------------------------------------------------------------------------------
# Test-SshDebug:
# Runs an interactive SSH debug session using OpenSSH with selectable verbosity.
# Supports -v (once) and -vvv (triple) with optional user, port, and identity file.
# Returns $true when ssh exits with code 0, otherwise $false.
# ------------------------------------------------------------------------------------------------
function Test-SshDebug {
    [CmdletBinding()]
    param (
        # HostName:
        # SSH host domain (e.g. 'ssh.dev.azure.com', 'github.com').
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$HostName,

        # Port:
        # SSH port (default 22).
        [Parameter()]
        [ValidateRange(1,65535)]
        [int]$Port = 22,

        # UserName:
        # Optional SSH username. When provided, target becomes 'UserName@HostName'.
        [Parameter()]
        [AllowEmptyString()]
        [string]$UserName = '',

        # IdentityFilePath:
        # Optional full path to a private key file to use (-i).
        [Parameter()]
        [AllowEmptyString()]
        [string]$IdentityFilePath = '',

        # Verbosity:
        # Verbosity level. Use 1 for -v, 3 for -vvv.
        [Parameter()]
        [ValidateSet(1,3)]
        [int]$Verbosity = 1,

        # AllocateTty:
        # When specified, adds -t (TTY allocation) for interactive debug runs.
        [Parameter()]
        [switch]$AllocateTty,

        # ExtraArgs:
        # Optional additional ssh args to append (e.g. @('-o','IdentitiesOnly=yes')).
        [Parameter()]
        [AllowNull()]
        [string[]]$ExtraArgs = @()
    )

    if (-not (Test-Command -Name 'ssh')) {
        throw "ssh command not found - install OpenSSH"
    }

    $hostClean = $HostName.Trim()

    $userClean = $UserName
    if (-not [string]::IsNullOrWhiteSpace($userClean)) { $userClean = $userClean.Trim() }

    $target = $hostClean
    if (-not [string]::IsNullOrWhiteSpace($userClean)) { $target = "$userClean@$hostClean" }

    $identityClean = $IdentityFilePath
    if (-not [string]::IsNullOrWhiteSpace($identityClean)) {
        $identityClean = $identityClean.Trim()
        if (-not (Test-Path -LiteralPath $identityClean -PathType Leaf)) {
            Write-FailMessage -Title "Identity missing" -Message $identityClean
            return $false
        }
    }
    else {
        $identityClean = ''
    }

    $vFlag = '-v'
    if ($Verbosity -eq 3) { $vFlag = '-vvv' }

    Write-Header "SSH Debug"
    Write-Var -Name "Target"           -Value $target
    Write-Var -Name "Port"             -Value $Port
    Write-Var -Name "Verbosity"        -Value $Verbosity
    Write-Var -Name "AllocateTty"      -Value $AllocateTty.IsPresent
    if ($identityClean) { Write-Var -Name "IdentityFilePath" -Value $identityClean }

    $argsList = @()

    $argsList += $vFlag

    if ($AllocateTty.IsPresent) {
        $argsList += '-t'
    }

    $argsList += @($target, '-p', "$Port")

    if ($identityClean) {
        $argsList += @('-i', $identityClean)
    }

    if ($ExtraArgs -and $ExtraArgs.Count -gt 0) {
        $argsList += $ExtraArgs
    }

    $echoArgs = @('ssh') + ($argsList | ForEach-Object { if ($_ -match '\s') { "`"$_`"" } else { $_ } })

    Write-StatusMessage -Title "SSH Debug" -Message "Launching interactive debug session"
    Write-WarnMessage -Title "SSH Debug" -Message "Close the SSH session (type 'exit' or close the window) to continue."
    Write-Host ($echoArgs -join ' ') -ForegroundColor Cyan

    try {
        & ssh @argsList
        $exit = $LASTEXITCODE

        if ($exit -eq 0) {
            Write-OkMessage -Title "SSH debug exit" -Message "Exit $exit"
            return $true
        }

        Write-FailMessage -Title "SSH debug exit" -Message "Exit $exit"
        return $false
    }
    catch {
        Write-FailMessage -Title "SSH debug failed" -Message $target
        Write-Warn $_.Exception.Message
        return $false
    }
}