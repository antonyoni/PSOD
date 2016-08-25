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

Describe "Get-OneDriveAuthToken" {

    Context "-> Authenticates against OneDrive" {

        $token = Get-OneDriveAuthToken

        It "and return a token" {
            $token | Should Not Be $null
        }

        It "the token is of type PSOD.OneDriveToken" {
            ($token | get-member).TypeName | Should BeExactly 'PSOD.OneDriveToken'
        }

    }

    Context "-> handles errors correctly" {

        $PSOD.auth.applicationId = ''

        It "does not return a token" {
            $token = Get-OneDriveAuthToken
            $token | Should Be $null
        }

        It "returns error based on the return URL" {
            try {
                $token = Get-OneDriveAuthToken
            } catch {
                $_
            }
            $Error.Count | Should BeExactly 1
        }

        $PSOD.auth.signInUrl =  ''

        It "handles HTTP errors correctly" {
            try {
                $token = Get-OneDriveAuthToken
            } catch {
                $_
            }
            $Error.Count | Should BeExactly 1
        }
    }

}
