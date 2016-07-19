################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

Function Move-OneDriveItem {
    <#
        .SYNOPSIS
        Move a OneDrive item from one parent to another.
        
        .EXAMPLE
        "Documents/file.pdf" | Move-OneDriveItem $token "destination/directory"

        .EXAMPLE
        Move-OneDriveItem $token -ItemID "85B75A4CE0397EE!1492" -destination "destination/directory"

        .EXAMPLE
        Move-OneDriveItem $token "Documents/DirToMove" "new/parent"
    #>
    [CmdletBinding(DefaultParameterSetName='Item Path')]
    [Alias('odmv', 'odmove')]
    [OutputType([PsObject])]
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
        [string]$ItemIdRoot = 'drive/items/',

        # The path to the destination directory / file.
        [Parameter(Mandatory=$True,
                   Position=3)]
        [string]$Destination
    )

    Process {

        if ($ItemId) {
            $p = joinPath $ItemIdRoot $ItemId
        } else {
            $p = joinPath $DriveRootPath $Path
        }

        Write-Verbose "Sending request to '$p'"

        $body = [ordered]@{
            parentReference = @{
                path = "/" + (joinPath $DriveRootPath $Destination)
            }
        } | ConvertTo-Json

        Write-Verbose "Request body:`n$body"

        $rsp = Invoke-OneDriveApiCall -Token $Token `
                                      -Path $p `
                                      -Method PATCH `
                                      -Body $body `
                                      -AdditionalRequestHeaders @{ Prefer = "respond-async" }

        Write-Output $rsp
    }

}

Export-ModuleMember -Function 'Move-OneDriveItem' -Alias 'odmv', 'odmove'

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
Move-OneDriveItem $token "temp/test3.pdf" "temp/move" -Verbose
"temp/Document1.docx" | Move-OneDriveItem $token -destination "temp/move" -Verbose
Move-OneDriveItem $token "doesntexist" "temp/move" -Verbose
Move-OneDriveItem $token -ItemID "85B75A4CE0397EE!1492" -destination "temp" -Verbose
Move-OneDriveItem $token "temp/move" "temp/move-dir" -Verbose
#>
