# 42 - dotnet-tools.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead ".NET Global Tools"

# ------------------------------------------------------------------------------------------------
# List Current Tools
# ------------------------------------------------------------------------------------------------

Write-Header "Installed Global Tools"
dotnet tool list --global

# ------------------------------------------------------------------------------------------------
# Install Tools
# ------------------------------------------------------------------------------------------------
# Installs each tool defined in $DotNet.Tools array.
# To add tools: Edit .shared/variables/dotnet.ps1 - uncomment or add to Tools array
# To remove tools: Use 'dotnet tool uninstall --global <tool-id>'
# To update tools: Use 'dotnet tool update --global <tool-id>'
# ------------------------------------------------------------------------------------------------

if ($DotNet.Tools.Count -eq 0) {
    Write-InfoMessage -Title "Tools" -Message "No tools configured"
}
else {
    $existingTools = dotnet tool list --global 2>$null

    foreach ($tool in $DotNet.Tools) {
        Write-Header "Installing: $tool"

        # Check if tool already exists by name
        if ($existingTools -match [regex]::Escape($tool)) {
            Write-InfoMessage -Title $tool -Message "Already installed"
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

Write-Header "Updated Tools List"
dotnet tool list --global
