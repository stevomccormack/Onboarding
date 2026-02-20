# .shared/variables/ruby.ps1

# -------------------------------------------------------------------------------------------------
# Ruby Variables
# -------------------------------------------------------------------------------------------------

$rubyInstallUrl = 'https://rubyinstaller.org/'
$rubyDocsUrl = 'https://www.ruby-lang.org/en/documentation/'

$Ruby = [pscustomobject]@{
    Id          = 'ruby'
    Enabled     = $false                        # Enable Ruby installation
    Name        = 'Ruby'
    CommandName = 'ruby'
    TestCommand = 'ruby --version'
    Description = 'Ruby programming language (includes gem)'
    WingetId    = 'RubyInstallerTeam.RubyWithDevKit'  # winget install --exact --id RubyInstallerTeam.RubyWithDevKit --source winget
    ChocoId     = 'ruby'                        # choco install ruby
    InstallUrl  = $rubyInstallUrl               # Installation page
    DocsUrl     = $rubyDocsUrl                  # Documentation
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Ruby` Variable:"
    $Ruby | Format-List
}
