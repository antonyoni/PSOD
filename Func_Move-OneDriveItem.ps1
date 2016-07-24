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

        # The path to the destination directory / file.
        [Parameter(Mandatory=$True,
                   Position=3)]
        [string]$Destination
    )

    Process {

        if ($ItemId) {
            $p = joinPath $PSOD.drive.itemRoot $ItemId
        } else {
            $p = joinPath $PSOD.drive.pathRoot $Path
        }

        Write-Verbose "Sending request to '$p'"

        $body = [ordered]@{
            parentReference = @{
                path = "/" + (joinPath $PSOD.drive.pathRoot $Destination)
            }
        } | ConvertTo-Json

        Write-Verbose "Request body:`n$body"

        $rsp = Invoke-OneDriveApiCall -Token $Token `
                                      -Path $p `
                                      -Method PATCH `
                                      -Body $body `
                                      -AdditionalRequestHeaders @{ Prefer = "respond-async" }

        Write-Output $rsp | newOneDriveItem
    }

}

Export-ModuleMember -Function 'Move-OneDriveItem' -Alias 'odmv', 'odmove'

#. .\setup-test.ps1
<#
Move-OneDriveItem $token "temp/test3.pdf" "temp/move" -Verbose
"temp/Document1.docx" | Move-OneDriveItem $token -destination "temp/move" -Verbose
Move-OneDriveItem $token "doesntexist" "temp/move" -Verbose
Move-OneDriveItem $token -ItemID "85B75A4CE0397EE!1492" -destination "temp" -Verbose
Move-OneDriveItem $token "temp/move" "temp/move-dir" -Verbose
#>
