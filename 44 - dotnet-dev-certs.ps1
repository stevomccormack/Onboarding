# 44 - dotnet-dev-certs.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead ".NET Development Certificates"

# ------------------------------------------------------------------------------------------------
# Configure HTTPS Certificates
# ------------------------------------------------------------------------------------------------
# Creates and trusts HTTPS development certificates for local ASP.NET Core apps.
# ------------------------------------------------------------------------------------------------

Write-Header "Cleaning existing certificates"
dotnet dev-certs https --clean

Write-Header "Creating and trusting new certificate"
dotnet dev-certs https --trust

Write-Header "Verifying certificate"
dotnet dev-certs https --check --trust

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