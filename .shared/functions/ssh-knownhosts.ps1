# .shared/functions/ssh-knownhosts.ps1

# ------------------------------------------------------------------------------------------------
# Test-EnsureSshKnownHosts:
# Ensures the SSH known_hosts file exists (creates it if missing).
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function Test-EnsureSshKnownHosts {
    [CmdletBinding()]
    param(
        # SshRootPath:
        # Root SSH directory path (e.g. C:\Users\me\.ssh). If empty, $HOME\.ssh is used.
        [Parameter()]
        [AllowEmptyString()]
        [string]$SshRootPath = ''
    )

    # Guards
    $root = $SshRootPath
    if ([string]::IsNullOrWhiteSpace($root)) {
        $homeDir = if ($HOME) { $HOME } else { [Environment]::GetFolderPath('UserProfile') }
        $root = [System.IO.Path]::Combine($homeDir, ".ssh")
    }

    if (-not (Test-EnsureDirectory -Path $root)) { return $false }

    $knownHostsPath = [System.IO.Path]::Combine($root, "known_hosts")

    if (Test-Path -LiteralPath $knownHostsPath -PathType Leaf) {
        Write-OkMessage -Title "known_hosts exists" -Message $knownHostsPath
        return $true
    }

    try {
        New-Item -ItemType File -Path $knownHostsPath -Force -ErrorAction Stop | Out-Null
        Write-OkMessage -Title "known_hosts created" -Message $knownHostsPath
        return $true
    }
    catch {
        Write-FailMessage -Title "known_hosts failed" -Message $knownHostsPath
        Write-Warn (($_ | Out-String).Trim())
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# New-SshKnownHostKey:
# Adds a host key to known_hosts using ssh-keyscan (best-effort).
# If ssh-keyscan fails, falls back to ssh StrictHostKeyChecking=accept-new to learn the host key.
# Appends new entries only; does not overwrite existing file.
# Returns $true if keys were added or already present, $false on failure.
# ------------------------------------------------------------------------------------------------
function New-SshKnownHostKey {
    [CmdletBinding()]
    param(
        # HostName:
        # Host to scan/learn (e.g. 'github.com', 'ssh.dev.azure.com').
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$HostName,

        # Port:
        # SSH port to scan/connect (default 22).
        [Parameter()]
        [ValidateRange(1,65535)]
        [int]$Port = 22,

        # KnownHostsPath:
        # Optional explicit known_hosts path. If empty, uses $HOME\.ssh\known_hosts.
        [Parameter()]
        [AllowEmptyString()]
        [string]$KnownHostsPath = ''
    )

    # Guards
    $hostClean = $HostName.Trim()

    $kh = $KnownHostsPath
    if ([string]::IsNullOrWhiteSpace($kh)) {
        $homeDir = if ($HOME) { $HOME } else { [Environment]::GetFolderPath('UserProfile') }
        $kh = [System.IO.Path]::Combine($homeDir, ".ssh", "known_hosts")
    }

    $khParent = Split-Path -Path $kh -Parent
    if (-not (Test-EnsureSshKnownHosts -SshRootPath $khParent)) { return $false }

    # If already present (simple match), skip work
    try {
        $existingLines = Get-Content -LiteralPath $kh -ErrorAction Stop
        if ($existingLines -match [regex]::Escape($hostClean)) {
            Write-OkMessage -Title "Host present" -Message $hostClean
            return $true
        }
    }
    catch {
        Write-WarnMessage -Title "known_hosts" -Message "Read failed; continuing"
    }

    # ------------------------------------------------------------------------------------------------
    # Attempt 1: ssh-keyscan
    # ------------------------------------------------------------------------------------------------
    if (Test-Command -Name 'ssh-keyscan') {

        Write-StatusMessage -Title "known_hosts" -Message "Scanning $hostClean (port $Port)"
        Write-Host "ssh-keyscan -p $Port $hostClean >> `"$kh`"" -ForegroundColor Cyan

        try {
            $scanOut = & ssh-keyscan -p $Port $hostClean 2>&1
            $exit    = $LASTEXITCODE
            $scanTxt = ($scanOut | Out-String).Trim()

            if ($exit -eq 0 -and -not [string]::IsNullOrWhiteSpace($scanTxt)) {

                $existing = @()
                try { $existing = Get-Content -LiteralPath $kh -ErrorAction Stop } catch { $existing = @() }

                $toAdd = @($scanTxt -split "`r?`n") | Where-Object { $_ -and ($existing -notcontains $_) }

                if (@($toAdd).Count -eq 0) {
                    Write-OkMessage -Title "Host present" -Message $hostClean
                    return $true
                }

                $toAdd | Add-Content -LiteralPath $kh -Encoding utf8 -ErrorAction Stop
                Write-OkMessage -Title "Host key added" -Message $hostClean
                return $true
            }

            Write-WarnMessage -Title "Keyscan failed" -Message "$hostClean (exit $exit)"
            if ($scanTxt) { Write-Warn $scanTxt }
        }
        catch {
            Write-WarnMessage -Title "Keyscan error" -Message $hostClean
            Write-Warn (($_ | Out-String).Trim())
        }
    }
    else {
        Write-WarnMessage -Title "Keyscan" -Message "ssh-keyscan missing; skipped"
    }

    # ------------------------------------------------------------------------------------------------
    # Attempt 2: ssh StrictHostKeyChecking=accept-new (learn host key even if auth fails)
    # Hard timeout to prevent PowerShell hangs
    # ------------------------------------------------------------------------------------------------
    if (-not (Test-Command -Name 'ssh')) {
        Write-FailMessage -Title "known_hosts" -Message "ssh missing; cannot learn host key"
        return $false
    }

    Write-StatusMessage -Title "known_hosts" -Message "Fallback learn $hostClean (port $Port)"

    $sshArgs = @(
        '-p', $Port,
        '-o', 'StrictHostKeyChecking=accept-new',
        '-o', 'BatchMode=yes',
        '-o', 'PreferredAuthentications=none',
        '-o', 'PasswordAuthentication=no',
        '-o', 'KbdInteractiveAuthentication=no',
        '-o', 'ConnectTimeout=8',
        '-o', 'ConnectionAttempts=1',
        "git@$hostClean"
    )

    Write-Host ("ssh " + ($sshArgs -join ' ')) -ForegroundColor Cyan

    $tmpStdOut = ''
    $tmpStdErr = ''

    try {
        $tmpStdOut = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "ssh-knownhosts-$([Guid]::NewGuid().ToString('N'))-out.log")
        $tmpStdErr = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "ssh-knownhosts-$([Guid]::NewGuid().ToString('N'))-err.log")

        $proc = Start-Process -FilePath 'ssh' -ArgumentList $sshArgs -NoNewWindow -PassThru `
            -RedirectStandardOutput $tmpStdOut -RedirectStandardError $tmpStdErr

        if (-not $proc) {
            Write-FailMessage -Title "known_hosts" -Message "Failed to start ssh process"
            return $false
        }

        $timeoutSeconds = 12
        $exited = $proc.WaitForExit($timeoutSeconds * 1000)

        if (-not $exited) {
            try { $proc.Kill() } catch {}
            Write-WarnMessage -Title "known_hosts" -Message "Fallback timed out; skipped"
            return $false
        }

        $existingAfter = @()
        try { $existingAfter = Get-Content -LiteralPath $kh -ErrorAction Stop } catch { $existingAfter = @() }

        if ($existingAfter -match [regex]::Escape($hostClean)) {
            Write-OkMessage -Title "Host key learned" -Message $hostClean
            return $true
        }

        $sshErr = ''
        try { $sshErr = (Get-Content -LiteralPath $tmpStdErr -Raw -ErrorAction SilentlyContinue).Trim() } catch {}

        Write-FailMessage -Title "Add host failed" -Message $hostClean
        if ($sshErr) { Write-Warn $sshErr }
        return $false
    }
    catch {
        Write-FailMessage -Title "Add host failed" -Message $hostClean
        Write-Warn (($_ | Out-String).Trim())
        return $false
    }
    finally {
        if ($tmpStdOut -and (Test-Path -LiteralPath $tmpStdOut)) { Remove-Item -LiteralPath $tmpStdOut -Force -ErrorAction SilentlyContinue | Out-Null }
        if ($tmpStdErr -and (Test-Path -LiteralPath $tmpStdErr)) { Remove-Item -LiteralPath $tmpStdErr -Force -ErrorAction SilentlyContinue | Out-Null }
    }
}
