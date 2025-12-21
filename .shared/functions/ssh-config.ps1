# ssh-config.ps1

# ------------------------------------------------------------------------------------------------
# New-SshHostConfigBlock:
# Builds an SSH config "Host" block as text for a single host alias.
# Returns the block as a string.
# ------------------------------------------------------------------------------------------------
function New-SshHostConfigBlock {
    [CmdletBinding()]
    param (
        # HostAlias:
        # SSH host alias used in config (e.g. 'github.com-myorg').
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$HostAlias,

        # HostName:
        # SSH host name (e.g. 'github.com' or 'ssh.dev.azure.com').
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$HostName,

        # IdentityFileName:
        # SSH private key file name (e.g. 'id_ed25519_github') stored under ~/.ssh/.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$IdentityFileName,

        # User:
        # SSH user (default: 'git').
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$User = 'git'
    )

    # Guards
    $hostAliasClean = $HostAlias.Trim()
    $hostNameClean  = $HostName.Trim()
    $keyNameClean   = $IdentityFileName.Trim()
    $userClean      = $User.Trim()

    # Write-StatusMessage -Title "SSH Config" -Message "Building host block"
    # Write-Var -Name "HostAlias"     -Value $hostAliasClean
    # Write-Var -Name "HostName"      -Value $hostNameClean
    # Write-Var -Name "User"          -Value $userClean
    # Write-Var -Name "IdentityFile"  -Value "~/.ssh/$keyNameClean"

@"
Host $hostAliasClean
    HostName $hostNameClean
    User $userClean
    IdentityFile ~/.ssh/$keyNameClean
    IdentitiesOnly yes
"@
}

# ------------------------------------------------------------------------------------------------
# New-SshFallbackConfigBlock:
# Builds a fallback SSH config block (Host *) as text.
# Returns the block as a string.
# ------------------------------------------------------------------------------------------------
function New-SshFallbackConfigBlock {
    [CmdletBinding()]
    param()

    # Write-StatusMessage -Title "SSH Config" -Message "Building fallback block"

@"
Host *
    IdentitiesOnly yes
"@
}

# ------------------------------------------------------------------------------------------------
# New-SshConfigBlocks:
# Builds SSH config blocks from a set of profiles and appends the fallback block.
# Each profile must provide: HostAlias, HostName, KeyFileName.
# Returns a string[] of blocks (empty array on failure).
# ------------------------------------------------------------------------------------------------
function New-SshConfigBlocks {
    [CmdletBinding()]
    param (
        # SshProfiles:
        # Collection of SSH profile objects (each must include HostAlias, HostName, KeyFileName).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $SshProfiles
    )

    # Guards
    $profiles = @($SshProfiles)
    if ($profiles.Count -eq 0) {
        Write-WarnMessage -Title "No profiles" -Message "No SSH config blocks created"
        return @()
    }

    try {
        $blocks = New-Object System.Collections.Generic.List[string]

        foreach ($p in $profiles) {
            if (-not ($p.PSObject.Properties.Name -contains 'HostAlias'))   { Write-WarnMessage -Title "Profile missing" -Message "HostAlias";   continue }
            if (-not ($p.PSObject.Properties.Name -contains 'HostName'))    { Write-WarnMessage -Title "Profile missing" -Message "HostName";    continue }
            if (-not ($p.PSObject.Properties.Name -contains 'KeyFileName')) { Write-WarnMessage -Title "Profile missing" -Message "KeyFileName"; continue }

            $hostAlias = [string]$p.HostAlias
            $hostName  = [string]$p.HostName
            $keyName   = [string]$p.KeyFileName

            if ([string]::IsNullOrWhiteSpace($hostAlias) -or [string]::IsNullOrWhiteSpace($hostName) -or [string]::IsNullOrWhiteSpace($keyName)) {
                Write-WarnMessage -Title "SSH Config" -Message "Profile invalid: missing required field(s)"
                continue
            }

            Write-StatusMessage -Title "SSH Config" -Message "Building config host block"
            Write-Var -Name "HostAlias" -Value $hostAlias -NoIcon

            $block = New-SshHostConfigBlock -HostAlias $hostAlias -HostName $hostName -IdentityFileName $keyName
            if (-not [string]::IsNullOrWhiteSpace($block)) {
                $blocks.Add($block) | Out-Null
            }
        }

        $blocks.Add((New-SshFallbackConfigBlock)) | Out-Null

        Write-OkMessage -Title "SSH Config" -Message "Config host blocks added. Count: $($blocks.Count)"
        return $blocks.ToArray()
    }
    catch {
        Write-FailMessage -Title "SSH Config" -Message "Unexpected error creating config"
        Write-Warn $_.Exception.Message -NoIcon
        return @()
    }
}

# ------------------------------------------------------------------------------------------------
# Set-SshConfigFile:
# Writes SSH config blocks to a config file as UTF-8 text separated by blank lines.
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function Set-SshConfigFile {
    [CmdletBinding()]
    param (
        # ConfigPath:
        # Full path to the SSH config file to write.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigPath,

        # ConfigBlocks:
        # Array of SSH config blocks (strings) to write.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ConfigBlocks
    )

    # Sanitize
    $configPathClean = $ConfigPath.Trim()

    # --------------------------------------------------------------------------------------------

    $blocks = @($ConfigBlocks) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    if ($blocks.Count -eq 0) {
        Write-FailMessage -Title "SSH Config" -Message "No config blocks found. Nothing to write"
        return $false
    }

    Write-StatusMessage -Title "SSH Config" -Message "Writing config"
    Write-Var -Name "ConfigPath" -Value $configPathClean _NoNewLine -NoIcon
    Write-Var -Name "Blocks" -Value $blocks.Count -NoIcon

    try {
        $content = $blocks -join "`n`n"
        $content | Set-Content -LiteralPath $configPathClean -Encoding utf8 -ErrorAction Stop

        Write-OkMessage -Title "SSH Config" -Message "Successfully created $configPathClean"
        return $true
    }
    catch {
        Write-FailMessage -Title "SSH Config" -Message "Failed to write $configPathClean"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }
}
