# .shared/functions/dotnet-project.ps1

# ------------------------------------------------------------------------------------------------
# Get-DotNetProjectCsprojAsXml:
# Reads and parses a .NET project file (.csproj) as XML.
# Validates that the file exists before attempting to read it.
# Returns the parsed XML document on success, $null on failure.
# ------------------------------------------------------------------------------------------------
function Get-DotNetProjectCsprojAsXml {
    [CmdletBinding()]
    [OutputType([xml])]
    param(

        # CsprojPath:
        # Local path where the .net project file (.csproj) is located.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()][string]$CsprojPath
    )

    # Guard: csproj exists
    if (-not (Test-Path -LiteralPath $CsprojPath -PathType Leaf)) {
        Write-FailMessage -Title "Project does not exist" -Message $CsprojPath
        return $null
    }

    try {
        [xml]$xml = Get-Content -LiteralPath $CsprojPath -Raw
        return $xml
    }
    catch {
        Write-FailMessage -Title "Project file read error" -Message "Failed to read csproj: $CsprojPath"
        return $null
    }
}

# ------------------------------------------------------------------------------------------------
# Test-DotNetProjectHasPackageReference:
# Checks if a .NET project file (.csproj) contains a reference to a specific NuGet package.
# Parses the project XML to locate PackageReference nodes by Include or Update attribute.
# Returns $true if the package is found, $false otherwise.
# ------------------------------------------------------------------------------------------------
function Test-DotNetProjectHasPackageReference {
    [CmdletBinding()]
    [OutputType([bool])]
    param(

        # CsprojPath:
        # Local path where the .net project file (.csproj) is located.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()][string]$CsprojPath,

        # PackageId:
        # The NuGet package ID to check for in the project file.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()][string]$PackageId
    )

    $xml = Get-DotNetProjectCsprojAsXml -CsprojPath $CsprojPath
    if ($null -eq $xml) {
        return $false
    }

    $nodes = $xml.SelectNodes("//*[local-name()='PackageReference']")
    foreach ($n in $nodes) {
        $id = $n.Include
        if ([string]::IsNullOrWhiteSpace($id)) {
            $id = $n.Update
        }

        if ([string]::IsNullOrWhiteSpace($id)) {
            continue
        }

        if ($id.Equals($PackageId, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

# ------------------------------------------------------------------------------------------------
# Test-DotNetProjectHasProjectReference:
# Checks if a .NET project file (.csproj) contains a reference to a specific project.
# Parses the project XML to locate ProjectReference nodes by Include attribute.
# Compares by project name (case-insensitive) extracted from the path.
# Returns $true if the project reference is found, $false otherwise.
# ------------------------------------------------------------------------------------------------
function Test-DotNetProjectHasProjectReference {
    [CmdletBinding()]
    [OutputType([bool])]
    param(

        # CsprojPath:
        # Local path where the .net project file (.csproj) is located.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()][string]$CsprojPath,

        # ProjectName:
        # The project name (with or without .csproj extension) to check for in the project file.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()][string]$ProjectName
    )

    $xml = Get-DotNetProjectCsprojAsXml -CsprojPath $CsprojPath
    if ($null -eq $xml) {
        return $false
    }

    # Normalize project name (remove .csproj if present)
    $normalizedProjectName = $ProjectName -replace '\.csproj$', ''

    $nodes = $xml.SelectNodes("//*[local-name()='ProjectReference']")
    foreach ($n in $nodes) {
        $include = $n.Include
        
        if ([string]::IsNullOrWhiteSpace($include)) {
            continue
        }

        # Extract project name from path (e.g., "..\MyProject\MyProject.csproj" -> "MyProject")
        $referencedProjectName = [System.IO.Path]::GetFileNameWithoutExtension($include)
        
        if ($referencedProjectName.Equals($normalizedProjectName, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}