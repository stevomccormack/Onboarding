# .shared/variables/projects.ps1

# -------------------------------------------------------------------------------------------------
# Project Variables
# -------------------------------------------------------------------------------------------------

$Projects = [pscustomobject]@{
    Onboarding = New-GitHubProject `
        -Owner 'stevomccormack' `
        -Repository 'Onboarding' `
        -Name 'Onboarding' `
        -Description 'PowerShell Onboarding Scripts' `
        -LocalPath (Join-Path 'D:\Steve McCormack\GitHub\@stevomccormack' 'Onboarding') `
        -UserName 'Steve McCormack' `
        -UserEmail 'hello@iamstevo.co' `
        -MainBranch 'main' `
        -FastForward $false `
        -UseRebase $true
    PineGuard  = New-GitHubProject `
        -Owner 'stevomccormack' `
        -Repository 'PineGuard' `
        -Name 'PineGuard' `
        -Description '.NET validation library' `
        -LocalPath (Join-Path 'D:\Steve McCormack\GitHub\@stevomccormack' 'PineGuard') `
        -UserName 'Steve McCormack' `
        -UserEmail 'hello@iamstevo.co' `
        -MainBranch 'main' `
        -FastForward $false `
        -UseRebase $true `
        -Tags @('dotnet')
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Projects` Variable:"
    # Write-ObjectPathTree -Object $Projects -RootPath '$Projects'   

    $Projects.Onboarding | Format-List
    $Projects.PineGuard | Format-List
}