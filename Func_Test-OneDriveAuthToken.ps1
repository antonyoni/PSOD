################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

Function Test-OneDriveAuthToken {
    <#
        .SYNOPSIS
        Renews the OneDrive authentication token if it has expired. Return true if successful, false otherwise.
        
        .EXAMPLE
        Test-OneDriveAuthToken
    #>
    [CmdletBinding()]
    [OutputType([boolean])]
    Param
    ()

    End {
        if ((Get-Date) -ge $PSOD.token.ExpiryDate) {
            Write-Verbose "Requesting new token"
            $token = Get-OneDriveAuthToken
            if ($token) {
                $PSOD.token = $token 
            } else {
                return $False
            }
        }
        return $True
    }
    
}

Export-ModuleMember -Function 'Test-OneDriveAuthToken'

<#
. .\setup-test.ps1
$PSOD | Format-List
Test-OneDriveAuthToken -Verbose
$PSOD.token
Test-OneDriveAuthToken -Verbose
$PSOD.token
#>
