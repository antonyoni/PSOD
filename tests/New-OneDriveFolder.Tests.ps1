################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the
# Creative Commons Attribution-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-sa/4.0/
################################################################################

. .\setup-test.ps1

Describe "New-OneDriveFolder" {

    $path    = "PSOD/odmkdir"
    $folder1 = "Folder1"
    $folder2 = "Folder2"
    $folder3 = "Folder3"
    $folder4 = "Folder4/Subfolder1"

    It "creates new folder by path" {
        $fld = New-OneDriveFolder -Path $path
        $fld.Path -replace "/$($PSOD.drive.pathRoot)", '' | Should Be $path
    }

    It "creates new folders recursively by path" {
        $fldPath = joinPath $path $folder4
        $fld = New-OneDriveFolder -Path $fldPath
        $fld.Path -replace "/$($PSOD.drive.pathRoot)", '' | Should Be $fldPath
    }

    It "doesn't fail even if the folder already exists" {
        $fld = New-OneDriveFolder -Path $path
        $fld.Path -replace "/$($PSOD.drive.pathRoot)", '' | Should Be $path
    }

    It "creates new folder by path from pipeline" {
        $fldPath = joinPath $path $folder1
        $fld = $fldPath | New-OneDriveFolder
    }

    $parentId = (Get-OneDriveItem $path).id

    It "creates new folder by name and parent id" {
        $fld = New-OneDriveFolder -Name $folder2 -ParentId $parentId
        $fld.ParentId -eq $parentId -and $fld.Name -eq $folder2 | Should Be $true
    }

    It "creates new folder by name and parent id from property" {
        $fld = [pscustomobject]@{ Name = $folder3 ; ParentId = $parentId } | New-OneDriveFolder
        $fld.ParentId -eq $parentId -and $fld.Name -eq $folder3 | Should Be $true
    }

    It "all previous test successful" {
        $items = Get-OneDriveChildItem $path -Recurse
        $items.Count | Should BeExactly 5
    }

    It "clean up and check" {
        Remove-OneDriveItem $path | Should Be $true
    }

    Context "-> Alias" {
        It "works with the alias odnf" {
            $fld = $path | odnf
            $fld.Path -replace "/$($PSOD.drive.pathRoot)", '' | Should Be $path
        }
        It "works with the alias odmkdir" {
            $fld = joinPath $path $folder1 | odmkdir
            $fld.Path -replace "/$($PSOD.drive.pathRoot)", '' | Should Be (joinPath $path $folder1)
        }
        It "clean up and check" {
            Remove-OneDriveItem $path | Should Be $true
        }
    }

}
