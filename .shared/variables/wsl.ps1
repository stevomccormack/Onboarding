# .shared/variables/wsl.ps1

# -------------------------------------------------------------------------------------------------
# WSL Variables
# -------------------------------------------------------------------------------------------------

$wslConfigSourcePath = [System.IO.Path]::Combine($PWD, '.shared\files\.wslconfig')
$wslConfigTargetPath = [System.IO.Path]::Combine($HOME, '.wslconfig')

# -------------------------------------------------------------------------------------------------

$Wsl = [pscustomobject]@{
    ConfigSourcePath   = $wslConfigSourcePath     # Path to the .wslconfig source file to install
    ConfigTargetPath   = $wslConfigTargetPath     # Path to the .wslconfig target file
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Wsl` Variable:"
    $Wsl | Format-List
}
