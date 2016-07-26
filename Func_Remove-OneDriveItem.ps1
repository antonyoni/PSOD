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
        Remove-OneDriveItem "Documents/doc-to-remove.pdf"

        .EXAMPLE
        "Documents/Office Lens/0000001.docx" | Remove-OneDriveItem

        .EXAMPLE
        Remove-OneDriveItem -ItemId "1234ABC!123"
    #>
    [CmdletBinding(DefaultParameterSetName='Item Path')]
    [Alias('odrm', 'oddel')]
    [OutputType([boolean])]
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

        $rsp = Invoke-OneDriveApiCall -Path $p -Method DELETE

        if ($rsp -is [string]) {
            Write-Output $True
        } else {
            Write-Output $False
        }

    }

}

Export-ModuleMember -Function 'Remove-OneDriveItem' -Alias 'odrm', 'oddel'

#. .\setup-test.ps1
<#
Remove-OneDriveItem "temp/another1"
Remove-OneDriveItem "temp/another2"
"temp/temp.pdf" | Remove-OneDriveItem
"temp/temp.pdf" | Remove-OneDriveItem #fails
Remove-OneDriveItem -ItemId "85B75A4CE0397EE!1482"
Remove-OneDriveItem -id "85B75A4CE0397EE!1489"
#>
