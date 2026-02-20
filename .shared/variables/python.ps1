# .shared/variables/python.ps1

# -------------------------------------------------------------------------------------------------
# Python Variables
# -------------------------------------------------------------------------------------------------

$pythonInstallUrl = 'https://www.python.org/downloads/'
$pythonDocsUrl = 'https://docs.python.org/3/'

$Python = [pscustomobject]@{
    Id          = 'python'
    Enabled     = $true                         # Enable Python installation
    Name        = 'Python'
    CommandName = 'python'
    TestCommand = 'python --version'
    Description = 'Python programming language (includes pip)'
    WingetId    = 'Python.Python.3.13'          # winget install --exact --id Python.Python.3.13 --source winget
    ChocoId     = 'python'                      # choco install python
    InstallUrl  = $pythonInstallUrl             # Installation page
    DocsUrl     = $pythonDocsUrl                # Documentation
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Python` Variable:"
    $Python | Format-List
}
