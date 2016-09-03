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
        
        $appId = $PSOD.auth.applicationId
        $PSOD.auth.applicationId = ''

        try {
            $token = Get-OneDriveAuthToken -ErrorAction Stop
        } catch {
            $err = $_
        }

        It "does not return a token" {
            $token | Should BeNullOrEmpty
        }

        It "returns error based on the return URL" {
            $err.Exception.Message -match 'client_id' | Should Be $true
        }

        $PSOD.auth.applicationId = $appId
        $PSOD.auth.signInUrl =  'http://does-not-exist/'

        It "handles HTTP errors correctly" {
            try {
                $token = Get-OneDriveAuthToken -ErrorAction Stop
            } catch {
                $err = $_
            }
            $err.Exception.Message | Should Be 'An error occured when navigating to the login page.'
        }
    }

}
