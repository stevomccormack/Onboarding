# environment-ad.ps1

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