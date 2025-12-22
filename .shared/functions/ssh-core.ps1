# .shared/functions/ssh-core.ps1

# ------------------------------------------------------------------------------------------------
# Register-GitHubSshKey:
# Registers an SSH public key in GitHub.
# Uses GitHub CLI + PAT when available, otherwise falls back to browser flow (manual).
# Returns $true on success, $false on failure.
# ------------------------------------------------------------------------------------------------
function Register-GitHubSshKey {
    [CmdletBinding()]
    param (
        # PublicKeyPath:
        # Path to the SSH public key file (*.pub).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PublicKeyPath,

        # Title:
        # Friendly name/title to display in GitHub for the uploaded key.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        # PersonalAccessToken:
        # Optional GitHub PAT used to authenticate GitHub CLI non-interactively.
        [Parameter()]
        [AllowEmptyString()]
        [string]$PersonalAccessToken = ''
    )

    # Guards
    if (-not (Test-Path -LiteralPath $PublicKeyPath -PathType Leaf)) {
        Write-FailMessage -Title "Public key not found" -Message $PublicKeyPath
        return $false
    }

    $titleClean = $Title.Trim()

    # --------------------------------------------------------------------------------------------

    $hasPat = -not [string]::IsNullOrWhiteSpace($PersonalAccessToken)
    $hasGh  = Test-Command -Name 'gh'

    Write-StatusMessage -Title "GitHub SSH" -Message "Registering public key: $titleClean"
    Write-Var -Name "Title"         -Value $titleClean -NoNewLine -NoIcon
    Write-Var -Name "PublicKeyPath" -Value $PublicKeyPath -NoNewLine -NoIcon
    Write-Var -Name "HasPAT"        -Value $hasPat -NoNewLine -NoIcon
    Write-Var -Name "HasGhCli"      -Value $hasGh -NoIcon

    if ($hasPat -and $hasGh) {
        try {
            Write-StatusMessage -Title "GitHub SSH" -Message "Authenticating with GitHub using PAT"
            Write-Host "gh auth login --hostname github.com --with-token" -ForegroundColor Cyan

            $authOutput = $PersonalAccessToken | & gh auth login --hostname github.com --with-token 2>&1
            $authExit   = $LASTEXITCODE

            if ($authExit -ne 0) {
                Write-FailMessage -Title "GitHub SSH" -Message "Authentication Failed. Exit: $authExit"
                if ($authOutput) { Write-Warn $authOutput }
                return $false
            }

            Write-StatusMessage -Title "GitHub SSH" -Message "Adding public key via GitHub CLI"
            Write-Warn "Ensure PAT permissions allow SSH key read/write." -NoIcon
            Write-Host "gh ssh-key add `"$PublicKeyPath`" --title `"$titleClean`" --type authentication" -ForegroundColor Cyan

            $addOutput = & gh ssh-key add $PublicKeyPath --title $titleClean --type authentication 2>&1
            $addExit   = $LASTEXITCODE

            if ($addExit -eq 0) {
                Write-OkMessage -Title "GitHub SSH" -Message "SSH key registered: $titleClean"
                return $true
            }

            Write-FailMessage -Title "GitHub SSH" -Message "Failed to add SSH key. Exit: $addExit"
            if ($addOutput) { Write-Warn $addOutput }
            return $false
        }
        catch {
            Write-FailMessage -Title "GitHub SSH" -Message "Failed to register SSH key: $titleClean"
            Write-Warn $_.Exception.Message -NoIcon
            return $false
        }
    }

    #--------------------------------------------------------------------------------------------
    # Fallback to manual browser flow

    Write-WarnMessage -Text "GitHub SSH" -Message "Fallback to manual browser flow"
    Write-Host "GitHub SSH settings: https://github.com/settings/ssh/new" -ForegroundColor Cyan

    Copy-FileToClipboard -Path $PublicKeyPath | Out-Null

    try {
        Start-Process 'https://github.com/settings/ssh/new'
        return $true
    }
    catch {
        Write-FailMessage -Title "GitHub SSH" -Message "Failed to open browser for SSH key registration"
        Write-Warn $_.Exception.Message -NoIcon
        Write-Warn "Open your browser and navigate to: https://github.com/settings/ssh/new" -NoIcon
        Write-Warn "Open your browser and navigate to: https://github.com/settings/ssh/new" -NoIcon
        Write-Warn "Your SSH public key has been copied to the clipboard." -NoIcon
        Write-Warn "Simply paste it into the form and save." -NoIcon
        return $false
    }
}

