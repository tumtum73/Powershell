param(
  [Parameter(Mandatory=$true)]
  [string]$resourceGroupName,
  [Parameter(Mandatory=$true)]
  [ValidateSet("eastus", "eastus2", "westus")]
  [string]$location = "eastus",
  [string]$storageAccountName,
  [string]$VMName
)



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

if (!(Get-AzVM -Name CorreiaTest1)) {
  Write-Output "Virtual Machine $VMName already exists."
}
else {
  New-AzVm `
      -ResourceGroupName $resourceGroupName `
      -Name $VMName `
      -Location $location `
      -VirtualNetworkName "myVnet" `
      -SubnetName "mySubnet" `
      -SecurityGroupName "myNetworkSecurityGroup" `
      -PublicIpAddressName "myPublicIpAddress" `
      -OpenPorts 80,3389
}