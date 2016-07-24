################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

Function Copy-OneDriveItem {
    <#
        .SYNOPSIS
        Copies a one drive item from one path to another.
        
        .EXAMPLE
        "Documents/file.pdf" | Copy-OneDriveItem $token "destination/directory"

        .EXAMPLE
        Copy-OneDriveItem $token -ItemID "85B75A4CE0397EE!1492" -destination "destination/directory"

        .EXAMPLE
        Copy-OneDriveItem $token "Documents/DirToCopy" "destination/directory"
    #>
    [CmdletBinding(DefaultParameterSetName='Item Path')]
    [Alias('odcp', 'odcopy')]
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
            $p = joinPath $p 'action.copy'
        } else {
            $p = joinPath $DriveRootPath $Path
            $p = $p.TrimEnd('/') + ':/action.copy'
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
                                      -Method POST `
                                      -Body $body `
                                      -AdditionalRequestHeaders @{ Prefer = "respond-async" }

        Write-Output $rsp
    }

}

Export-ModuleMember -Function 'Copy-OneDriveItem' -Alias 'odcp', 'odcopy'

#. .\setup-test.ps1
<#
Copy-OneDriveItem $token "temp/test3.pdf" "temp/dest" -Verbose
"temp/Document1.docx" | Copy-OneDriveItem $token -destination "dontexist" -Verbose
Copy-OneDriveItem $token -ItemID "85B75A4CE0397EE!1492" -destination "temp/dest" -Verbose
Copy-OneDriveItem $token "temp/copy" "temp/dest" -Verbose
#>
