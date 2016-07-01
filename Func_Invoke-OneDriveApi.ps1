################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-nc-sa/4.0/
################################################################################

Function Invoke-OneDriveApi {
    <#
        .SYNOPSIS
        Wrapper for Invoke-RestMethod to send commands to the OneDrive API.
        
        .EXAMPLE
        Invoke-OneDriveApi -Path $path -Token $token.Token

        .EXAMPLE
        'drive', 'drives' | Invoke-OneDriveApi -Token $token.Token

        .EXAMPLE
        $token | Invoke-OneDriveApi -Path 'drive/view.recent'
    #>
    [CmdletBinding()]
    [OutputType([PsObject])]
    Param
    (
        # API resource path.
        [Parameter(Mandatory=$True,
                   Position=1,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [string]$Path,

        # The API authentication token.
        [Parameter(Mandatory=$True,
                   Position=2,
                   ValueFromPipelineByPropertyName=$True)]
        [string]$Token,

        # Api URL. Default is the OneDrive personal address of 'https://api.onedrive.com/v1.0/'. 
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True)]
        [string]$ApiUrlRoot = 'https://api.onedrive.com/v1.0/',

        # The method used for the API request.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True)]
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method,

        # Data to be sent as part of the API request.
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$True)]  
        $Body
    )

    Process {

        $baseUri    = New-Object uri($ApiUrlRoot)
        $requestUri = New-Object uri($baseUri, $Path)

        Write-Verbose "Request URI:`n$requestUri"

        $requestHeaders = @{
            Authorization = "bearer $Token"
            Accept        = 'application/json'
        }

        $irmParams = @{
            Uri         = $requestUri
            Headers     = $requestHeaders
            ContentType = 'application/json'
        }

        if ($Method) {
            $irmParams['Method'] = $Method
        }

        if ($Body) {
            $irmParams['Body'] = $Body
        }

        $rsp = Invoke-RestMethod @irmParams

        Write-Output $rsp
    }
    
}

Export-ModuleMember -Function 'Invoke-OneDriveApi'

#$token = Get-Content .\PSOD\onedrive.opt | Get-OneDriveAuthToken
#$path = 'drive'
#Invoke-OneDriveApi -Path $path -Token $token.Token
#'drive', 'drive' | Invoke-OneDriveApi -Token $token.Token
#$token | Invoke-OneDriveApi -Path 'drive/view.recent'
<#
[pscustomobject]@{
    Path  = 'drive/shared'
    Token = $token.Token
} | Invoke-OneDriveApi
#>
<#
Invoke-OneDriveApi -Path 'drive/root:/Documents:/children'`
                   -Token $token.Token `
                   -Method Post `
                   -Body ([ordered]@{
                       name   = 'TestFolder'
                       folder = @{}
                   } | ConvertTo-Json) `
                   -Verbose
#>
