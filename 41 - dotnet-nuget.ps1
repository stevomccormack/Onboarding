# 44 - dotnet-nuget.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead ".NET NuGet Sources"

# ------------------------------------------------------------------------------------------------
# List Current Sources
# ------------------------------------------------------------------------------------------------

Write-Header "Current NuGet Sources"
dotnet nuget list source

# ------------------------------------------------------------------------------------------------
# Add Custom Sources
# ------------------------------------------------------------------------------------------------
# To add a source:
#   dotnet nuget add source "https://your-feed.com/v3/index.json" --name "YourFeed"
# 
# To remove a source:
#   dotnet nuget remove source "YourFeed"
#
# To update a source:
#   dotnet nuget update source "YourFeed" --source "https://new-url.com/v3/index.json"
# ------------------------------------------------------------------------------------------------

# Example: Add custom source (uncomment and modify as needed)
# dotnet nuget add source "https://nuget.abp.io/YOUR-KEY/v3/index.json" --name "nuget.abp.io"

# ------------------------------------------------------------------------------------------------
# Configure NuGet Sources from $DotNet.NugetSources
# ------------------------------------------------------------------------------------------------

if ($DotNet.NugetSources.Count -eq 0) {
    Write-InfoMessage -Title "NuGet Sources" -Message "No sources configured"
}
else {
    $existingSources = dotnet nuget list source 2>$null

    foreach ($src in $DotNet.NugetSources) {
        Write-Header "Configuring: $($src.Name)"

        # Check if source already exists by name
        if ($existingSources -match [regex]::Escape($src.Name)) {
            Write-InfoMessage -Title $src.Name -Message "Already registered"
        }
        else {
            dotnet nuget add source $src.Source --name $src.Name

            if ($LASTEXITCODE -eq 0) {
                Write-OkMessage -Title $src.Name -Message "Added: $($src.Source)"
            }
            else {
                Write-FailMessage -Title $src.Name -Message "Failed to add source: $($src.Source)"
            }
        }
    }
}

# ------------------------------------------------------------------------------------------------
# List Updated Sources
# ------------------------------------------------------------------------------------------------

Write-Header "Updated NuGet Sources"
dotnet nuget list source
