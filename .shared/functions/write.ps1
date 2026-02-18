# .shared/functions/write.ps1

# ------------------------------------------------------------------------------------------------
# ANSI Escape Sequences
# ------------------------------------------------------------------------------------------------
$Ansi = [pscustomobject]@{
    Esc       = [char]27
    Bold      = "$([char]27)[1m"
    Dim       = "$([char]27)[2m"
    Italic    = "$([char]27)[3m"
    Underline = "$([char]27)[4m"
    Reset     = "$([char]27)[0m"
}

# ------------------------------------------------------------------------------------------------
# Resolve-WriteIcon:
# Returns the requested icon + trailing space, or an empty string when -NoIcon is specified.
# ------------------------------------------------------------------------------------------------
function Resolve-WriteIcon {
    [CmdletBinding()]
    param (
        # Icon:
        # The icon (emoji/text) to prefix output with (e.g. '✅').
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Icon,

        # NoIcon:
        # When set, suppresses the icon output.
        [Parameter()]
        [switch]$NoIcon
    )

    # Guards
    $iconClean = $Icon.Trim()
    if ($NoIcon.IsPresent) { return '' }

    return "$iconClean  "
}

# ------------------------------------------------------------------------------------------------
# Write-MastHead:
# Writes a top-level masthead with separators for section starts.
# ------------------------------------------------------------------------------------------------
function Write-MastHead {
    [CmdletBinding()]
    param (
        # Text:
        # Heading text to display.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,

        # ForegroundColor:
        # Color for masthead text and separators.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'Cyan',

        # Separator:
        # Separator character repeated for the masthead border.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Separator = '=',

        # SeparatorLength:
        # How many separator characters to print.
        [Parameter()]
        [ValidateRange(1,1000)]
        [int]$SeparatorLength = 100
    )

    # Guards
    $textClean = $Text.Trim()
    $sepClean = $Separator.Trim()
    $line = ($sepClean * $SeparatorLength)

    Write-Host "`n`n$($Ansi.Bold)# $line$($Ansi.Reset)" -ForegroundColor $ForegroundColor
    Write-Host "$($Ansi.Bold)# $textClean$($Ansi.Reset)" -ForegroundColor $ForegroundColor
    Write-Host "$($Ansi.Bold)# $line`n$($Ansi.Reset)" -ForegroundColor $ForegroundColor
}

# ------------------------------------------------------------------------------------------------
# Write-Header:
# Writes a section header with separators.
# ------------------------------------------------------------------------------------------------
function Write-Header {
    [CmdletBinding()]
    param (
        # Text:
        # Header text to display.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,

        # ForegroundColor:
        # Color for header text and separators.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'Green',

        # Separator:
        # Separator character repeated for the header border.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Separator = '-',

        # SeparatorLength:
        # How many separator characters to print.
        [Parameter()]
        [ValidateRange(1,1000)]
        [int]$SeparatorLength = 80
    )

    # Guards
    $textClean = $Text.Trim()
    $sepClean = $Separator.Trim()
    $line = ($sepClean * $SeparatorLength)

    Write-Host "`n$($Ansi.Bold)$line$($Ansi.Reset)" -ForegroundColor $ForegroundColor
    Write-Host "$($Ansi.Bold)$textClean$($Ansi.Reset)" -ForegroundColor $ForegroundColor
    Write-Host "$($Ansi.Bold)$line$($Ansi.Reset)" -ForegroundColor $ForegroundColor
}

# ------------------------------------------------------------------------------------------------
# Write-StatusHeader:
# Writes a simple status line (no icon).
# ------------------------------------------------------------------------------------------------
function Write-StatusHeader {
    [CmdletBinding()]
    param (
        # Text:
        # Header text to display.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,

        # ForegroundColor:
        # Color for header text and separators.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'Yellow',

        # Separator:
        # Separator character repeated for the header border.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Separator = '-'
    )

    # separatorLength:
    $separatorLength = $Text.Length

    # Guards
    $textClean = $Text.Trim()
    $sepClean = $Separator.Trim()
    $line = ($sepClean * $separatorLength)

    Write-NewLine
    # Write-Host "$line" -ForegroundColor $ForegroundColor
    Write-Host $textClean -ForegroundColor $ForegroundColor
    Write-Host "$line" -ForegroundColor $ForegroundColor
}

