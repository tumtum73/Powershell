#Connect-AzAccount

Write-Output "Get all Azure AD Users"
[System.Collections.ArrayList]$nonECZusers = Get-AzADUser | select UserPrincipalName,@{Label="status";Expression={"Non-ECZ"}}

$ECZgroups = "ECZ"

ForEach ($group in $ECZGroups)  {
    Write-Output "Get all members of group $($group.DisplayName)"
    $members = Get-AzADGroup -DisplayName "ECZ" | Get-AzADGroupMember

    foreach ($user in $nonECZusers) {
        if ($members.UserPrincipalName -contains $user.UserPrincipalName ) {
            Write-Host "Updating user $($user.UserPrincipalName)"
            $nonECZusers[$nonECZusers.IndexOf($user)].status = "ECZ"
        }
        else {
            Write-Host "No Update for user $($user.UserPrincipalName)"
        }
    }
}

Write-Output "List of nonECZUsers"
$nonECZusers
