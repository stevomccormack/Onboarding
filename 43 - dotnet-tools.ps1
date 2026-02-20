# 42 - dotnet-tools.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead ".NET Global Tools"
Write-Status "Installing .NET global tools..."

# ------------------------------------------------------------------------------------------------
# Install Tools
# ------------------------------------------------------------------------------------------------
# Installs each tool defined in $DotNet.Tools array.
# To add tools: Edit .shared/variables/dotnet.ps1 - uncomment or add to Tools array
# To remove tools: Use 'dotnet tool uninstall --global <tool-id>'
# To update tools: Use 'dotnet tool update --global <tool-id>'
# ------------------------------------------------------------------------------------------------

if ($DotNet.Tools.Count -eq 0) {
    Write-InfoMessage -Title ".NET Tools" -Message "No tools configured"
}
else {
    $existingTools = dotnet tool list --global 2>$null

    foreach ($tool in $DotNet.Tools) {

        # Check if tool already exists by name
        if ($existingTools -match [regex]::Escape($tool)) {
            Write-OkMessage -Title $tool -Message "Already installed"
            continue
        }

        dotnet tool install --global $tool
        
        if ($LASTEXITCODE -eq 0) {
            Write-OkMessage -Title $tool -Message "Installed"
        }
        else {
            Write-FailMessage -Title $tool -Message "Failed to install"
        }
    }
}

# ------------------------------------------------------------------------------------------------
# List Updated Tools
# ------------------------------------------------------------------------------------------------

Write-StatusHeader ".NET Global Tools:"
dotnet tool list --global
