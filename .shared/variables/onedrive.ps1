# -------------------------------------------------------------------------------------------------
# OneDrive Variables
# -------------------------------------------------------------------------------------------------

$oneDriveRoot   = $env:OneDrive
$oneDriveDevDir  = [System.IO.Path]::Combine($oneDriveRoot, 'Development')

# -------------------------------------------------------------------------------------------------

$OneDrive = [pscustomobject]@{
    Name            = 'OneDrive'
    Root            = $oneDriveRoot
    DevDir          = $oneDriveDevDir
    SshDir          = [System.IO.Path]::Combine($oneDriveDevDir, ".ssh@$Env:COMPUTERNAME")
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled){

    Write-Header "$($OneDrive.Name) Variables:"
    Write-ObjectPathTree -Object $OneDrive -RootPath '$OneDrive'
}