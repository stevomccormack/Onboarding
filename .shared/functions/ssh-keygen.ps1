# .shared/functions/ssh-keygen.ps1

# ------------------------------------------------------------------------------------------------
# New-SshKey:
# Generates an SSH key pair using ssh-keygen.
# Ensures the parent directory exists, supports Force recreation, and can copy the public key to
# clipboard. Returns the public key path on success, otherwise $null.
# ------------------------------------------------------------------------------------------------
function New-SshKey {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        # KeyFilePath:
        # Full path to the private key file to create (public key will be "$KeyFilePath.pub").
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyFilePath,

        # KeyType:
        # Key type to generate: ed25519 or rsa.
        [Parameter()]
        [ValidateSet('ed25519', 'rsa')]
        [string]$KeyType = 'ed25519',

        # KeyBits:
        # RSA key size (only used when KeyType = 'rsa').
        [Parameter()]
        [ValidateRange(1024, 8192)]
        [int]$KeyBits = 4096,

        # KeyComment:
        # Comment embedded in the public key (often email/host info).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyComment,

        # KeyPassphrase:
        # Passphrase for the private key (empty string is allowed).
        [Parameter()]
        [AllowEmptyString()]
        [string]$KeyPassphrase = '',

        # Force:
        # Deletes existing key files (private/public) before generating a new pair.
        [Parameter()]
        [switch]$Force,

        # CopyPublicKeyToClipboard:
        # Copies the generated (or existing) public key to clipboard.
        [Parameter()]
        [switch]$CopyPublicKeyToClipboard
    )

    # Guards
    if (-not (Test-Command -Name 'ssh-keygen')) {
        throw "ssh-keygen command not found - install OpenSSH and ensure PATH is set"
    }

    $keyFilePathClean = $KeyFilePath.Trim()
    $commentClean = $KeyComment.Trim()

    # --------------------------------------------------------------------------------------------

    if ($KeyType -ne 'rsa' -and $PSBoundParameters.ContainsKey('KeyBits')) {
        Write-WarnMessage -Title "KeyBits ignored" -Message "KeyType is '$KeyType'"
    }

    $publicKeyPath = "$keyFilePathClean.pub"
    $parentDir = Split-Path -Path $keyFilePathClean -Parent

    Write-Header "SSH Key Generation"
    Write-Var -Name "KeyType" -Value $KeyType
    Write-Var -Name "KeyFilePath" -Value $keyFilePathClean
    Write-Var -Name "Force" -Value $Force.IsPresent
    Write-Var -Name "CopyPublicKeyToClipboard" -Value $CopyPublicKeyToClipboard.IsPresent

    if (-not [string]::IsNullOrWhiteSpace($parentDir)) {
        Write-StatusMessage -Title "SSH KeyGen" -Message "Ensuring key directory exists"
        if (-not (Test-EnsureDirectory -Path $parentDir)) { return $null }
    }

    # Guard: key already exists and no Force
    if ((Test-Path -LiteralPath $keyFilePathClean -PathType Leaf) -and -not $Force.IsPresent) {
        Write-OkMessage -Title "SSH key exists" -Message $keyFilePathClean
        Write-Var -Name "PublicKeyPath" -Value $publicKeyPath

        if ($CopyPublicKeyToClipboard.IsPresent) {
            Copy-FileToClipboard -Path $publicKeyPath | Out-Null
            Write-OkMessage -Title "Public key copied" -Message $publicKeyPath
        }

        return $publicKeyPath
    }

    # Guard: Force cleanup is predictable and should not be inside try/catch
    if ($Force.IsPresent) {
        Write-StatusMessage -Title "SSH KeyGen" -Message "Force enabled; removing existing key files"
        if (Test-Path -LiteralPath $keyFilePathClean) { Remove-Item -LiteralPath $keyFilePathClean -Force -ErrorAction SilentlyContinue | Out-Null }
        if (Test-Path -LiteralPath $publicKeyPath) { Remove-Item -LiteralPath $publicKeyPath    -Force -ErrorAction SilentlyContinue | Out-Null }
    }

    $argsList = @('-t', $KeyType, '-C', $commentClean, '-f', $keyFilePathClean, '-N', $KeyPassphrase)
    if ($KeyType -eq 'rsa') { $argsList += @('-b', $KeyBits) }

    $safeEcho = @('-t', $KeyType, '-C', $commentClean, '-f', $keyFilePathClean, '-N', '<hidden>')
    if ($KeyType -eq 'rsa') { $safeEcho += @('-b', $KeyBits) }

    Write-StatusMessage -Title "SSH KeyGen" -Message "Running ssh-keygen"
    Write-Host ("ssh-keygen " + ($safeEcho -join ' ')) -ForegroundColor Cyan

    try {
        $output = & ssh-keygen @argsList 2>&1
        $exit = $LASTEXITCODE

        if ($exit -ne 0) {
            Write-FailMessage -Title "ssh-keygen failed" -Message "Exit $exit"
            if ($output) { Write-Warn $output }
            return $null
        }

        if (-not (Test-Path -LiteralPath $keyFilePathClean -PathType Leaf)) {
            Write-FailMessage -Title "Private key missing" -Message $keyFilePathClean
            return $null
        }

        if (-not (Test-Path -LiteralPath $publicKeyPath -PathType Leaf)) {
            Write-FailMessage -Title "Public key missing" -Message $publicKeyPath
            return $null
        }

        Write-OkMessage -Title "SSH key generated" -Message $keyFilePathClean
        Write-Var -Name "PublicKeyPath" -Value $publicKeyPath

        if ($CopyPublicKeyToClipboard.IsPresent) {
            Copy-FileToClipboard -Path $publicKeyPath | Out-Null
            Write-OkMessage -Title "Public key copied" -Message $publicKeyPath
        }

        return $publicKeyPath
    }
    catch {
        Write-FailMessage -Title "Key generation failed" -Message $keyFilePathClean
        Write-Warn $_.Exception.Message
        return $null
    }
}
