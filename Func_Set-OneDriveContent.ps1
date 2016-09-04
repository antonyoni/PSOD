################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the
# Creative Commons Attribution-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-sa/4.0/
################################################################################

Function Set-OneDriveContent {
    <#
        .SYNOPSIS
        Uploads a new file, or update the contents of an existing OneDrive file.
        
        .EXAMPLE
        Set-OneDriveContent -Path "Documents" -Source 'C:\Temp\test.pdf' -Force

        .EXAMPLE
        Set-OneDriveContent -Path "Documents/aNewDirectory/" -Source 'C:\Temp\test.pdf'

        .EXAMPLE
        Set-OneDriveContent -Path "Documents/another-name.pdf" -Source 'C:\Temp\test.pdf'

        .EXAMPLE
        Set-OneDriveContent -ItemId "85B75A4CE0397EE!1450" -Source 'C:\Temp\test.pdf'
    #>
    [CmdletBinding(DefaultParameterSetName='Item Path')]
    [Alias('odsc')]
    [OutputType([PsObject])]
    Param
    (
        # API resource destination path.
        [Parameter(Mandatory=$True,
                   Position=1,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item Path')]
        [Alias('ApiUrl', 'Resource')]
        [string]$Path,

        # API destination item ID.
        [Parameter(Mandatory=$True,
                   Position=1,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Item ID')]
        [Alias('id')]
        [string]$ItemId,

        # The local path of the source file or directory.
        [Parameter(Mandatory=$True,
                   Position=2)]
        [string]$Source,

        # By default, remote items are not overwritten. Set this to overwrite.
        [Parameter(Mandatory=$False)]
        [switch]$Force
    )

    Process {

        $upload = Get-Item -Path $Source

        if (!$upload) {
            return
        }

        Write-Verbose "Source path: $($upload.FullName)"

        if ($ItemId) {
            $remote = Get-OneDriveItem -ItemId $ItemId
            if (!$remote) {
                return
            }
        } else {
            $remote = Get-OneDriveItem -Path $Path -ErrorAction SilentlyContinue
        }

        if (!$remote -and !$Path.EndsWith('/')) {
            # Assume path leaf is the file name even if no extension
            $uploadPath = joinPath $PSOD.drive.pathRoot $Path
            $uploadPath = joinPath $uploadPath 'content' ':/'
        } elseif ($remote.Type -eq 'folder' -or $Path.EndsWith('/')) {
            if ($ItemId) {
                $uploadPath = joinPath $PSOD.drive.itemRoot $ItemId
                $uploadPath = joinPath $uploadPath 'children'
                $uploadPath = joinPath $uploadPath $upload.Name
                $uploadPath = joinPath $uploadPath 'content'
            } else {
                $uploadPath = joinPath $PSOD.drive.pathRoot $Path
                $uploadPath = joinPath $uploadPath $upload.Name
                $uploadPath = joinPath $uploadPath 'content' ':/'
            }
        } else {
            if ($ItemId) {
                $uploadPath = joinPath $PSOD.drive.itemRoot $remote.ParentId
                $uploadPath = joinPath $uploadPath $remote.Name ':/' 
                $uploadPath = joinPath $uploadPath 'content' ':/'
            } else {
                $uploadPath = joinPath $PSOD.drive.pathRoot $Path
                $uploadPath = joinPath $uploadPath 'content' ':/'
            }
        }

        Write-Verbose "Destination path: $uploadPath"

        if ($Force) {
            $uploadPath += '?@name.conflictBehavior=replace'
        } else {
            $uploadPath += '?@name.conflictBehavior=fail'
        }
        
        $rsp = Invoke-OneDriveApiCall -Path $uploadPath `
                                      -Method PUT `
                                      -InFile $upload.FullName

        if ($rsp) {
            Write-Output $rsp | newOneDriveItem
        }
        
    }

}

Export-ModuleMember -Function 'Set-OneDriveContent' -Alias 'odsc'
