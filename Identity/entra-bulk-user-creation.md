[← Back to The Sky Hold](../README.md)

# Entra ID Bulk User Creation

> **Status: upload troubleshooting documented; successful import not yet confirmed with a screenshot.**

On 2026-09-17 I built a CSV of 51 test users and imported it with the Microsoft Entra admin center's **Bulk create** tool, as part of the identity groundwork for [The Ward](https://github.com/Lglass510/The_Ward_Sentinel_Soar). My [progress report from that day](https://github.com/Lglass510/The_Ward_Sentinel_Soar/blob/main/lab-journal/2026-09-17-azure-security-progress.pdf) notes working with test users and security groups. This page records what the files from that session show.

## The data

| | |
| --- | --- |
| Users | 51 (named after authors, `jane.austen`, `george.orwell`, ...) |
| Departments | 7: IT (8), Marketing (8), Sales (7), Finance (7), Human Resources (7), Operations (7), Product (7) |
| Job titles | 14 |
| Format | Entra bulk-create template (`version:v1.0` header row, then display name, UPN, initial password, block sign-in, name, job title, department, usage location, address and phone fields) |

The CSV itself isn't published here: it holds the lab tenant's domain and initial passwords.

## What happened

| Time | Step | Evidence |
| --- | --- | --- |
| 08:25 | First CSV built, with UPNs on a placeholder domain (`@fabrikam.example`) | CSV file |
| 09:04 | **Upload failed: 51 of 51 rows.** Every row returned *"The domain portion of the userPrincipalName property is invalid. You must use one of the verified domain names in your organization."* | Entra bulk-operation results file |
| 09:06 | Downloaded Microsoft's `CreateUsersTemplate.csv` to compare formats | Template file |
| 09:11 | Added usage location, office, address and phone fields | `enriched` CSV |
| 09:25 | Changed every UPN to the tenant's verified `onmicrosoft.com` domain | `fixed` CSV |

**What I learned:** Entra only accepts UPN suffixes that are verified domains in the tenant. A made-up domain fails every row, and the bulk-operation results file names the exact field and reason. That file is the first place to look when a bulk job fails.

## Not confirmed yet

- That the corrected file uploaded successfully (no results file or screenshot from the retry)
- Any groups created for these users (no group names or counts in the files)

## Evidence to add

1. **Bulk operation results:** Entra admin center > Users > **Bulk operation results**, showing the retry with 51 succeeded (or the results CSV download).
2. **User count:** `Get-MgUser -Filter "department eq 'Marketing'" -ConsistencyLevel eventual -CountVariable n -All | Out-Null; $n` for one department, or a screenshot of **All users** filtered by department.
3. **Groups, if any were made:** Entra admin center > Groups > All groups, plus one group's **Members** page.

Redact the tenant domain and IDs before adding screenshots.
