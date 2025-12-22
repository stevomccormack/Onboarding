# 45 - dotnet-build.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead ".NET Build Repositories"

# ------------------------------------------------------------------------------------------------
# Build All Repositories
# Finds and builds all .NET solutions in the repositories directory.
# ------------------------------------------------------------------------------------------------

$reposDir = ""

if ([string]::IsNullOrWhiteSpace($reposDir)) {
    Write-FailMessage -Title "" -Message "Environment variable not set"
    exit 1
}

if (-not (Test-Path $reposDir)) {
    Write-FailMessage -Title "Directory" -Message "Not found: $reposDir"
    exit 1
}

Write-Status "Repository directory: $reposDir"

$solutions = Get-ChildItem -Path $reposDir -Filter "*.sln" -Recurse

if ($solutions.Count -eq 0) {
    Write-InfoMessage -Title "Solutions" -Message "No .sln files found"
    exit 0
}

Write-Status "Found $($solutions.Count) solution(s)"

foreach ($sln in $solutions) {
    Write-Header "Building: $($sln.Name)"
    
    dotnet clean $sln.FullName
    dotnet restore $sln.FullName
    dotnet build $sln.FullName --configuration Release --no-restore --verbosity minimal
    
    if ($LASTEXITCODE -eq 0) {
        Write-OkMessage -Title $sln.Name -Message "Build succeeded"
    }
    else {
        Write-FailMessage -Title $sln.Name -Message "Build failed"
    }
}