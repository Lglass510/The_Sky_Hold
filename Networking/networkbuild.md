# Building the Network — The Story So Far

**Goal:** stand up a virtual network for the AZ-104 lab, understand every line that builds it, and document the mistakes along the way instead of hiding them.

---

## Attempt 1 — It Worked, But I Didn't Know Why

![Original VNet build script](screenshots/original_vnet_build.png)

The first version of [VNET.ps1](VNET.ps1) ([VNET.original.ps1](VNET.original.ps1) keeps this exact version preserved) does two things:

1. Creates an empty VNet (`mavnetwork`, `10.0.0.0/16`) with `New-AzVirtualNetwork`.
2. Builds a subnet (`mars1`, `10.0.1.0/24`) and staples it onto that VNet with `Add-AzVirtualNetworkSubnetConfig`, then pushes the change to Azure with `Set-AzVirtualNetwork`.

It ran. The subnet showed up in Azure. Job done — or so I thought.

### What I got wrong

`Add-AzVirtualNetworkSubnetConfig` returns an updated copy of the VNet object. I never captured that return value:

```powershell
Add-AzVirtualNetworkSubnetConfig @subnet -VirtualNetwork $virtualNetwork
$virtualNetwork | Set-AzVirtualNetwork
```

This *should* have been:

```powershell
$virtualNetwork = Add-AzVirtualNetworkSubnetConfig @subnet -VirtualNetwork $virtualNetwork
```

It only worked by accident — the cmdlet also happens to mutate `$virtualNetwork` in place as a side effect, so line 2 picked up the subnet anyway. The lesson isn't "it was broken," it's that **it worked for a reason I didn't understand**, which is arguably worse for a lab whose whole point is understanding the *why*. Relying on an undocumented side effect instead of the actual return value is a habit that will eventually break silently, on some future cmdlet that doesn't happen to be as forgiving.

### Other gaps in this pass

- No check for whether I was even logged into the right subscription.
- No error handling — a failed `New-AzVirtualNetwork` would leave `$virtualNetwork` empty and the next command would fail with a confusing null-reference error instead of the real Azure error.
- Not safe to re-run — running it twice fails with "already exists" instead of just confirming the VNet is there.
- Two separate calls to Azure (create VNet, then update it) to do something that can be done in one.

---

## Attempt 2 — Refactored With the Failures in Mind

![Refactored VNet build script](screenshots/refactored_vnetbuild.png)

The current [VNET.ps1](VNET.ps1) fixes each of those, one problem at a time:

| Problem in Attempt 1 | Fix in Attempt 2 |
|---|---|
| Discarded return value, relied on a side effect | Subnet is built with `New-AzVirtualNetworkSubnetConfig` *before* the VNet exists, and passed straight into `New-AzVirtualNetwork` — one call, no silent mutation to depend on |
| No check on which subscription I was deploying into | `Get-AzContext` guard at the top — throws immediately with a clear message if not logged in |
| Errors could fail silently and cascade | `$ErrorActionPreference = 'Stop'` — the script halts at the actual point of failure |
| Re-running the script failed on "already exists" | `Get-AzVirtualNetwork` checks first; if found, it reuses it instead of erroring |
| Two round-trips to Azure | Down to one — the subnet is included in the `New-AzVirtualNetwork` call instead of added afterward |

### The trade-off worth naming

Collapsing the two-step "create, then add a subnet" pattern into a single call is more efficient, but it also means I'm no longer practicing the *other* real-world pattern: adding a subnet to a VNet that **already exists**. That's a genuinely different and common admin task (the original script's approach, done correctly with the return value captured). If I want to keep exercising that pattern, the right move is a **separate script** for "add a subnet to an existing VNet," not bolting it back onto this one.

---

## What This Taught Me

- A command running without an error is not the same as a command being *correct*. `Add-AzVirtualNetworkSubnetConfig` "worked" while hiding exactly the kind of gap in understanding this lab exists to close.
- Capture return values. Don't assume a cmdlet mutating something in place is guaranteed behavior — it's an implementation detail, not a contract.
- Idempotency (safe to re-run) and error handling aren't extra polish for a lab script — they're what makes it possible to iterate quickly without a re-run turning into a cleanup chore.
- There's more than one correct way to build the same resource in Azure, and the "better" one depends on what you're actually trying to practice, not just which is fewer lines.

## Next

- [ ] Write the companion script for adding a subnet to an existing VNet, using the corrected (return-value-captured) version of the Attempt 1 pattern.
- [ ] Add an NSG to `mars1` and document that decision here too.
- [ ] Screenshot the resulting VNet/subnet from the Azure Portal to confirm CLI output matches what actually deployed.
