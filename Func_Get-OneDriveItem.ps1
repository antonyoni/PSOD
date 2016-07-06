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
    [CmdletBinding()]
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
                   ValueFromPipelineByPropertyName=$True)]
        [string]$Path,

        # The API path for the user's default drive's root. 'drive/root:/'. 
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True)]
        [string]$DriveRootPath = 'drive/root:/',

        # Gets the items in the specified path, and all child items.
        [Parameter(Mandatory=$False)]
        [switch]$Recurse
    )

    Process {

        $p = JoinPath $DriveRootPath $Path
        $p = JoinPath $p ':/children'

        Write-Verbose "Sending request to '$p'"

        $rsp = Invoke-OneDriveApiCall -Path $p -Token $Token

        if ($rsp.value) {
            Write-Output $rsp.value
        } else {
            Write-Output $rsp
        }

        if ($Recurse) {
            $rsp.value | ? { $_.folder.childCount -gt 0 } | % {
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
Get-OneDriveItem $token.Token -Verbose | select name, id, size, webUrl | Format-Table
Get-OneDriveItem $token.Token -Recurse | select name, id, size, webUrl | Format-Table
"Documents" | Get-OneDriveItem $token.Token -Recurse
#>
