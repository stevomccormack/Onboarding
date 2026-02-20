# 44 - dotnet-dev-certs.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead ".NET Development Certificates"


# ------------------------------------------------------------------------------------------------
# Create Trusted Dev Certificate
# ------------------------------------------------------------------------------------------------
Write-Header "Create and Trust Dev Certificate"
Write-Status "Cleaning and creating new trusted certificate..."

Write-Command "dotnet dev-certs https --clean"
dotnet dev-certs https --clean

Write-Command "dotnet dev-certs https --trust"
dotnet dev-certs https --trust

Write-Command "dotnet dev-certs https --check --trust"
dotnet dev-certs https --check --trust


# ------------------------------------------------------------------------------------------------
# Certificate Manager
# ------------------------------------------------------------------------------------------------
Write-Header "Certificate Stores"

Write-Status "Personal Certificates (Cert:\CurrentUser\My)"
Write-Info "Search for 'localhost' certificate:" -NoIcon
Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -match 'localhost' } | Format-Table Subject, Thumbprint, NotAfter -AutoSize

Write-NewLine
Write-Status "Trusted Root CAs (Cert:\CurrentUser\Root) - localhost:"
Write-Info "Search for 'localhost' certificate:" -NoIcon
Get-ChildItem Cert:\CurrentUser\Root | Where-Object { $_.Subject -match 'localhost' } | Format-Table Subject, Thumbprint, NotAfter -AutoSize

Write-NewLine
Write-Ok "Opening Certificate Manager (certmgr.msc)..." -NoIcon
Start-Process certmgr.msc

# ------------------------------------------------------------------------------------------------
# Additional Commands
# ------------------------------------------------------------------------------------------------
# Export certificate:
#   dotnet dev-certs https --export-path ./dev-cert.pfx --password YourPassword
#
# List certificates:
#   dotnet dev-certs https --check
#
# Clean all certificates:
#   dotnet dev-certs https --clean
# ------------------------------------------------------------------------------------------------