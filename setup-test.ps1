Import-Module ..\PSOD
. .\PSOD.helpers.ps1
if ((Get-Date) -ge $token.ExpiryDate) {
    $token = Get-Content .\onedrive.opt | Get-OneDriveAuthToken
}