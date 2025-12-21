# .shared/variables/me.ps1

# -------------------------------------------------------------------------------------------------
# Identity
# -------------------------------------------------------------------------------------------------

$meFirstName       = 'Steve'
$meLastName        = 'McCormack'
$meFullName        = "$meFirstName $meLastName"

# -------------------------------------------------------------------------------------------------

$Me = [pscustomobject]@{
    FirstName = $meFirstName    
    LastName = $meLastName
    FullName = $meFullName

    Steve = [pscustomobject]@{

        Iam = [pscustomobject]@{
            Slug        = 'iamstevo'
            LongSlug    = 'iamstevo'
            Domain      = 'iamstevo.co'
            Email       = 'hello@iamstevo.co'
        }

        Live = [pscustomobject]@{
            Slug        = 'stevomccormack'
            LongSlug    = 'stevomccormack'
            Domain      = 'live.com'
            Email       = 'stevomccormack@live.com'
        }
    }
    
    MWeb = [pscustomobject]@{
        Slug        = 'mweb'
        LongSlug    = 'mwebsolutions'
        Domain      = 'mweb.co'
        Email       = 'steve@mweb.co'
    }

    Seedsquare = [pscustomobject]@{
        Slug        = 'seedsquare'
        LongSlug    = 'seedsquare'
        Domain      = 'seedsquare.ai'
        Email       = 'steve@seedsquare.ai'
    }
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled){

    Write-Header "`$Me` Variable:"
    $Me | Format-List
}