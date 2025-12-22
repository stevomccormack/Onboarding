# 02 - ms-active-directory.ps1

$computerSystem = Get-WmiObject -Class Win32_ComputerSystem

# ------------------------------------------------------------------------------------------------
# Active Directory Group Policy Update
# ------------------------------------------------------------------------------------------------
# Forces an immediate refresh of both computer and user Group Policy settings.
# This applies any new policy changes from the domain controller without waiting for the
# automatic refresh interval (default: 90 minutes + random offset).
#
# Use cases:
# - After making Active Directory policy changes
# - When onboarding new users/computers
# - Troubleshooting policy application issues
# ------------------------------------------------------------------------------------------------

gpupdate /force

# ------------------------------------------------------------------------------------------------
# Display Computer Domain Information
# ------------------------------------------------------------------------------------------------
# Shows the computer's domain membership, workgroup, and domain role.
# Useful for verifying domain join status and computer configuration.
# ------------------------------------------------------------------------------------------------

Get-WmiObject -Class Win32_ComputerSystem | Select-Object Name, Domain, PartOfDomain, DomainRole

# ------------------------------------------------------------------------------------------------
# Display Current User Information
# ------------------------------------------------------------------------------------------------
# Shows the current user's Security Identifier (SID) and account name.
# Useful for verifying the logged-in user and their domain identity.
# ------------------------------------------------------------------------------------------------

whoami /user

# ------------------------------------------------------------------------------------------------
# Display Current User's Group Memberships
# ------------------------------------------------------------------------------------------------
# Lists all security groups the current user belongs to, including domain groups.
# Useful for verifying user permissions and troubleshooting access issues.
# ------------------------------------------------------------------------------------------------

whoami /groups

# ------------------------------------------------------------------------------------------------
# Display Fully Qualified Domain Name
# ------------------------------------------------------------------------------------------------
# Shows the user's account in FQDN format (domain\username).
# Useful for verifying domain membership and authentication context.
# ------------------------------------------------------------------------------------------------
if ($computerSystem.PartOfDomain){

    whoami /fqdn
}

# ------------------------------------------------------------------------------------------------
# Verify Domain Trust Relationship
# ------------------------------------------------------------------------------------------------
# Tests the secure channel between the local computer and the domain controller.
# Returns True if the trust is intact, False if broken.
# Useful for troubleshooting domain authentication issues.
# ------------------------------------------------------------------------------------------------
if ($computerSystem.PartOfDomain){

  Test-ComputerSecureChannel -Verbose
}

# ------------------------------------------------------------------------------------------------
# Display Group Policy Results Summary
# ------------------------------------------------------------------------------------------------
# Shows a summary of applied Group Policy settings for the current user and computer.
# Useful for verifying which policies are applied and troubleshooting policy issues.
# Only runs if computer is domain-joined and RSoP data exists.
# ------------------------------------------------------------------------------------------------

if ($computerSystem.PartOfDomain){

    gpresult /r
}

# ------------------------------------------------------------------------------------------------
# Generate Detailed Group Policy Report (HTML)
# ------------------------------------------------------------------------------------------------
# Creates a detailed HTML report of all applied Group Policy settings.
# Report is saved to the current directory as 'gpreport.html'.
# Useful for comprehensive policy analysis and documentation.
# Only runs if computer is domain-joined.
# ------------------------------------------------------------------------------------------------

if ($computerSystem.PartOfDomain) {

  gpresult /h ./log/gp-report.html
}