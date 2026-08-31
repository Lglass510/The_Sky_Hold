#Requires -Modules Az.Network

<#
.SYNOPSIS
    Creates a virtual network with one subnet.
.DESCRIPTION
    VNet address space is 10.0.0.0/16 (65,536 addresses).
    The mars1 subnet carves out 10.0.1.0/24 (256 addresses, 251 usable —
    Azure reserves 5 per subnet: network, gateway, 2x DNS, broadcast).
    10.0.0.0/24 is left unused, reserved for a future subnet.
    See VNET.original.ps1 for the first pass and what changed.
#>

$ErrorActionPreference = 'Stop'

## Context guard
$ctx = Get-AzContext
if (-not $ctx) { throw 'Not connected. Run Connect-AzAccount.' }
Write-Host "Deploying to subscription: $($ctx.Subscription.Name)"

## Virtual Network + Subnet creation
#Variable declarations
$virtualNetworkName = 'mavnetwork'
$resourceGroupName = 'az104-network'
$location = 'northcentralus'

$subnetName = 'mars1'
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix '10.0.1.0/24'

$vnetParams = @{
    Name = $virtualNetworkName
    ResourceGroupName = $resourceGroupName
    Location = $location
    AddressPrefix = '10.0.0.0/16'
    Subnet = $subnetConfig
}

$existing = Get-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "VNet '$virtualNetworkName' already exists in '$resourceGroupName' — skipping creation."
    $virtualNetwork = $existing
} else {
    $virtualNetwork = New-AzVirtualNetwork @vnetParams
}

Write-Host "VNet '$($virtualNetwork.Name)' ready with subnet(s): $($virtualNetwork.Subnets.Name -join ', ')"
