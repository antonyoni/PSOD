################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

$configFile = (Join-Path -Path $psScriptRoot -ChildPath 'PSOD.config.json')
$PSOD = ConvertFrom-Json (Get-Content $configFile -Raw)
# if no ApplicationId in the settings file, check onedrive.opt file.
if (!$PSOD.auth.applicationId) {
    $appIdFile = (Join-Path -Path $psScriptRoot -ChildPath 'onedrive.opt')
    if (Test-Path $appIdFile) {
        $PSOD.auth.applicationId = Get-Content $appIdFile -Raw
    }
}
Add-Member -InputObject $PSOD `
           -NotePropertyName token `
           -NotePropertyValue (New-Object PsObject)
Export-ModuleMember -Variable PSOD

################################################################################

. (Join-Path -Path $psScriptRoot -ChildPath 'PSOD.helpers.ps1')

################################################################################

Get-ChildItem -Path $psScriptRoot `
    | ? { $_ -match '^Func_.+$' } `
    | % {
        . (Join-Path -Path $psScriptRoot -ChildPath $_)
    }

################################################################################
