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
        Get-OneDriveItem $token # return the root

        .EXAMPLE
        "Documents" | Get-OneDriveItem $token

        .EXAMPLE
        Get-OneDriveItem $token -ItemId "1234ABC!123"
    #>
    [CmdletBinding(DefaultParameterSetName='Item Path')]
    [Alias('odgi')]
    [OutputType([PsObject])]
    Param
    (
        # The API authentication token.
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   Position=1)]
        [Alias('ApiToken', 'AccessToken')]
        [PsObject]$Token,

        # API resource path.
        [Parameter(Mandatory=$False,
                   Position=2,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item Path')]
        [Alias('ApiUrl', 'Resource')]
        [string]$Path,

        # API item ID.
        [Parameter(Mandatory=$True,
                   Position=2,
                   ValueFromPipeline=$True,
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

        # API only returns directories if there's a trailing '/'. This does not
        # seem to matter for files.
        $p = joinPath $p '/'

        Write-Verbose "Sending request to '$p'"

        $rsp = Invoke-OneDriveApiCall -Token $Token -Path $p

        Write-Output $rsp | newOneDriveItem
    }

}

Export-ModuleMember -Function 'Get-OneDriveItem' -Alias 'odgi'

#. .\setup-test.ps1
<#
Get-OneDriveItem $token -Verbose | select name, id, size, webUrl | Format-Table
"Documents/" | Get-OneDriveItem $token -Verbose
#>
<#
$token | Get-OneDriveItem -ItemId '85B75A4CE0397EE!110' -Verbose
Get-OneDriveItem $token -ItemId '85B75A4CE0397EE!1436' -Verbose
#>
