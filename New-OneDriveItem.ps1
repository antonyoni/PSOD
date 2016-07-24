################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

Function New-OneDriveItem {
    <#
        .SYNOPSIS
        Creates a new PSOD.OneDriveItem object from an API response.
        
        .EXAMPLE
        New-OneDriveItem $response
        
        .EXAMPLE
        $response | New-OneDriveItem
    #>
    [CmdletBinding()]
    [OutputType([PsObject])]
    Param
    (
        # 
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   Position=1)]
        [PsObject]$ApiResponse
    )

    Process {

        if ($ApiResponse.value) {
            $ret = $ApiResponse.value
        } else {
            $ret = $ApiResponse
        }

        $ret | % {
            $_.PsObject.TypeNames.Insert(0, "PSOD.OneDriveItem")
            Write-Output $_
        }

    }

}

Export-ModuleMember -Function 'New-OneDriveItem'

<#
. .\setup-test.ps1
#>
<#
$items = Invoke-OneDriveApiCall -Path 'drive/root:/Documents:/children'`
                                -Token $token
New-OneDriveItem $items | Get-Member

$items = Invoke-OneDriveApiCall -Path 'drive/root:/Pictures:/children'`
                       -Token $token `
    | New-OneDriveItem
$items | Get-Member

#>
