param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("AzureCloud", "AzureUSGovernment")]
  [string]$azenv,
  [Parameter(Mandatory=$true)]
  [string]$resourceGroupName,
  [ValidateSet("eastus", "eastus2", "westus")]
  [string]$location = "eastus",
  [Parameter(Mandatory=$true)]
  [string]$storageAccountName,
  [Parameter(Mandatory=$true)]
  [string]$VMName,
  [Parameter(Mandatory=$false)]
  [string]$VMLocalAdminUser = "LocalAdminUser",
  [Parameter(Mandatory=$false)]
  [ValidateSet("Standard_A8_v2", "Standard_D4_v3")]
  [string]$VMSize = "Standard_A8_v2"
)

if ($PSVersionTable.PSEdition -eq 'Desktop' -and (Get-Module -Name AzureRM -ListAvailable)) {
  Write-Warning -Message ('Az module not installed. Having both the AzureRM and ' +
    'Az modules installed at the same time is not supported.')
} else {
  Install-Module -Name Az -AllowClobber -Scope CurrentUser
}

# Connect to Azure with a browser sign in token
Write-Output "Login to Azure"
$login = Connect-AzAccount -Environment $azenv

# Get Credential for VM
Write-Output "Set Password for VM Admin"
$VMCred = Get-Credential -UserName $VMLocalAdminUser -Message "Set password for local admin account"

if (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue) {
  Write-Output "Resource Group $($resourceGroupName) exists!"
}
else {
  # Create the resource group.
  New-AzResourceGroup -Name $resourceGroupName -Location $location
  Write-Output "resource Group $($resourceGroupName) created!"
}

if (get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue) {
  Write-Output "Storage Account $($storageAccountName) exists!"
}
else {
  # Create the storage account.
  $storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -Location $location `
    -SkuName "Standard_LRS"
  Write-Output "Storage Account $($storageAccountName) created!"
}

# Retrieve the context.
$ctx = $storageAccount.Context

New-AzVm `
    -ResourceGroupName $resourceGroupName `
    -Name $VMName `
    -Location $location `
    -VirtualNetworkName "myVnet" `
    -SubnetName "mySubnet" `
    -SecurityGroupName "myNetworkSecurityGroup" `
    -PublicIpAddressName "myPublicIpAddress" `
    -Size $VMSize `
    -Credential $VMCred

#Reference:  http://woshub.com/get-external-ip-powershell/
Write-Output "Get Client Public IP Address"
$clientPublicIPAddress = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
Write-Output "ClientPublic IP Address $($clientPublicIPAddress)"

Write-Output "Get VM Public IP Address"
$myPublicIpAddress = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName | Select IpAddress
Write-Output "Connect to VM using Public IP Address $($myPublicIpAddress)"

# Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig `
  -Name myNetworkSecurityGroupRuleRDP `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 1000 `
  -SourceAddressPrefix $($clientPublicIPAddress)/32 `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 3389 `
  -Access Allow

  $nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -Name myNetworkSecurityGroup `
  -SecurityRules $nsgRuleRDP
