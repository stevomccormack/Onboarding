# 45 - dotnet-build.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead ".NET Projects: Restore & Build"

# ------------------------------------------------------------------------------------------------
# Find all projects tagged 'dotnet'
# ------------------------------------------------------------------------------------------------
Write-Header "Resolving .NET Projects"

$dotnetProjects = $Projects.PSObject.Properties.Value | Where-Object { $_.Tags -contains 'dotnet' }

if (-not $dotnetProjects) {
    Write-InfoMessage -Title "Projects" -Message "No projects tagged 'dotnet' found in `$Projects"
    exit 0
}

Write-Status "Found $(@($dotnetProjects).Count) project(s) tagged 'dotnet':"
foreach ($project in $dotnetProjects) {
    Write-Info "  - $($project.Name): $($project.LocalPath)" -NoIcon
}

# ------------------------------------------------------------------------------------------------
# Build All .NET Solutions
# Finds and builds all .sln files within each tagged project's LocalPath.
# ------------------------------------------------------------------------------------------------
Write-Header "Building Solutions"

$builtCount = 0
$failedCount = 0

foreach ($project in $dotnetProjects) {

    if ([string]::IsNullOrWhiteSpace($project.LocalPath)) {
        Write-FailMessage -Title $project.Name -Message "LocalPath is not set"
        $failedCount++
        continue
    }

    if (-not (Test-Path $project.LocalPath)) {
        Write-FailMessage -Title $project.Name -Message "LocalPath not found: $($project.LocalPath)"
        $failedCount++
        continue
    }

    $solutions = Get-ChildItem -Path $project.LocalPath -Include "*.sln", "*.slnx" -Recurse

    if ($solutions.Count -eq 0) {
        Write-InfoMessage -Title $project.Name -Message "No .sln or .slnx files found in $($project.LocalPath)"
        continue
    }

    foreach ($sln in $solutions) {
        Write-StatusHeader "Building: $($sln.Name)..."

        Write-Command "dotnet clean $($sln.FullName)"
        dotnet clean $sln.FullName

        Write-Command "dotnet restore $($sln.FullName)"
        dotnet restore $sln.FullName

        Write-Command "dotnet build $($sln.FullName) --configuration Release --no-restore --verbosity minimal"
        dotnet build $sln.FullName --configuration Release --no-restore --verbosity minimal

        if ($LASTEXITCODE -eq 0) {
            Write-OkMessage -Title $sln.Name -Message "Build succeeded"
            $builtCount++
        }
        else {
            Write-FailMessage -Title $sln.Name -Message "Build failed"
            $failedCount++
        }
    }
}