# ------------------------------------------------------------------------------------------------
# Register-AzureDevOpsSshKey:
# Performs manual Azure DevOps SSH key registration using the supported browser flow.
# Copies the public key to the clipboard, displays clear step-by-step instructions,
# pauses to allow the user to read them, opens the Azure DevOps SSH keys page,
# and waits until the user confirms completion (or browser closure when possible).
# ------------------------------------------------------------------------------------------------
function Register-AzureDevOpsSshKey {
    [CmdletBinding()]
    param (
        # PublicKeyPath:
        # Path to the SSH public key file (*.pub) that will be uploaded to Azure DevOps.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PublicKeyPath,

        # OrgName:
        # Azure DevOps organization name (URL slug, e.g. 'myorg').
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OrgName,

        # FriendlyName:
        # Friendly display name for the SSH key inside Azure DevOps.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FriendlyName,

        # PauseInSeconds:
        # Number of seconds to pause after printing instructions and before opening the browser.
        # Allows the user time to read the steps (similar to a git rebase pause).
        [Parameter()]
        [ValidateRange(0,60)]
        [int]$PauseInSeconds = 3,

        # WaitForBrowserClose:
        # When specified, attempts to wait for the launched browser process to exit.
        # Falls back to an interactive prompt if process tracking is not reliable.
        [Parameter()]
        [switch]$WaitForBrowserClose
    )

    # ------------------------------------------------------------------------------------------------
    # Guards
    $publicKeyPathClean = $PublicKeyPath.Trim()

    if (-not (Test-Path -LiteralPath $publicKeyPathClean -PathType Leaf)) {
        Write-FailMessage -Title "Azure DevOps SSH" -Message "Public key not found: $publicKeyPathClean"
        return $false
    }

    if ([IO.Path]::GetExtension($publicKeyPathClean).ToLowerInvariant() -ne '.pub') {
        Write-WarnMessage -Title "Azure DevOps SSH" -Message "Public key not found. Expected a .pub file: $publicKeyPathClean"
    }

    $orgClean  = $OrgName.Trim()
    $nameClean = $FriendlyName.Trim()

    if (-not (Get-Command -Name 'Start-Process' -ErrorAction SilentlyContinue)) {
        throw "Azure DevOps SSH: Start-Process command not available"
    }

    if (-not (Get-Command -Name 'Copy-FileToClipboard' -ErrorAction SilentlyContinue)) {
        throw "Azure DevOps SSH: Copy-FileToClipboard function not available"
    }

    $publicKeyData = ''
    try {
        $publicKeyData = (Get-Content -LiteralPath $publicKeyPathClean -Raw -ErrorAction Stop).Trim()
    }
    catch {
        Write-FailMessage -Title "Azure DevOps SSH" -Message "Read public key failed: $publicKeyPathClean"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }

    if ([string]::IsNullOrWhiteSpace($publicKeyData)) {
        Write-FailMessage -Title "Azure DevOps SSH" -Message "Public key empty: $publicKeyPathClean"
        return $false
    }

    $keyPrefixOk = $publicKeyData -match '^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp(256|384|521)|sk-ssh-ed25519@openssh\.com|sk-ecdsa-sha2-nistp256@openssh\.com)\s+'
    if (-not $keyPrefixOk) {
        Write-WarnMessage -Title "Azure DevOps SSH" -Message "Key does not look like a standard OpenSSH public key (continuing)."
        Write-Warn $publicKeyData -NoIcon
    }

    # ------------------------------------------------------------------------------------------------

    $keysUrl = "https://dev.azure.com/$orgClean/_usersSettings/keys"

    Write-Header "Azure DevOps SSH Key Registration using Browser Flow"
    Write-StatusMessage "Please follow the instructions below to add the SSH key to Azure DevOps." 

    Write-Host ""
    Write-Host "INSTRUCTIONS:" -ForegroundColor Cyan
    Write-Host "1) The public key has been copied to your clipboard." -ForegroundColor Cyan
    Write-Host "2) A browser will open to the Azure DevOps SSH keys page." -ForegroundColor Cyan
    Write-Host "3) Click 'New Key' (or 'Add')." -ForegroundColor Cyan
    Write-Host "4) Paste the key and set the name to '$nameClean'." -ForegroundColor Cyan
    Write-Host "5) Save the key." -ForegroundColor Cyan
    Write-Host "6) CLOSE THE BROWSER ONCE COMPLETED to continue." -ForegroundColor Yellow
    Write-Host ""

    Copy-FileToClipboard -Path $publicKeyPathClean | Out-Null

    if ($PauseInSeconds -gt 0) {
        Write-StatusMessage -Title "Azure DevOps SSH" -Message "Opening browser in $PauseInSeconds seconds"
        Start-Sleep -Seconds $PauseInSeconds
    }

    $proc = $null
    try {
        $proc = Start-Process -FilePath $keysUrl -PassThru -ErrorAction Stop
    }
    catch {
        Write-FailMessage -Title "Azure DevOps SSH" -Message "Failed to open browser: $keysUrl"
        Write-Warn $_.Exception.Message -NoIcon
        return $false
    }

    $canWait = $WaitForBrowserClose.IsPresent -and $proc -and $proc.Id -gt 0

    if ($canWait) {
        Write-StatusMessage -Title "Azure DevOps SSH" -Message "Closing browser to continue..."
        try { Wait-Process -Id $proc.Id -ErrorAction Stop }
        catch { $canWait = $false }
    }

    if (-not $canWait) {
        while ($true) {
            $choice = Write-Choice `
                -Prompt "Have you finished adding the SSH key in the browser?" `
                -YesLabel "Continue" `
                -NoLabel "Retry Open" `
                -SkipLabel "Skip"

            if ($choice -eq "Continue") { break }

            if ($choice -eq "Retry Open") {
                Write-StatusMessage -Title "Azure DevOps SSH" -Message "Re-opening SSH keys page"
                try { Start-Process -FilePath $keysUrl | Out-Null } catch { }
                continue
            }

            if ($choice -eq "Skip") {
                Write-WarnMessage -Title "Azure DevOps SSH" -Message "Skipped by user"
                return $false
            }
        }
    }

    Write-OkMessage -Title "Azure DevOps SSH" -Message "SSH key registered: $nameClean"
    return $true
}