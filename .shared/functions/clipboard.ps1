# clipboard.ps1

# ------------------------------------------------------------------------------------------------
# Copy-FileToClipboard:
# Copies the *contents of a file* into the system clipboard using Get-Content (-Raw) and Set-Clipboard.
# Returns $true on success, $false on any failure (missing file, missing cmdlet, access issues, etc.).
# ------------------------------------------------------------------------------------------------
function Copy-FileToClipboard {
    [CmdletBinding()]
    param(
        # Path:
        # Full or relative path to an existing *file* (leaf). Must not be null or empty.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    # Guard: this function copies a FILE only
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-FailMessage -Title "Clipboard" -Message "File not found: $Path"
        return $false
    }

    # Guard: Set-Clipboard may not exist in older or restricted environments
    if (-not (Get-Command -Name 'Set-Clipboard' -ErrorAction SilentlyContinue)) {
        Write-WarnMessage -Title "Clipboard" -Message "Set-Clipboard missing, skipping clipboard copy..."
        return $false
    }

    try {
        # Read entire file as a single string (ideal for clipboard operations)
        $content = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop

        # Explicitly stop on clipboard failures
        $content | Set-Clipboard -ErrorAction Stop

        Write-OkMessage -Title "Clipboard" -Message "Copied to clipboard: $Path"
        return $true
    }
    catch {
        Write-FailMessage -Title "Clipboard" -Message "Clipboard copy failed: $Path"
        return $false
    }
}
