# .shared/variables/pip.ps1

# -------------------------------------------------------------------------------------------------
# Pip (Python Package Manager) Configuration & Packages
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Pip Package Commands
# -------------------------------------------------------------------------------------------------
# Install a package:
#   pip install <package>
# Upgrade a package:
#   pip install --upgrade <package>
# Uninstall a package:
#   pip uninstall <package>
# List installed packages:
#   pip list
# -------------------------------------------------------------------------------------------------

$pipInstallUrl = 'https://pip.pypa.io/en/stable/installation/'
$pipDocsUrl = 'https://pip.pypa.io/en/stable/'
$pipPackagesUrl = 'https://pypi.org/'

$Pip = [pscustomobject]@{
    Id                     = 'pip'
    Enabled                = $true                            # Enable pip (included with Python 3.4+)
    Name                   = 'Pip'
    CommandName            = 'pip'
    TestCommand            = 'pip --version'
    Description            = 'Python package manager (included with Python 3.4+)'
    WingetId               = $null                            # Bundled with Python — no separate install
    ChocoId                = $null                            # Bundled with Python — no separate install
    InstallUrl             = $pipInstallUrl               # Installation instructions (comes with Python 3.4+)
    DocsUrl                = $pipDocsUrl                  # Documentation
    PackagesUrl            = $pipPackagesUrl              # Package index (PyPI)
    
    # Pip Configuration Settings
    Yes                    = $true                        # Assume yes to all prompts
    Quiet                  = $false                       # Quiet output
    Verbose                = $false                       # Verbose output
    NoInput                = $true                        # Disable prompts
    DisablePipVersionCheck = $false                    # Disable pip version check
    
    Packages               = @(
        # AI/LLM Development
        @{ Id = 'openai'; Enabled = $true; Name = 'OpenAI SDK'; CommandName = 'python'; TestCommand = 'python -c "import openai; print(openai.__version__)"'; Url = 'https://pypi.org/project/openai/' }
        @{ Id = 'langchain'; Enabled = $true; Name = 'LangChain'; CommandName = 'python'; TestCommand = 'python -c "import langchain; print(langchain.__version__)"'; Url = 'https://pypi.org/project/langchain/' }
        @{ Id = 'anthropic'; Enabled = $false; Name = 'Anthropic SDK'; CommandName = 'python'; TestCommand = 'python -c "import anthropic; print(anthropic.__version__)"'; Url = 'https://pypi.org/project/anthropic/' }
        
        # Azure & Cloud
        @{ Id = 'azure-cli'; Enabled = $false; Name = 'Azure CLI (pip)'; CommandName = 'az'; TestCommand = 'az --version'; Url = 'https://pypi.org/project/azure-cli/' }
        @{ Id = 'azure-functions'; Enabled = $false; Name = 'Azure Functions SDK'; CommandName = 'python'; TestCommand = 'python -c "import azure.functions"'; Url = 'https://pypi.org/project/azure-functions/' }
        
        # Data Science & ML
        @{ Id = 'jupyter'; Enabled = $false; Name = 'Jupyter'; CommandName = 'jupyter'; TestCommand = 'jupyter --version'; Url = 'https://pypi.org/project/jupyter/' }
        @{ Id = 'pandas'; Enabled = $false; Name = 'Pandas'; CommandName = 'python'; TestCommand = 'python -c "import pandas; print(pandas.__version__)"'; Url = 'https://pypi.org/project/pandas/' }
        @{ Id = 'numpy'; Enabled = $false; Name = 'NumPy'; CommandName = 'python'; TestCommand = 'python -c "import numpy; print(numpy.__version__)"'; Url = 'https://pypi.org/project/numpy/' }
        
        # Web Development
        @{ Id = 'flask'; Enabled = $false; Name = 'Flask'; CommandName = 'flask'; TestCommand = 'flask --version'; Url = 'https://pypi.org/project/flask/' }
        @{ Id = 'fastapi'; Enabled = $false; Name = 'FastAPI'; CommandName = 'python'; TestCommand = 'python -c "import fastapi; print(fastapi.__version__)"'; Url = 'https://pypi.org/project/fastapi/' }
        
        # Testing & Quality
        @{ Id = 'pytest'; Enabled = $false; Name = 'pytest'; CommandName = 'pytest'; TestCommand = 'pytest --version'; Url = 'https://pypi.org/project/pytest/' }
        @{ Id = 'black'; Enabled = $false; Name = 'Black'; CommandName = 'black'; TestCommand = 'black --version'; Url = 'https://pypi.org/project/black/' }
    )
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Pip` Variable:"
    $Pip | Format-List
}
