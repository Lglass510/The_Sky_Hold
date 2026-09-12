#Requires -Modules Az.Accounts, Az.Storage

<#!
.SYNOPSIS
    Applies a baseline security configuration to existing Azure Storage accounts.

.DESCRIPTION
    This script hardens the storage accounts used by the Sky Hold storage lab.
    It does not create, delete, rotate keys, change replication, or remove data.

    The baseline enforces HTTPS-only traffic, TLS 1.2, and disables anonymous
    blob access.

    Public network access denial is opt-in because it can affect existing clients.
    Infrastructure encryption is a creation-time design decision and is not
    attempted against existing accounts by this script.

    Run with -WhatIf first. The script requires an existing Az login and does not
    connect or request credentials automatically.
#>

# CmdletBinding enables advanced function behavior. SupportsShouldProcess adds
# PowerShell's standard -WhatIf and -Confirm safeguards for Azure changes.
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ResourceGroupName = 'az104-storage',

    [string[]]$StorageAccountName = @(
        'mavsvault',
        'reapersvault',
        'servosvault'
    ),

    [switch]$DenyPublicNetworkAccess
)

$ErrorActionPreference = 'Stop'

# Fail before making any API calls if the operator has not selected an Azure
# subscription. Silent continuation would make the target environment unclear.
$context = Get-AzContext
if (-not $context) {
    throw 'No Azure context is active. Run Connect-AzAccount before running this script.'
}

# Print the active scope so the operator can catch an unexpected subscription or
# resource group before reviewing the proposed changes.
Write-Host "Subscription: $($context.Subscription.Name)"
Write-Host "Resource group: $ResourceGroupName"

# Process each named account independently. Get-AzStorageAccount confirms that
# the account exists and prevents a typo from becoming a misleading update.
foreach ($name in $StorageAccountName) {
    Get-AzStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -Name $name `
        -ErrorAction Stop | Out-Null

    # Keep the baseline in one hashtable so the same settings are passed to the
    # update command and can be displayed before execution.
    $settings = @{
        EnableHttpsTrafficOnly = $true
        MinimumTlsVersion = 'TLS1_2'
        AllowBlobPublicAccess = $false
    }

    # Network isolation can break applications that still use public endpoints,
    # so it requires an explicit switch instead of being enabled by default.
    if ($DenyPublicNetworkAccess) {
        $settings.PublicNetworkAccess = 'Disabled'
    }

    # Convert the requested settings into readable output. This makes the intended
    # state visible during both normal and -WhatIf runs.
    $changes = $settings.GetEnumerator() | ForEach-Object {
        "$($_.Key)=$($_.Value)"
    }

    Write-Host "[$name] Requested settings: $($changes -join ', ')"

    # SupportsShouldProcess provides PowerShell's standard -WhatIf and -Confirm
    # safeguards, allowing the operator to inspect the plan before changing Azure.
    if ($PSCmdlet.ShouldProcess($name, 'Apply storage security baseline')) {
        # Apply only the explicit baseline settings. The script deliberately does
        # not rotate keys, alter replication, delete data, or change access policy.
        Set-AzStorageAccount `
            -ResourceGroupName $ResourceGroupName `
            -Name $name `
            @settings | Out-Null

        # Read the account again after the update so the output reflects Azure's
        # stored state rather than assuming the request succeeded.
        $verified = Get-AzStorageAccount `
            -ResourceGroupName $ResourceGroupName `
            -Name $name

        # Report the controls that matter to the security baseline, including the
        # resulting network-access mode when that optional switch was used.
        Write-Host "[$name] Verified: HTTPS=$($verified.EnableHttpsTrafficOnly); TLS=$($verified.MinimumTlsVersion); BlobPublicAccess=$($verified.AllowBlobPublicAccess); PublicNetworkAccess=$($verified.PublicNetworkAccess)"
    }
}