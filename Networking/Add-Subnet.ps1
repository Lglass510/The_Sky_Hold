#Requires -Modules Az.Network

<#
.SYNOPSIS
    Adds a subnet to an existing virtual network.
.DESCRIPTION
    Companion to VNET.ps1 — that script builds a VNet from scratch with its
    subnet included in one call. This script covers the other real admin task:
    adding a subnet to a VNet that already exists.

    Unlike Attempt 1 in VNET.original.ps1, this captures the return value of
    Add-AzVirtualNetworkSubnetConfig instead of relying on it mutating the
    original object as a side effect. See networkbuild.md for why that matters.

    Used here to add AzureBastionSubnet (10.0.0.0/26) to mavnetwork, carved out
    of the 10.0.0.0/24 block that VNET.ps1 left reserved.
#>

param(
    [string]$VirtualNetworkName = 'mavnetwork',
    [string]$ResourceGroupName  = 'az104-network',
    [string]$SubnetName         = 'AzureBastionSubnet',
    [string]$AddressPrefix      = '10.0.0.0/26'
)

$ErrorActionPreference = 'Stop'

$ctx = Get-AzContext
if (-not $ctx) { throw 'Not connected. Run Connect-AzAccount.' }
Write-Host "Deploying to subscription: $($ctx.Subscription.Name)"

$virtualNetwork = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

$existingSubnet = $virtualNetwork.Subnets | Where-Object { $_.Name -eq $SubnetName }
if ($existingSubnet) {
    Write-Host "Subnet '$SubnetName' already exists in '$VirtualNetworkName' — skipping."
} else {
    # Capture the return value — this is the fix for the Attempt 1 bug.
    $virtualNetwork = Add-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $AddressPrefix -VirtualNetwork $virtualNetwork
    $virtualNetwork = $virtualNetwork | Set-AzVirtualNetwork
    Write-Host "Subnet '$SubnetName' ($AddressPrefix) added to '$VirtualNetworkName'."
}

Write-Host "VNet '$($virtualNetwork.Name)' now has subnet(s): $($virtualNetwork.Subnets.Name -join ', ')"
