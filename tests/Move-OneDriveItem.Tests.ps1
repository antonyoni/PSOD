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

Describe "Move-OneDriveItem" {

    $path    = "PSOD/odcp" # Folder containing three folders, two empty, one with two docs
    $file1   = "doc1.docx"
    $file2   = "excel1.xlsx"
    $folder1 = "PSOD/odcp/Folder1"
    $folder2 = "PSOD/odcp/Folder2"
    $folder3 = "PSOD/odcp/DestinationFolder"

    It "check test folder setup (if this fails, results might not be accurate)" {
        $rsp = Get-OneDriveChildItem -Path $path -Recurse
        $rsp.Count | Should Be 5
    }

    Context "-> File move" {
        It "moves files by path" {
            $p = joinPath $folder1 $file1
            $item = Move-OneDriveItem -Path $p -Destination $folder2
            $item.Parent -replace "/$($PSOD.drive.pathRoot)", '' | Should Be $folder2
        }
        It "moves files by path from pipeline" {
            $item = (joinPath $folder1 $file2) | Move-OneDriveItem -Destination $folder2
            $item.Parent -replace "/$($PSOD.drive.pathRoot)", '' | Should Be $folder2
        }
        It "moves files by id" {
            $p = joinPath $folder2 $file1
            $id = (Get-OneDriveItem $p).id
            $item = Move-OneDriveItem -ItemId $id -Destination $folder1
            $item.Parent -replace "/$($PSOD.drive.pathRoot)", '' | Should Be $folder1
        }
        It "moves files by id from pipeline by property name" {
            $p = joinPath $folder2 $file2
            $id = (Get-OneDriveItem $p).id
            $item = [pscustomobject]@{ id = $id } | Move-OneDriveItem -Destination $folder1
            $item.Parent -replace "/$($PSOD.drive.pathRoot)", '' | Should Be $folder1
        }
    }

    Context "-> Directory move" {
        It "moves directories by path" {
            $item = Move-OneDriveItem -Path $folder1 -Destination $folder3
            $item.Parent -replace "/$($PSOD.drive.pathRoot)", '' | Should Be $folder3
        }
        It "moves directories by id" {
            $fld = joinPath $folder3 'Folder1'
            $id = (Get-OneDriveItem $fld).id
            $item = Move-OneDriveItem -id $id -Destination $path
            $item.Parent -replace "/$($PSOD.drive.pathRoot)", '' | Should Be $path
        }
    }

    Context "-> Alias" {
        It "works with the alias odmv" {
            $p = joinPath $folder1 $file1
            $item = odmv $p $folder2
            $item.Parent -replace "/$($PSOD.drive.pathRoot)", '' | Should Be $folder2
        }
        It "works with the alias odmove" {
            $p = joinPath $folder2 $file1
            $item = odmove $p $folder1
            $item.Parent -replace "/$($PSOD.drive.pathRoot)", '' | Should Be $folder1
        }
    }

    Context "-> Correctly sets parameters for Invoke-RestMethod" {
        Mock -ModuleName PSOD Invoke-RestMethod { return $Headers }
        It "Additional Headers" {
            $m = Move-OneDriveItem -Path "test-path" -Destination "test-destination"
            $m['Prefer'] | Should Be 'respond-async'
        }
    }

}
