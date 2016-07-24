################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

################################### Helpers ####################################

Function joinPath($Path1, $Path2) {
    if (!$Path1) { $Path1 = "" }
    if (!$Path2) { $Path2 = "" }
    return $Path1.TrimEnd('/'), $Path2.TrimStart('/') -join '/'
}

################################################################################

Function newOneDriveItem {
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

################################################################################
