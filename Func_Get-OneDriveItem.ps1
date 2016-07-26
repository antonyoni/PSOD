################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

Function Get-OneDriveItem {
    <#
        .SYNOPSIS
        Gets item (folder/file) details from the OneDrive API. By default gets the default drive's root. Can be used with either a relative path, or an item id.
        
        .EXAMPLE
        Get-OneDriveItem # return the root

        .EXAMPLE
        "Documents" | Get-OneDriveItem

        .EXAMPLE
        Get-OneDriveItem -ItemId "1234ABC!123"
    #>
    [CmdletBinding(DefaultParameterSetName='Item Path')]
    [Alias('odgi')]
    [OutputType([PsObject])]
    Param
    (
        # API resource path.
        [Parameter(Mandatory=$False,
                   Position=1,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item Path')]
        [Alias('ApiUrl', 'Resource')]
        [string]$Path,

        # API item ID.
        [Parameter(Mandatory=$True,
                   Position=1,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item ID')]
        [Alias('id')]
        [string]$ItemId
    )

    Process {

        if ($ItemId) {
            $p = joinPath $PSOD.drive.itemRoot $ItemId
        } else {
            $p = joinPath $PSOD.drive.pathRoot $Path
        }

        Write-Verbose "Sending request to '$p'"

        $rsp = Invoke-OneDriveApiCall -Path $p

        if ($rsp) {
            Write-Output $rsp | newOneDriveItem
        }
    }

}

Export-ModuleMember -Function 'Get-OneDriveItem' -Alias 'odgi'

#. .\setup-test.ps1
<#
Get-OneDriveItem -Verbose
"Documents/" | Get-OneDriveItem -Verbose
#>
<#
Get-OneDriveItem -ItemId '85B75A4CE0397EE!110' -Verbose
[pscustomobject]@{ id = '85B75A4CE0397EE!1436' } | Get-OneDriveItem -Verbose
#>
