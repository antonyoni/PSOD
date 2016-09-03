################################################################################
# Author     : Antony Onipko
# Copyright  : (c) 2016 Antony Onipko. All rights reserved.
################################################################################
# This work is licensed under the
# Creative Commons Attribution-ShareAlike 4.0 International License.
# To view a copy of this license, visit
# https://creativecommons.org/licenses/by-sa/4.0/
################################################################################

Function New-OneDriveToken {
    <#
        .SYNOPSIS
        Creates a new OneDrive Authentication token from an API response.
        
        .EXAMPLE
        New-OneDriveToken -ResponseUrl $ApiResponse
    #>
    [CmdletBinding(DefaultParameterSetName='API Response')]
    [Alias('odnt')]
    [OutputType([PsObject])]
    Param
    (
        # The API response URL from an authentication request.
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   Position=1,
                   ParameterSetName='API Response')]
        [string]$ResponseUrl,

        # The access token.
        [Parameter(Mandatory=$True,
                   Position=1,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Token Details')]
        [string]$AccessToken,

        # Type of token requested. Either bearer or code.
        [Parameter(Mandatory=$True,
                   Position=2,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Token Details')]
        [Alias("TokenType")]
        [string]$Type,

        # Number of seconds that the token is valid for.
        [Parameter(Mandatory=$True,
                   Position=3,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Token Details')]
        [int]$ExpiresIn,

        # The requested authentication scope(s).
        [Parameter(Mandatory=$True,
                   Position=4,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Token Details')]
        [string[]]$Scope,

        # The user ID of the requestor.
        [Parameter(Mandatory=$True,
                   Position=5,
                   ValueFromPipelineByPropertyName=$True,
                   ParameterSetName='Token Details')]
        [string]$UserId
    )

    Process {

        if ($ResponseUrl) {
            $AccessToken = [regex]::Match($ResponseUrl, "access_token=(.+?)&").Groups[1].Value
            $Type        = [regex]::Match($ResponseUrl, "token_type=(.+?)&").Groups[1].Value
            $ExpiresIn   = [regex]::Match($ResponseUrl, "expires_in=(.+?)&").Groups[1].Value
            $Scope       = [regex]::Match($ResponseUrl, "scope=(.+?)&").Groups[1].Value -split " "
            $UserId      = [regex]::Match($ResponseUrl, "user_id=(.+?)(&|$)").Groups[1].Value
        }

        $nt = [pscustomobject]@{
            AccessToken = $AccessToken
            Type        = $Type
            ExpiresIn   = $ExpiresIn
            Created     = Get-Date
            Scope       = $Scope
            UserId      = $UserId
        }

        $nt.PsObject.TypeNames.Insert(0, "PSOD.OneDriveToken")
        
        Write-Output $nt
    }

}

Export-ModuleMember -Function 'New-OneDriveToken' -Alias 'odnt'
