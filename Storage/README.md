# Storage Security

The Sky Hold currently contains three StorageV2 accounts in the `az104-storage` resource group:

| Account | Region |
| --- | --- |
| `mavsvault` | North Central US |
| `reapersvault` | North Central US |
| `servosvault` | North Central US |

## Hardening Script

[`Secure-StorageAccounts.ps1`](Secure-StorageAccounts.ps1) applies the storage security baseline to those existing accounts.

The reusable review copy is also kept in [The Forge](../../The%20Forge/Scripts/storage_account_scripts), while this repository records the Azure scope, resource assumptions, and operational safety notes.

The default baseline:

- Requires HTTPS-only traffic.
- Requires TLS 1.2.
- Disables anonymous blob access.

The script does not create or delete accounts, rotate keys, change replication, remove data, or change authentication methods. It requires an existing Azure context and supports `-WhatIf`.

The script first validates the active Azure context and each account name, builds the desired settings in one object, previews them, applies them through `ShouldProcess`, and reads the accounts again to verify the resulting state. This makes the change reviewable and safe to rehearse before execution.

## Review Before Stronger Controls

Two stronger controls are opt-in because they may affect existing clients:

```powershell
./Secure-StorageAccounts.ps1 -WhatIf -DenyPublicNetworkAccess
```

Review private endpoints, firewall rules, trusted services, application access, and recovery requirements before enabling public-network denial. Confirm the subscription and account scope before applying any change. Infrastructure encryption must be selected when creating a new storage account; it is not enabled retroactively by this script.

## Example Run

```powershell
Connect-AzAccount
./Secure-StorageAccounts.ps1 -WhatIf
./Secure-StorageAccounts.ps1
```

Run the script from an elevated administrative context with the required `Az.Accounts` and `Az.Storage` modules. Verify the output for each account after the change.