################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

. .\setup-test.ps1

Describe "Get-OneDriveChildItem" {

    $path   = "PSOD/odgci" # Folder containing one folder, two documents, 7 item recursively
    $itemId = (Get-OneDriveItem $path).Id

    It "gets children of the drive root by default" {
        $rsp = Get-OneDriveChildItem
        ($rsp.Parent -ne '/drive/root:').Count | Should Be 0
    }

    It "gets correct number of items from test directory" {
        $rsp = Get-OneDriveChildItem -Path $path
        $rsp.Count | Should Be 3
    }

    It "gets correct number of items recursively" {
        $rsp = Get-OneDriveChildItem -Path $path -Recurse
        $rsp.Count | Should Be 7
    }

    It "gets items by path from pipeline" {
        $rsp = $path | Get-OneDriveChildItem
        $rsp.Count | Should Be 3
    }

    It "gets item by path from property" {
        $rsp = [pscustomobject]@{ Resource = $path } | Get-OneDriveChildItem
        $rsp.Count | Should Be 3
    }

    It "gets item by ID recursively" {
        $rsp = Get-OneDriveChildItem -ItemId $itemId -Recurse
        $rsp.Count | Should Be 7
    }

    It "gets item by ID from property" {
        $rsp = [pscustomobject]@{ id = $itemId } | Get-OneDriveChildItem
        $rsp.Count | Should Be 3
    }

    Context "-> Alias" {
        It "works with the alias odgci" {
            $rsp = $path | odgci
            $rsp.count | Should Be 3
        }
        It "works with the alias odls" {
            $rsp = $path | odls
            $rsp.count | Should Be 3
        }
    }

}
