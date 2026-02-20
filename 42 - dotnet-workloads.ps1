# 43 - dotnet-workloads.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead ".NET Workloads"

# ------------------------------------------------------------------------------------------------
# Update Manifests
# ------------------------------------------------------------------------------------------------

Write-Status "Updating workload manifests..."
dotnet workload update

# ------------------------------------------------------------------------------------------------
# Install Workloads
# ------------------------------------------------------------------------------------------------
# Installs each workload defined in $DotNet.Workloads array.
# To add workloads: Edit .shared/variables/dotnet.ps1 - uncomment or add to Workloads array
# To remove workloads: Use 'dotnet workload uninstall <workload-id>'
# ------------------------------------------------------------------------------------------------

if ($DotNet.Workloads.Count -eq 0) {
    Write-InfoMessage -Title "Workloads" -Message "No workloads configured"
}
else {
    $existingWorkloads = dotnet workload list 2>$null

    foreach ($workload in $DotNet.Workloads) {
        Write-Header "Installing: $workload"

        # Check if workload already exists by name
        if ($existingWorkloads -match [regex]::Escape($workload)) {
            Write-InfoMessage -Title $workload -Message "Already installed"
            continue
        }

        dotnet workload install $workload
        
        if ($LASTEXITCODE -eq 0) {
            Write-OkMessage -Title $workload -Message "Installed"
        }
        else {
            Write-FailMessage -Title $workload -Message "Failed to install"
        }
    }
}

# ------------------------------------------------------------------------------------------------
# List Installed Workloads
# ------------------------------------------------------------------------------------------------

Write-Header "Installed Workloads"
dotnet workload list
