param(
    [string]$clientId,
    [string]$clientSecret,
    [string]$tenantId,
    [string]$recipientEmail
)

$fromEmail = "Stephen Correia <stephen.correia@volvo.com>"

# Function to get access token using v2 endpoint
function Get-AccessToken {
    param (
        [string]$clientId,
        [string]$clientSecret,
        [string]$tenantId
    )

$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $body = @{
        grant_type    = "client_credentials"
        client_id     = $clientId
        client_secret = $clientSecret
        scope         = "https://graph.microsoft.com/.default"
    }

$response = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body
    return $response.access_token
}

# Function to send email using Microsoft Graph API
function Send-Email {
    param (
        [string]$accessToken,
        [string]$recipientEmail,
        [string]$subject,
        [string]$body,
        [string]$fromEmail
    )

$graphApiEndpoint = "https://graph.microsoft.com/v1.0/users/$($recipientEmail)/sendMail"
    $headers = @{
        Authorization = "Bearer $accessToken"
        "Content-Type" = "application/json"
    }

$emailData = @{
        message = @{
            subject = $subject
            body = @{
                contentType = "Text"
                content = $body
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = $recipientEmail
                    }
                }
            )
            from = @{
                emailAddress = @{
                    address = $fromEmail
                }
            }
        }
    }

$emailJson = $emailData | ConvertTo-Json -Depth 100
    Invoke-RestMethod -Uri $graphApiEndpoint -Method Post -Headers $headers -Body $emailJson -ContentType "application/json"
}

# Main script
try {
    # Get the access token
    $accessToken = Get-AccessToken -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId

# Compose the email subject and body
    $subject = "Test Email from PowerShell"
    $body = "This is a test email sent from PowerShell using Microsoft Graph API."
    $sender = "$fromEmail"

# Send the email
    Send-Email -accessToken $accessToken -recipientEmail $recipientEmail -subject $subject -body $body -fromEmail $sender

Write-Host "Email sent successfully!"
}
catch {
    Write-Host "Failed to send email: $($_.Exception.Message)"
}