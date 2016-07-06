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
        Gets item (folder/file) details from the OneDrive API.
        
        .EXAMPLE
        Get-OneDriveItem $token.Token

        .EXAMPLE
        "Documents" | Get-OneDriveItem $token.Token -Recurse
    #>
    [CmdletBinding(DefaultParameterSetName='Item Path')]
    [OutputType([PsObject])]
    Param
    (
        # The API authentication token.
        [Parameter(Mandatory=$True,
                   Position=1)]
        [string]$Token,

        # API resource path.
        [Parameter(Mandatory=$False,
                   Position=2,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item Path')]
        [string]$Path,

        # The API path for the user's default drive's root. Default is 'drive/root:/'. 
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item Path')]
        [string]$DriveRootPath = 'drive/root:/',

        # API item ID.
        [Parameter(Mandatory=$True,
                   Position=2,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item ID')]
        [Alias('id')]
        [string]$ItemId,

        # The API url to access a specified item. Default is 'drive/items/{0}'.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item ID')]
        [string]$ItemIdPath = 'drive/items/{0}',

        # Gets the items in the specified path, and all child items.
        [Parameter(Mandatory=$False)]
        [switch]$Recurse
    )

    Process {

        if ($ItemId) {
            $p = $ItemIdPath -f $ItemId
        } else {
            $p = JoinPath $DriveRootPath $Path
            $p = JoinPath $p ':/children'
        }

        Write-Verbose "Sending request to '$p'"

        $rsp = Invoke-OneDriveApiCall -Path $p -Token $Token

        if ($rsp.value) {
            $ret = $rsp.value
        } else {
            $ret = $rsp
        }

        Write-Output $ret

        if ($Recurse) {
            $ret | ? { $_.folder.childCount -gt 0 } | % {
                Get-OneDriveItem -Token $token -Path (JoinPath $Path $_.name) -Recurse
            }
        }

    }

}

Export-ModuleMember -Function 'Get-OneDriveItem'

<#
if ((Get-Date) -ge $token.ExpiryDT) {
    $token = Get-Content .\PSOD\onedrive.opt | Get-OneDriveAuthToken
}
#>
<#
Get-OneDriveItem $token.Token -Verbose | select name, id, size, webUrl | Format-Table
Get-OneDriveItem $token.Token -Recurse | select name, id, size, webUrl | Format-Table
"Documents" | Get-OneDriveItem $token.Token -Recurse
#>
<#
Get-OneDriveItem $token.Token -ItemId '85B75A4CE0397EE!110' -Verbose
Get-OneDriveItem $token.Token -ItemId '85B75A4CE0397EE!1436' -Verbose
Get-OneDriveItem $token.Token -ItemId '85B75A4CE0397EE!110' -Verbose -Recurse
Get-OneDriveItem $token.Token -ItemId '85B75A4CE0397EE!1436' -Verbose -Recurse
#>
