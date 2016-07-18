################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

Function Remove-OneDriveItem {
    <#
        .SYNOPSIS
        Deletes the specified item.
        
        .EXAMPLE
        Remove-OneDriveItem $token "Documents/doc-to-remove.pdf"

        .EXAMPLE
        "Documents/Office Lens/0000001.docx" | Remove-OneDriveItem $token

        .EXAMPLE
        Remove-OneDriveItem $token -ItemId "1234ABC!123"
    #>
    [CmdletBinding(DefaultParameterSetName='Item Path')]
    [Alias('odrm', 'oddel')]
    [OutputType([boolean])]
    Param
    (
        # The API authentication token.
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   Position=1)]
        [Alias('ApiToken', 'AccessToken')]
        [OneDriveToken]$Token,

        # API resource path.
        [Parameter(Mandatory=$False,
                   Position=2,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item Path')]
        [Alias('ApiUrl', 'Resource')]
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

        # The API url to access a specified item. Default is 'drive/items/'.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item ID')]
        [string]$ItemIdRoot = 'drive/items/'
    )

    Process {

        if ($ItemId) {
            $p = joinPath $ItemIdRoot $ItemId
        } else {
            $p = joinPath $DriveRootPath $Path
        }

        Write-Verbose "Sending request to '$p'"

        $rsp = Invoke-OneDriveApiCall -Token $Token -Path $p -Method DELETE

        if ($rsp -is [string]) {
            Write-Output $True
        } else {
            Write-Output $False
        }

    }

}

Export-ModuleMember -Function 'Remove-OneDriveItem' -Alias 'odrm', 'oddel'

<#
Import-Module ..\PSOD
Function joinPath($Path1, $Path2) {
    if (!$Path1) { $Path1 = "" }
    if (!$Path2) { $Path2 = "" }
    return $Path1.TrimEnd('/'), $Path2.TrimStart('/') -join '/'
}
if ((Get-Date) -ge $token.ExpiryDate) {
    $token = Get-Content .\onedrive.opt | Get-OneDriveAuthToken
}
#>
<#
Remove-OneDriveItem $token "temp/another1"
Remove-OneDriveItem $token "temp/another2"
"temp/temp.pdf" | Remove-OneDriveItem $token
"temp/temp.pdf" | Remove-OneDriveItem $token #fails
Remove-OneDriveItem $token -ItemId "85B75A4CE0397EE!1482"
Remove-OneDriveItem $token -id "85B75A4CE0397EE!1489"
#>
