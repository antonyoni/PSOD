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
            $p = joinPath $p 'action.copy'
        } else {
            $p = joinPath $PSOD.drive.pathRoot $Path
            $p = $p.TrimEnd('/') + ':/action.copy'
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
