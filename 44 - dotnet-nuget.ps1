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
