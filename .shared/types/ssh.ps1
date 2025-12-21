# .shared/types/ssh.ps1

# ------------------------------------------------------------------------------------------------
# SshProfile:
# Strongly-typed SSH profile used across key generation, config, agent, and registration workflows.
# ------------------------------------------------------------------------------------------------
class SshProfile {

    # Enabled:
    # Whether this profile should be processed.
    [bool]$Enabled

    # Provider:
    # Git provider (GitHub / AzureDevOps).
    [GitProvider]$Provider

    # Org:
    # Provider organisation/account name (e.g. Azure DevOps org).
    [string]$Org

    # Email:
    # Email used for key comment / profile identity.
    [string]$Email

    # AccessToken:
    # Optional PAT used for API-based key registration.
    [string]$AccessToken

    # HostAlias:
    # SSH config Host alias (friendly name).
    [string]$HostAlias

    # HostName:
    # SSH hostname (e.g. github.com / ssh.dev.azure.com).
    [string]$HostName

    # KeyType:
    # SSH key type (rsa / ed25519).
    [string]$KeyType

    # KeyPrefix:
    # Prefix used to differentiate keys (used in file naming).
    [string]$KeyPrefix

    # KeyFileName:
    # Private key filename (no directory path).
    [string]$KeyFileName

    # KeyFilePath:
    # Fully qualified path to private key.
    [string]$KeyFilePath

    # KeyPassphrase:
    # Optional passphrase used during key generation.
    [string]$KeyPassphrase

    # ForceNewKey:
    # Forces regeneration even if a key already exists.
    [bool]$ForceNewKey

    SshProfile() {}

    SshProfile(
        [bool]$Enabled,
        [GitProvider]$Provider,
        [string]$Org,
        [string]$Email,
        [string]$AccessToken,
        [string]$HostAlias,
        [string]$HostName,
        [string]$KeyType,
        [string]$KeyPrefix,
        [string]$KeyFileName,
        [string]$KeyFilePath,
        [string]$KeyPassphrase,
        [bool]$ForceNewKey
    ) {
        $this.Enabled       = $Enabled
        $this.Provider      = $Provider
        $this.Org           = $Org
        $this.Email         = $Email
        $this.AccessToken   = $AccessToken
        $this.HostAlias     = $HostAlias
        $this.HostName      = $HostName
        $this.KeyType       = $KeyType
        $this.KeyPrefix     = $KeyPrefix
        $this.KeyFileName   = $KeyFileName
        $this.KeyFilePath   = $KeyFilePath
        $this.KeyPassphrase = $KeyPassphrase
        $this.ForceNewKey   = $ForceNewKey
    }
}

# ------------------------------------------------------------------------------------------------
# New-SshProfile:
# Creates a validated SshProfile and resolves key filename/path under the provided SSH root.
# ------------------------------------------------------------------------------------------------
function New-SshProfile {
    [CmdletBinding()]
    param(
        # Enabled:
        # Whether the profile should be processed.
        [Parameter()]
        [bool]$Enabled = $true,

        # Provider:
        # Git provider (GitHub / AzureDevOps).
        [Parameter(Mandatory)]
        [GitProvider]$Provider,

        # SshRootPath:
        # Existing SSH directory root (e.g. ~/.ssh).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SshRootPath,

        # Org:
        # Provider organisation/account name.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Org,

        # Email:
        # Email used for key comment / profile identity.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Email,

        # AccessToken:
        # Optional PAT used for API-based key registration.
        [Parameter()]
        [AllowEmptyString()]
        [string]$AccessToken = '',

        # HostAlias:
        # SSH config Host alias (friendly name).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$HostAlias,

        # HostName:
        # SSH hostname (e.g. github.com / ssh.dev.azure.com).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$HostName,

        # KeyType:
        # SSH key type (rsa / ed25519).
        [Parameter(Mandatory)]
        [ValidateSet('rsa','ed25519')]
        [string]$KeyType,

        # KeyPrefix:
        # Prefix used to differentiate keys (used in file naming).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyPrefix,

        # KeyPassphrase:
        # Optional passphrase used during key generation.
        [Parameter()]
        [AllowEmptyString()]
        [string]$KeyPassphrase = '',

        # ForceNewKey:
        # Forces regeneration even if a key already exists.
        [Parameter()]
        [bool]$ForceNewKey = $false
    )

    # Guards
    $sshRootClean = $SshRootPath.Trim()
    $orgClean     = $Org.Trim()
    $emailClean   = $Email.Trim()
    $aliasClean   = $HostAlias.Trim()
    $hostClean    = $HostName.Trim()
    $keyTypeClean = $KeyType.Trim().ToLowerInvariant()
    $prefixClean  = $KeyPrefix.Trim()

    if (-not $sshRootClean) { throw "SshRootPath is empty" }
    if (-not $orgClean)     { throw "Org is empty" }
    if (-not $emailClean)   { throw "Email is empty" }
    if (-not $aliasClean)   { throw "HostAlias is empty" }
    if (-not $hostClean)    { throw "HostName is empty" }
    if (-not $prefixClean)  { throw "KeyPrefix is empty" }

    # Provider rules (fail loud)
    if ($Provider -eq [GitProvider]::AzureDevOps -and $keyTypeClean -ne 'rsa') {
        throw "Azure DevOps requires RSA public keys (ssh-rsa). KeyType '$KeyType' is not supported."
    }

    if (-not (Test-Path -LiteralPath $sshRootClean -PathType Container)) {
        throw "SshRootPath does not exist: $sshRootClean"
    }

    $keyFileName = "id_{0}_{1}" -f $keyTypeClean, $prefixClean
    $keyFilePath = [System.IO.Path]::Combine($sshRootClean, $keyFileName)

    return [SshProfile]::new(
        $Enabled,
        $Provider,
        $orgClean,
        $emailClean,
        $AccessToken,
        $aliasClean,
        $hostClean,
        $keyTypeClean,
        $prefixClean,
        $keyFileName,
        $keyFilePath,
        $KeyPassphrase,
        $ForceNewKey
    )
}
