. .\setup-test.ps1

Describe "New-OneDriveAuthToken" {

    $ResponseUrl = "http://localhost:8080/#access_token=ABC123==&token_type=bearer&expires_in=3600&scope=onedrive.readwrite files.read&user_id=uid123"

    $tokenDetails = @{
        AccessToken = "ABC123=="
        Type        = "bearer"
        Scope       = @('onedrive.readwrite', 'files.read')
        UserId      = "uid123"
        ExpiresIn   = 3600
    }

    Context "-> New token created from a response URL" {

        It "from an explicit parameter" {
            $token = New-OneDriveToken -ResponseUrl $ResponseUrl
            $token | Should Not BeNullOrEmpty
        }

        It "from an implicit parameter" {
            $token = New-OneDriveToken $ResponseUrl
            $token | Should Not BeNullOrEmpty
        }

        $token = $ResponseUrl | New-OneDriveToken

        It "from the pipeline" {
            $token | Should Not BeNullOrEmpty
        }

        # Test that each of the token values is parsed correctly from the response URL
        $tokenDetails.GetEnumerator() | % {
            $k = $_.Key
            $v = $_.Value

            It "and the '$k' is parsed correctly" {
                $token.$k | Should BeExactly $v
            }
        }

    }

    Context "-> New token created from Token Details parameter set" {

        It "from explicit parameters" {
            $token = New-OneDriveToken -AccessToken "ABC123==" `
                                       -Type "bearer" `
                                       -ExpiresIn 3600 `
                                       -Scope "onedrive.readwrite", "files.read" `
                                       -UserId "uid123"
            $token | Should Not BeNullOrEmpty
        }

        It "from values passed by pipeline" {
            $tokenObject = New-Object PsObject -Property $tokenDetails
            $token = $tokenObject | New-OneDriveToken
            $token | Should Not BeNullOrEmpty
        }

        It "from another token" {
            $anotherToken = $ResponseUrl | New-OneDriveToken
            $token = $anotherToken | New-OneDriveToken
            $token | Should Not BeNullOrEmpty
        }

    }

    Context "-> Type extensions are working" {

        $token = $ResponseUrl | New-OneDriveToken

        It "returns a token of type 'PSOD.OneDriveToken'" {
            ($token | get-member).TypeName | Should BeExactly 'PSOD.OneDriveToken'
        }

        It "has a property ExpiryDate" {
            $token.ExpiryDate | Should Not BeNullOrEmpty
        }

        It "returns the AccessToken with ToString" {
            $token.ToString() | Should BeExactly $token.AccessToken
        }

    }
}
