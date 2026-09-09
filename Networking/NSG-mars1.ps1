#Requires -Modules Az.Network

<#
.Synopsis
   Creates a Network Security Group
.DESCRIPTION
   This script creates a Network Security Group with specified rules
#>

$ErrorActionPreference = 'Stop'

## Context guard
$ctx = Get-AzContext   
if (-not $ctx) { throw 'Not connected. Run Connect-AzAccount.' }
Write-Host "Deploying to subscription: $($ctx.Subscription.Name)"


## Create the rule in memory with New-AzNetworkSecurityRuleConfig then deploy it with New-AzNetworkSecurityGroup
##Only traffic originating from the Bastion subnet is allowed in on 3389
$rdpFromBastion = New-AzNetworkSecurityRuleConfig `
-Name 'Allow-RDP-From-Bastion' `
-Description ' RDP only from the Bastion subnet, nothing else inbound' `
-Access Allow `
-Protocol Tcp `
-Direction Inbound `
-Priority 100 `
-SourceAddressPrefix '10.0.0.0/26' `
-SourcePortRange '*' `
-DestinationAddressPrefix '*' `
-DestinationPortRange 3389



$nsgName = 'mars1-nsg'
$resourceGroupName = 'az104-network'
$location ='northcentralus'

$nsg = New-AzNetworkSecurityGroup `
-Name $nsgName `
-ResourceGroupName $resourceGroupName `
-Location $location `
-SecurityRules $rdpFromBastion `
-Force ## skip rdp/ssh confirmation prompt



$vnet = Get-AzVirtualNetwork -Name 'mavnetwork' -ResourceGroupName $resourceGroupName
$subnet = $vnet.Subnets | Where-Object { $_.Name -eq 'mars1' }

$vnet = Set-AzVirtualNetworkSubnetConfig `
-Name 'mars1' `
-VirtualNetwork $vnet `
-AddressPrefix $subnet.AddressPrefix `
-NetworkSecurityGroup $nsg


$vnet = $vnet | Set-AzVirtualNetwork




