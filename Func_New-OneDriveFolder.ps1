################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the
# Creative Commons Attribution-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-sa/4.0/
################################################################################

Function New-OneDriveFolder {
    <#
        .SYNOPSIS
        Create a new folder in the specified location.
        
        .EXAMPLE
        New-OneDriveFolder -Path 'path/to/folder'

        .EXAMPLE
        New-OneDriveFolder -Name 'NewFolder' -ParentId '1234ABC!123'

        .EXAMPLE
        'path/to/folder1', 'path/to/folder2' | odmkdir

        .NOTES
        The API will create all folders in the path, even if they don't exist.
        This command does not fail if the folder already exists.
    #>
    [CmdletBinding(DefaultParameterSetName='Folder Path')]
    [Alias('odnf','odmkdir')]
    [OutputType([PsObject])]
    Param
    (
        # API path of the new folder.
        [Parameter(Mandatory=$False,
                   Position=1,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Folder Path')]
        [Alias('ApiUrl', 'Resource')]
        [string]$Path,

        # Name of the folder
        [Parameter(Mandatory=$True,
                   Position=1,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Parent ID')]
        [string]$Name,

        # Id of the parent
        [Parameter(Mandatory=$True,
                   Position=2,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Parent ID')]
        [Alias('id')]
        [string]$ParentId,

        # By default, if folder exists is fails. Set to overwrite.
        [Parameter(Mandatory=$False)]
        [switch]$Force
    )

    Process {

        if ($ParentId) {
            $parent = joinPath $PSOD.drive.itemRoot $ParentId
            $parent = joinPath $parent 'children'
        } else {
            $parent = joinPath $PSOD.drive.pathRoot (Split-Path $Path)
            $parent = joinPath $parent 'children' ':/'
            $Name   = Split-Path $Path -Leaf
        }

        Write-Verbose "Folder name: $Name"
        Write-Verbose "Parent path: $parent"

        $body = [ordered]@{
            name   = $Name
            folder = @{}
        } | ConvertTo-Json

        Write-Verbose "Request body:`n$body"

        if ($Force) {
            $parent += '?@name.conflictBehavior=replace'
        } else {
            $parent += '?@name.conflictBehavior=fail'
        }

        $rsp = Invoke-OneDriveApiCall -Path $parent `
                                      -Method POST `
                                      -Body $body
        
        if ($rsp) {
            Write-Output $rsp | newOneDriveItem
        }
    }

}

Export-ModuleMember -Function 'New-OneDriveFolder' -Alias 'odnf', 'odmkdir'
