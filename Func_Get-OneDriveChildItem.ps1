################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

Function Get-OneDriveChildItem {
    <#
        .SYNOPSIS
        Gets the items in the specified path, or that are children of the specified Item ID from the OneDrive API. By default gets the items in the default drive's root. Can be used with either a relative path, or an item id.
        
        .EXAMPLE
        Get-OneDriveChildItem $token # Gets all the items in the default drive's root.

        .EXAMPLE
        "Documents" | Get-OneDriveChildItem $token

        .EXAMPLE
        Get-OneDriveChildItem $token -ItemId "1234ABC!123"
    #>
    [CmdletBinding(DefaultParameterSetName='Item Path')]
    [Alias('odgci','odls')]
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
        [string]$ItemId,

        # Gets the items in the specified path, and all child items.
        [Parameter(Mandatory=$False)]
        [switch]$Recurse
    )

    Process {

        if ($ItemId) {
            $rsp = Get-OneDriveItem -Token $Token `
                                    -ItemId ($ItemId + ':/:/children')

        } else {
            $rsp = Get-OneDriveItem -Token $Token `
                                    -Path ($Path + ':/children')
        }

        Write-Output $rsp | newOneDriveItem

        if ($Recurse) {
            $rsp | ? { [int]$_.folder.childCount -gt 0 } | % {
                Get-OneDriveChildItem -Token $Token `
                                      -ItemId $_.id `
                                      -Recurse
            }
        }

    }

}

Export-ModuleMember -Function 'Get-OneDriveChildItem' -Alias 'odgci', 'odls'

#. .\setup-test.ps1
<#
Get-OneDriveChildItem $token -Verbose | select name, id, size, webUrl | Format-Table
"Documents" | Get-OneDriveChildItem $token -Verbose
#$token | Get-OneDriveChildItem -Path "Documents/Office Lens" -Verbose
#>
<#
$token | Get-OneDriveChildItem -ItemId '85B75A4CE0397EE!110' -Verbose | select name, id, size, webUrl | Format-Table
Get-OneDriveChildItem $token -ItemId '85B75A4CE0397EE!1436' -Verbose
#>
#<#
#Get-OneDriveChildItem $token -Recurse | select name, id, size, @{name="parent";Exp={$_.parentReference.path}} | Format-Table -Auto
#Get-OneDriveChildItem $token "Documents" -Recurse
#$token | Get-OneDriveChildItem -Path "Documents/Office Lens" -Verbose -Recurse
#>
