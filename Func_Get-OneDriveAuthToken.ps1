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
        Gets an authorization token for an application. By default, the onedrive.readwrite permissions are requested.
        
        .EXAMPLE
        Get-OneDriveAuthToken '0000abcd-0000-abcd-00ab-abcd0000dcba'

        .EXAMPLE
        '0000abcd-0000-abcd-00ab-abcd0000dcba' | Get-OneDriveAuthToken

        .EXAMPLE
        Get-OneDriveAuthToken -ApplicationId '0000abcd-0000-abcd-00ab-abcd0000dcba' -AuthenticationScopes 'onedrive.readwrite', 'offline_access'
        
    #>
    [CmdletBinding()]
    [OutputType("PSOD.OneDriveToken")]
    Param
    (
        # The ID of the application to get authorization for. The default is the ID of the 'OLExpenses' application.
        [Parameter(Mandatory=$True,
                   Position=1,
                   ValueFromPipeline=$True)]
        [string]$ApplicationId,

        # The scope(s) to request authentication for. Default is 'onedrive.readwrite'.
        [Parameter(Mandatory=$False)]
        [string[]]$AuthenticationScopes = @('onedrive.readwrite'),

        # The callback URL for the authentication website. By default this is 'https://login.live.com/oauth20_desktop.srf', the recommended callback for desktop apps.
        [Parameter(Mandatory=$False)]
        [string]$CallBackUrl = 'https://login.live.com/oauth20_desktop.srf',

        # The response type to request from the authentication server. Either token or code. Default is token.
        [Parameter(Mandatory=$False)]
        [string]$ResponseType = 'token',

        # The authorization URL for the API.
        [Parameter(Mandatory=$False)]
        [string]$SignInUrl = 'https://login.live.com/oauth20_authorize.srf'
    )

    Begin {
        $DEFAULT_FORM_WIDTH     = 420
        $DEFAULT_FORM_HEIGHT    = 680
        $DEFAULT_BROWSER_WIDTH  = 400
        $DEFAULT_BROWSER_HEIGHT = 660
    }

    End {

        $requestUri  = $SignInUrl
        $requestUri += "?client_id=$ApplicationId"
        $requestUri += "&scope=$($AuthenticationScopes -join ' ')"
        $requestUri += "&response_type=$ResponseType"
        $requestUri += "&redirect_url=$CallBackUrl"

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
            Write-Error (${Global:$tempVar} -split '#')[1]
        } else {
            $token = New-OneDriveToken -ResponseUrl ${Global:$tempVar}
        }

        Remove-Variable -Name $tempVar -Scope Global

        Write-Output $token
    }
    
}

Export-ModuleMember -Function 'Get-OneDriveAuthToken'

<#
$token = Get-Content .\onedrive.opt | Get-OneDriveAuthToken -Verbose
$token | Get-Member
$token
#>
