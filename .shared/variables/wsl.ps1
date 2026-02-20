# .shared/variables/wsl.ps1

# -------------------------------------------------------------------------------------------------
# WSL Variables
# -------------------------------------------------------------------------------------------------

$wslConfigSourcePath = [System.IO.Path]::Combine($PWD, '.shared\files\.wslconfig')
$wslConfigTargetPath = [System.IO.Path]::Combine($HOME, '.wslconfig')

# -------------------------------------------------------------------------------------------------

$Wsl = [pscustomobject]@{
    Id               = 'wsl'
    Enabled          = $true                        # Enable WSL installation
    Name             = 'WSL (Windows Subsystem for Linux)'
    CommandName      = 'wsl'
    TestCommand      = 'wsl --version'
    Description      = 'Run Linux environment on Windows'
    WingetId         = $null                        # WSL is a Windows feature, use: wsl --install
    ChocoId          = $null                        # Not available via Chocolatey
    InstallUrl       = 'https://learn.microsoft.com/en-us/windows/wsl/install'
    DocsUrl          = 'https://learn.microsoft.com/en-us/windows/wsl/'
    ConfigSourcePath = $wslConfigSourcePath         # Path to the .wslconfig source file to install
    ConfigTargetPath = $wslConfigTargetPath         # Path to the .wslconfig target file
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Wsl` Variable:"
    $Wsl | Format-List
}
