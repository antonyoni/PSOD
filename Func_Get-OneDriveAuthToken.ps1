################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

Function Get-OneDriveAuthToken {
    <#
        .SYNOPSIS
        Gets an authorization token for the application defined in the PSOD.config.json or onedrive.opt file. By default, the onedrive.readwrite permissions are requested.
        
        .EXAMPLE
        Get-OneDriveAuthToken

        .EXAMPLE
        Get-OneDriveAuthToken -AuthenticationScopes 'onedrive.readwrite', 'offline_access'
    #>
    [CmdletBinding()]
    [OutputType("PSOD.OneDriveToken")]
    Param
    (
        # The scope(s) to request authentication for. Default is 'onedrive.readwrite'.
        [Parameter(Mandatory=$False)]
        [string[]]$AuthenticationScopes = @('onedrive.readwrite'),

        # The response type to request from the authentication server. Either token or code. Default is token.
        [Parameter(Mandatory=$False)]
        [string]$ResponseType = 'token'
    )

    Begin {
        $DEFAULT_FORM_WIDTH     = 420
        $DEFAULT_FORM_HEIGHT    = 680
        $DEFAULT_BROWSER_WIDTH  = 400
        $DEFAULT_BROWSER_HEIGHT = 660
    }

    End {

        $requestUri  = $PSOD.auth.signInUrl
        $requestUri += "?client_id=$($PSOD.auth.applicationId)"
        $requestUri += "&scope=$($AuthenticationScopes -join ' ')"
        $requestUri += "&response_type=$ResponseType"
        $requestUri += "&redirect_url=$($PSOD.auth.callbackUrl)"

        Write-Verbose "$requestUri"

        $form = New-Object -TypeName System.Windows.Forms.Form -Property @{
            Width  = $DEFAULT_FORM_WIDTH
            Height = $DEFAULT_FORM_HEIGHT
        }

        $browser = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{
            Width  = $DEFAULT_BROWSER_WIDTH
            Height = $DEFAULT_BROWSER_HEIGHT
            Url    = $requestUri
        }

        $tempVar = [guid]::NewGuid().Guid
        New-Variable -Name $tempVar -Scope Global

        $browser.Add_DocumentCompleted({
            ${Global:$tempVar} = [System.Web.HttpUtility]::UrlDecode($browser.Url.AbsoluteUri)
            Write-Verbose ${Global:$tempVar}
            switch (${Global:$tempVar}) {
                {$_ -match 'error=|access_token=[^&]'} {
                    $form.Close()
                }
            }
        })

        $form.Controls.Add($browser)

        $form.ShowDialog() | Out-Null
        $form.Activate()

        if (${Global:$tempVar} -match 'error=') {
            $errId  = [regex]::Match(${Global:$tempVar}, "error=(.+?)&").Groups[1].Value
            $errMsg = [regex]::Match(${Global:$tempVar}, "error_description=(.+?)(&|$)").Groups[1].Value
            Write-Error "$errMsg ($errId)"
        } else {
            $token = New-OneDriveToken -ResponseUrl ${Global:$tempVar}
        }

        Remove-Variable -Name $tempVar -Scope Global

        Write-Output $token
    }
    
}

Export-ModuleMember -Function 'Get-OneDriveAuthToken'
