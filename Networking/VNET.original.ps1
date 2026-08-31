## Virtual Network Creation
#Variable declarations

$virtualNetworkName = 'mavnetwork'
$resourceGroupName = 'az104-network'
$location = 'northcentralus'

$vnet = @{
    Name = $virtualNetworkName
    ResourceGroupName = $resourceGroupName
    Location = $location
    AddressPrefix = '10.0.0.0/16'
}

$virtualNetwork = New-AzVirtualNetwork @vnet



## Mars1 Subnet Creation
$subnetName = 'mars1'

$subnet = @{
    Name = $subnetName
    AddressPrefix = '10.0.1.0/24'
}

Add-AzVirtualNetworkSubnetConfig @subnet -VirtualNetwork $virtualNetwork 
$virtualNetwork | Set-AzVirtualNetwork







