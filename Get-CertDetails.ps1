<#

.SYNOPSIS

Get Cert Details from provided URL

 

.DESCRIPTION

Get Cert Details from provided URL

 

.PARAMETER url

the https Uniform Resource Locator for a web site with SSL enabled

 

.EXAMPLE

Get-CertDetails.ps1 -url "https://www.microsoft.com/"

 

.EXAMPLE

  Get-CertDetails.ps1 "https://www.microsoft.com/"

 

.NOTES


               Script:   Get-CertDetails.ps1

               Version:               1.0

               Author:                Stephen Correia

               Date:                    06/14/2022

               Keywords:          

               Comments:        

               References:

               https://www.tutorialspoint.com/how-to-get-website-ssl-certificate-validity-dates-with-powershell

#>

 

[CmdletBinding()]

param(

    [Parameter(

        Mandatory = $false

    )]

    [string]    $url = "https://www.microsoft.com/"

)

 

#Colorize output

#Reference:  https://stackoverflow.com/questions/24551420/how-to-colour-a-variable-in-psobject-output

$esc = [char]27

$redBright = 91

 

$daysTillExpire = 30

 

$today = Get-Date

[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

$req = [Net.HttpWebRequest]::Create($url)

$req.GetResponse() | Out-Null

$expDate = [datetime]$req.ServicePoint.Certificate.GetExpirationDateString()

 

Write-Host "URL = $url"

Write-Host "Cert Start Date = $($req.ServicePoint.Certificate.GetEffectiveDateString())"

 

if ($expDate -lt $today.AddDays($daysTillExpire)){

    #$expirationDate = "$esc[${redBright}m$($expDate)$esc[0m"

    Write-Host -ForegroundColor Red "Cert End Date = $expDate"

   }

else {

    Write-Host "Cert End Date = $expDate"

}