# ------------------------------------------------------------------------------------------------
# Write-Status:
# Writes a simple status line (no icon).
# ------------------------------------------------------------------------------------------------
function Write-Status {
    [CmdletBinding()]
    param (
        # Text:
        # Text to write.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,

        # ForegroundColor:
        # Text color.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'Yellow',

        # NoNewLine:
        # When set, does not append a newline.
        [Parameter()]
        [switch]$NoNewLine
    )

    # Sanitize
    $textClean = $Text.Trim()

    Write-Host $textClean -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-StatusMessage:
# Writes a titled status message (no icon by default) and supports -NoIcon for consistency.
# ------------------------------------------------------------------------------------------------
function Write-StatusMessage {
    [CmdletBinding()]
    param (
        # Title:
        # Short title prefix for the message.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        # Message:
        # Message content (free-form).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        # ForegroundColor:
        # Color for message text.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'White',

        # NoNewLine:
        # When set, does not append a newline to the message.
        [Parameter()]
        [switch]$NoNewLine,

        # NoIcon:
        # When set, suppresses any icon output.
        [Parameter()]
        [switch]$NoIcon
    )

    # Sanitize
    $titleClean = $Title.Trim()
    $msgClean   = $Message.Trim()
    $prefix = "$($titleClean): "

    Write-Host $prefix -ForegroundColor Yellow -NoNewline
    Write-Host " $msgClean" -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-Info:
# Writes an informational message with an optional icon.
# ------------------------------------------------------------------------------------------------
function Write-Info {
    [CmdletBinding()]
    param (
        # Text:
        # Text to write.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,

        # ForegroundColor:
        # Text color.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'Cyan',

        # NoNewLine:
        # When set, does not append a newline.
        [Parameter()]
        [switch]$NoNewLine,

        # NoIcon:
        # When set, suppresses the icon.
        [Parameter()]
        [switch]$NoIcon
    )

    # Guards
    $textClean = $Text.Trim()

    $icon = Resolve-WriteIcon -Icon 'ℹ️' -NoIcon:$NoIcon
    Write-Host "$icon$textClean" -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-InfoMessage:
# Writes an informational titled message with an optional icon.
# ------------------------------------------------------------------------------------------------
function Write-InfoMessage {
    [CmdletBinding()]
    param (
        # Title:
        # Short title prefix for the message.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        # Message:
        # Message content (free-form).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        # ForegroundColor:
        # Color for message text.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'White',

        # NoNewLine:
        # When set, does not append a newline to the message.
        [Parameter()]
        [switch]$NoNewLine,

        # NoIcon:
        # When set, suppresses the icon.
        [Parameter()]
        [switch]$NoIcon
    )

    # Guards
    $titleClean = $Title.Trim()

    $icon = Resolve-WriteIcon -Icon 'ℹ️' -NoIcon:$NoIcon

    Write-Host "$icon$($titleClean): " -ForegroundColor Cyan -NoNewline
    Write-Host $Message -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-Ok:
# Writes a success message with an optional icon.
# ------------------------------------------------------------------------------------------------
function Write-Ok {
    [CmdletBinding()]
    param (
        # Text:
        # Text to write.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,

        # ForegroundColor:
        # Text color.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'Green',

        # NoNewLine:
        # When set, does not append a newline.
        [Parameter()]
        [switch]$NoNewLine,

        # NoIcon:
        # When set, suppresses the icon.
        [Parameter()]
        [switch]$NoIcon
    )

    # Guards
    $textClean = $Text.Trim()

    $icon = Resolve-WriteIcon -Icon '✅' -NoIcon:$NoIcon
    Write-Host "$icon$textClean" -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-OkMessage:
# Writes a success titled message with an optional icon.
# ------------------------------------------------------------------------------------------------
function Write-OkMessage {
    [CmdletBinding()]
    param (
        # Title:
        # Short title prefix for the message.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        # Message:
        # Message content (free-form).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        # ForegroundColor:
        # Color for message text.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'White',

        # NoNewLine:
        # When set, does not append a newline to the message.
        [Parameter()]
        [switch]$NoNewLine,

        # NoIcon:
        # When set, suppresses the icon.
        [Parameter()]
        [switch]$NoIcon
    )

    # Guards
    $titleClean = $Title.Trim()

    $icon = Resolve-WriteIcon -Icon '✅' -NoIcon:$NoIcon

    Write-Host "$icon$($titleClean): " -ForegroundColor Green -NoNewline
    Write-Host $Message -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-Warn:
# Writes a warning message with an optional icon.
# ------------------------------------------------------------------------------------------------
function Write-Warn {
    [CmdletBinding()]
    param (
        # Text:
        # Text to write.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,

        # ForegroundColor:
        # Text color.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'Yellow',

        # NoNewLine:
        # When set, does not append a newline.
        [Parameter()]
        [switch]$NoNewLine,

        # NoIcon:
        # When set, suppresses the icon.
        [Parameter()]
        [switch]$NoIcon
    )

    # Guards
    $textClean = $Text.Trim()

    $icon = Resolve-WriteIcon -Icon '⚠️' -NoIcon:$NoIcon
    Write-Host "$icon$textClean" -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-WarnMessage:
# Writes a warning titled message with an optional icon.
# ------------------------------------------------------------------------------------------------
function Write-WarnMessage {
    [CmdletBinding()]
    param (
        # Title:
        # Short title prefix for the message.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        # Message:
        # Message content (free-form).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        # ForegroundColor:
        # Color for message text.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'White',

        # NoNewLine:
        # When set, does not append a newline to the message.
        [Parameter()]
        [switch]$NoNewLine,

        # NoIcon:
        # When set, suppresses the icon.
        [Parameter()]
        [switch]$NoIcon
    )

    # Guards
    $titleClean = $Title.Trim()

    $icon = Resolve-WriteIcon -Icon '⚠️' -NoIcon:$NoIcon

    Write-Host "$icon$($titleClean): " -ForegroundColor Yellow -NoNewline
    Write-Host $Message -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-Fail:
# Writes a failure message with an optional icon.
# ------------------------------------------------------------------------------------------------
function Write-Fail {
    [CmdletBinding()]
    param (
        # Text:
        # Text to write.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,

        # ForegroundColor:
        # Text color.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'Red',

        # NoNewLine:
        # When set, does not append a newline.
        [Parameter()]
        [switch]$NoNewLine,

        # NoIcon:
        # When set, suppresses the icon.
        [Parameter()]
        [switch]$NoIcon
    )

    # Guards
    $textClean = $Text.Trim()

    $icon = Resolve-WriteIcon -Icon '❌' -NoIcon:$NoIcon
    Write-Host "$icon$textClean" -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-FailMessage:
# Writes a failure titled message with an optional icon.
# ------------------------------------------------------------------------------------------------
function Write-FailMessage {
    [CmdletBinding()]
    param (
        # Title:
        # Short title prefix for the message.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        # Message:
        # Message content (free-form).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        # ForegroundColor:
        # Color for message text.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'White',

        # NoNewLine:
        # When set, does not append a newline to the message.
        [Parameter()]
        [switch]$NoNewLine,

        # NoIcon:
        # When set, suppresses the icon.
        [Parameter()]
        [switch]$NoIcon
    )

    # Guards
    $titleClean = $Title.Trim()

    $icon = Resolve-WriteIcon -Icon '❌' -NoIcon:$NoIcon

    Write-Host "$icon$($titleClean): " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-Fatal:
# Writes a fatal message with an optional icon.
# ------------------------------------------------------------------------------------------------
function Write-Fatal {
    [CmdletBinding()]
    param (
        # Text:
        # Text to write.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,

        # ForegroundColor:
        # Text color.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'Red',

        # NoNewLine:
        # When set, does not append a newline.
        [Parameter()]
        [switch]$NoNewLine,

        # NoIcon:
        # When set, suppresses the icon.
        [Parameter()]
        [switch]$NoIcon
    )

    # Guards
    $textClean = $Text.Trim()

    $icon = Resolve-WriteIcon -Icon '⛔' -NoIcon:$NoIcon
    Write-Host "$icon$textClean" -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-FatalMessage:
# Writes a fatal titled message with an optional icon.
# ------------------------------------------------------------------------------------------------
function Write-FatalMessage {
    [CmdletBinding()]
    param (
        # Title:
        # Short title prefix for the message.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        # Message:
        # Message content (free-form).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        # ForegroundColor:
        # Color for message text.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'White',

        # NoNewLine:
        # When set, does not append a newline to the message.
        [Parameter()]
        [switch]$NoNewLine,

        # NoIcon:
        # When set, suppresses the icon.
        [Parameter()]
        [switch]$NoIcon
    )

    # Guards
    $titleClean = $Title.Trim()

    $icon = Resolve-WriteIcon -Icon '⛔' -NoIcon:$NoIcon

    Write-Host "$icon$($titleClean): " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-Var:
# Writes a named value pair with an optional icon.
# ------------------------------------------------------------------------------------------------
function Write-Var {
    [CmdletBinding()]
    param (
        # Name:
        # Variable name to display.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Value:
        # Value to display (can be $null).
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$Value,

        # NameColor:
        # Color for name text.
        [Parameter()]
        [ConsoleColor]$NameColor = 'Cyan',

        # ValueColor:
        # Color for value text.
        [Parameter()]
        [ConsoleColor]$ValueColor = 'White',

        # NoNewLine:
        # When set, does not append a newline to the value.
        [Parameter()]
        [switch]$NoNewLine,

        # NoIcon:
        # When set, suppresses the icon.
        [Parameter()]
        [switch]$NoIcon
    )

    # Guards
    $nameClean = $Name.Trim()

    $icon = Resolve-WriteIcon -Icon '💠' -NoIcon:$NoIcon

    Write-Host "$icon$($nameClean): " -ForegroundColor $NameColor -NoNewline
    Write-Host "$Value" -ForegroundColor $ValueColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-NewLine:
# Writes one or more blank lines to the console.
# ------------------------------------------------------------------------------------------------
function Write-NewLine {
    [CmdletBinding()]
    param (
        # Lines:
        # Number of blank lines to write.
        [Parameter()]
        [ValidateRange(1, 100)]
        [int]$Lines = 1
    )

    for ($i = 0; $i -lt $Lines; $i++) {
        Write-Host ""
    }
}

# ------------------------------------------------------------------------------------------------
# Write-Command:
# Writes a command string with optional args, formatted for readability.
# ------------------------------------------------------------------------------------------------
function Write-Command {
    [CmdletBinding()]
    param (
        # Command:
        # Command name (e.g. 'git', 'az').
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Command,

        # CommandArgs:
        # Optional command arguments.
        [Parameter()]
        [string[]]$CommandArgs = @(),

        # ForegroundColor:
        # Text color.
        [Parameter()]
        [ConsoleColor]$ForegroundColor = 'Cyan',

        # SingleLine:
        # Kept for compatibility; output is single-line by default.
        [Parameter()]
        [switch]$SingleLine,

        # NoNewLine:
        # When set, does not append a newline.
        [Parameter()]
        [switch]$NoNewLine
    )

    # Guards
    $commandClean = $Command.Trim()

    $formattedArgs = $CommandArgs | ForEach-Object {
        if ($_ -match '\s|["'']') { '"' + ($_ -replace '"','\"') + '"' } else { $_ }
    }

    $commandText = ($commandClean + ' ' + ($formattedArgs -join ' ')).Trim()

    Write-Host $commandText -ForegroundColor $ForegroundColor -NoNewline:$NoNewLine
}

# ------------------------------------------------------------------------------------------------
# Write-Choice:
# Renders a simple Y/N/S choice prompt and returns the chosen label.
# ------------------------------------------------------------------------------------------------
function Write-Choice {
    [CmdletBinding()]
    param(
        # Prompt:
        # Prompt text displayed to the user.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Prompt,

        # YesKey:
        # Single character key for Yes.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$YesKey = 'Y',

        # YesLabel:
        # Return label for Yes.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$YesLabel = 'Yes',

        # NoKey:
        # Single character key for No.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$NoKey = 'N',

        # NoLabel:
        # Return label for No.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$NoLabel = 'No',

        # SkipKey:
        # Single character key for Skip.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$SkipKey = 'S',

        # SkipLabel:
        # Return label for Skip.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$SkipLabel = 'Skip',

        # PromptForegroundColor:
        # Color for prompt text.
        [Parameter()]
        [ConsoleColor]$PromptForegroundColor = 'Green',

        # LabelForegroundColor:
        # Color for options legend.
        [Parameter()]
        [ConsoleColor]$LabelForegroundColor = 'Yellow'
    )

    # Guards
    $promptClean = $Prompt.Trim()

    $yesKey  = $YesKey.Trim().ToUpperInvariant()
    $noKey   = $NoKey.Trim().ToUpperInvariant()
    $skipKey = $SkipKey.Trim().ToUpperInvariant()

    if ($yesKey.Length -ne 1 -or $noKey.Length -ne 1 -or $skipKey.Length -ne 1) {
        throw "YesKey, NoKey, and SkipKey must each be a single character."
    }

    Write-Host ""
    Write-Host "$yesKey = $YesLabel"   -ForegroundColor $LabelForegroundColor
    Write-Host "$noKey  = $NoLabel"    -ForegroundColor $LabelForegroundColor
    Write-Host "$skipKey = $SkipLabel" -ForegroundColor $LabelForegroundColor
    Write-Host ""

    while ($true) {
        Write-Host -NoNewline "$promptClean ($yesKey/$noKey/$skipKey): " -ForegroundColor $PromptForegroundColor
        $choice = (Read-Host).Trim().ToUpperInvariant()

        switch ($choice) {
            { $_ -eq $yesKey }  { return $YesLabel }
            { $_ -eq $noKey }   { return $NoLabel }
            { $_ -eq $skipKey } { return $SkipLabel }
            default { Write-Warn "Invalid input. Enter $yesKey, $noKey, or $skipKey." }
        }
    }
}

# ------------------------------------------------------------------------------------------------
# Write-ObjectPathTree:
# Recursively prints an object's property paths and values for quick inspection.
# ------------------------------------------------------------------------------------------------
function Write-ObjectPathTree {
    [CmdletBinding()]
    param (
        # Object:
        # Object to inspect.
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$Object,

        # RootPath:
        # Starting root path label.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RootPath
    )

    # Guards
    $rootClean = $RootPath.Trim()

    $isLeaf =
        $null -eq $Object -or
        $Object -is [string] -or
        $Object -is [ValueType]

    if ($isLeaf) {
        Write-Host "$rootClean`: " -NoNewline -ForegroundColor Cyan
        Write-Host "$Object" -ForegroundColor White
        return
    }

    foreach ($prop in $Object.PSObject.Properties) {
        $currentPath = "$rootClean.$($prop.Name)"
        $value = $prop.Value

        if ($null -eq $value -or $value -is [string] -or $value -is [ValueType]) {
            Write-Host "$currentPath`: " -NoNewline -ForegroundColor Cyan
            Write-Host "$value" -ForegroundColor White
        }
        elseif ($value -is [pscustomobject] -or $value -is [hashtable]) {
            Write-Host "`n$currentPath" -ForegroundColor Yellow
            Write-ObjectPathTree -Object $value -RootPath $currentPath
        }
        elseif ($value -is [System.Collections.IEnumerable]) {
            $i = 0
            foreach ($item in $value) {
                Write-ObjectPathTree -Object $item -RootPath "$currentPath[$i]"
                $i++
            }
        }
        else {
            Write-Host "$currentPath`: " -NoNewline -ForegroundColor Cyan
            Write-Host "$value" -ForegroundColor White
        }
    }
}
