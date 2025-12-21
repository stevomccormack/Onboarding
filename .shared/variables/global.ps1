# -------------------------------------------------------------------------------------------------
# Global Variables
# NOTE: This file should be loaded first!!
# -------------------------------------------------------------------------------------------------

$rootPath = 'D:\Steve McCormack\GitHub\@stevomccormack\Onboarding'

$Global = [pscustomobject]@{
    RootPath    = $rootPath
    DotEnvPath  = ([System.IO.Path]::Combine($rootPath, '.env'))
    DotEnvScope = 'User'
    DotEnvForce = $false # Force reload even if already loaded
    Log = [pscustomobject]@{
        Enabled  = $false
    }
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled){

    Write-Header "Global Variables (`$Global`):"
    Write-ObjectPathTree -Object $Global -RootPath '$Global'
}