# Azure Lab

> **Build it. Break it. Secure it. Understand it.**

This lab is my hands-on Azure environment for preparing for the **Microsoft Certified: Azure Administrator Associate (AZ-104)** and **Microsoft Certified: Identity and Access Administrator Associate (SC-500)** exams.

The goal isn't to memorize which button to click in the Azure Portal.

The goal is to understand what is happening underneath the interface — how Azure resources are created, connected, secured, monitored, and administered — and to become comfortable managing those resources through the **Azure Portal, Azure CLI, PowerShell, and Bicep**.

---

## The Story

I'm building this lab from the ground up.

Starting with an empty Azure environment, I'm working through the same problems an administrator would encounter in a real infrastructure environment:

**Who gets access?**

**Where does the workload run?**

**How does it communicate?**

**Where does the data live?**

**How do I know when something breaks?**

**How do I secure it?**

**And eventually — can I rebuild the whole thing without clicking through the Portal?**

Each section of this repository represents another piece of that environment.

The lab isn't intended to be a collection of disconnected tutorials. The pieces are meant to eventually fit together into one functioning Azure environment.

---

# Lab Architecture

The environment is organized around six major areas:

```text
                         ┌─────────────────────┐
                         │       Identity      │
                         │    & Governance     │
                         └──────────┬──────────┘
                                    │
                                    ▼
┌──────────────┐          ┌─────────────────────┐          ┌──────────────┐
│  Networking  │◄────────►│      Compute       │◄────────►│   Storage    │
└──────────────┘          └──────────┬──────────┘          └──────────────┘
                                     │
                                     ▼
                           ┌─────────────────────┐
                           │     Monitoring      │
                           └─────────────────────┘
```

The objective is to eventually have these components interact rather than existing as isolated exercises.

---

# Repository Structure

```text
Azure_Lab/
│
├── Identity-Governance/
│   └── Identity, RBAC, Azure Policy, governance
│
├── Storage/
│   └── Storage accounts, blobs, files, redundancy, security
│
├── Compute/
│   └── Virtual machines and Azure compute services
│
├── Networking/
│   └── VNets, subnets, NSGs, DNS, connectivity
│
├── Monitoring/
│   └── Azure Monitor, Log Analytics, alerts, diagnostics
│
└── README.md
```

Each directory will contain the labs, notes, commands, configurations, and lessons learned associated with that area.

---

# 01 — Identity & Governance

**Question: Who are you, and what are you allowed to do?**

This section focuses heavily on the administrative and security side of Azure.

I'll use it to build an understanding of:

* Microsoft Entra ID
* Users and groups
* Role-Based Access Control (RBAC)
* Azure subscriptions
* Management groups
* Resource groups
* Azure Policy
* Resource locks
* Managed identities
* Administrative roles
* Authentication and authorization
* Governance and compliance

The goal is to understand the difference between:

> **Authentication — "Who are you?"**

and

> **Authorization — "What are you allowed to do?"**

This area is especially important for **SC-500**, but it also forms the foundation for administering Azure effectively.

---

# 02 — Storage

**Question: Where does the data live?**

Azure provides several ways to store data, and choosing the right option requires understanding what the workload actually needs.

This section will cover areas such as:

* Storage accounts
* Blob storage
* Azure Files
* File shares
* Storage tiers
* Redundancy
* Access keys
* Shared access signatures (SAS)
* Storage security
* Lifecycle management
* Data protection
* Replication

The objective isn't simply to create a storage account.

It's to understand **why one storage configuration would be appropriate over another.**

---

# 03 — Compute

**Question: Where does the workload run?**

This section focuses on Azure compute and the administration of workloads.

Topics will include:

* Azure Virtual Machines
* VM sizing
* Disks
* Images
* Availability options
* VM networking
* Extensions
* Managed identities
* Scaling
* VM administration
* Infrastructure deployment

My existing Windows Server and Active Directory lab provides a useful foundation here.

The Azure lab takes those concepts and moves them into the cloud.

---

# 04 — Networking

**Question: How does everything communicate?**

Networking is where the different parts of the environment start becoming an actual environment.

This section will focus on:

* Virtual networks (VNets)
* Subnets
* IP addressing
* Network Security Groups (NSGs)
* Network interfaces
* Private and public IP addresses
* DNS
* Routing
* VNet peering
* VPN concepts
* Azure Load Balancer
* Network troubleshooting

The goal is to stop thinking about Azure resources individually and start thinking about **traffic flows**.

For example:

```text
User
 │
 ▼
Public Endpoint
 │
 ▼
Network
 │
 ▼
Subnet
 │
 ▼
NSG
 │
 ▼
Workload
 │
 ▼
Storage / Database / Service
```

If something doesn't work, I want to be able to reason through the path instead of guessing.

---

# 05 — Monitoring

**Question: How do I know what's happening?**

An administrator shouldn't have to wait for someone to say:

> "Something is broken."

This section focuses on visibility and troubleshooting.

Topics will include:

* Azure Monitor
* Log Analytics
* Metrics
* Logs
* Activity logs
* Diagnostic settings
* Alerts
* Workbooks
* Queries
* Resource health
* Monitoring VM performance
* Troubleshooting failed deployments and resources

The goal is to develop the habit of asking:

**What does Azure know about this problem?**

before immediately changing things.

---

# The Security Thread

Although the repository is divided into separate sections, security runs through the entire lab.

Identity affects compute.

Networking affects security.

Storage permissions affect data protection.

Monitoring provides visibility.

Governance controls what can be deployed and how.

So instead of treating SC-500 as a completely separate subject, I'm using this lab to understand how **security and administration overlap.**

```text
                 SECURITY
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
    Identity    Networking    Data
        │           │           │
        └───────────┼───────────┘
                    ▼
                 Compute
                    │
                    ▼
               Monitoring
                    │
                    ▼
              Governance
```

---

# How I Build

I want this lab to reflect how infrastructure is actually managed rather than relying exclusively on the Portal.

Whenever practical, I'll approach resources through multiple interfaces:

```text
Azure Portal
     │
     ├── Azure CLI
     │
     ├── PowerShell
     │
     └── Bicep
```

The Portal helps me **see** Azure.

The CLI and PowerShell help me **operate** Azure.

Bicep helps me **define and reproduce** Azure infrastructure.

The long-term goal is to become comfortable moving between all four.

---

# Lab Philosophy

### Don't just follow the tutorial.

If I create something, I want to know:

* What did I create?
* Why did I create it?
* Where does it live?
* What depends on it?
* Who can access it?
* How does traffic reach it?
* What happens if I delete it?
* How would I troubleshoot it?
* How would I recreate it?

### Break things intentionally.

A lab that never breaks teaches very little about troubleshooting.

When appropriate, I'll deliberately change configurations, remove permissions, modify networking, stop resources, and introduce problems.

Then I'll troubleshoot them.

### Document the lesson, not just the command.

A command tells me **what I typed**.

A good lab note should also explain **what the command actually did**.

---

# Certification Targets

## AZ-104 — Azure Administrator

The lab will reinforce the major administrator skill areas:

* Manage Azure identities and governance
* Implement and manage storage
* Deploy and manage Azure compute resources
* Configure and manage virtual networking
* Monitor and maintain Azure resources

## SC-500 — Identity and Access Administrator

The lab will reinforce areas including:

* Microsoft Entra ID
* Identity lifecycle
* Authentication
* Authorization
* RBAC
* Identity governance
* Access management
* Administrative roles
* Security controls
* Monitoring and troubleshooting identity-related activity

The certifications are the target.

**The lab is the training ground.**

---

# What "Done" Looks Like

This lab is not finished when every folder contains a few commands.

It's finished when I can look at an Azure environment and explain:

> **What is here, why it exists, who can access it, how it communicates, how it is secured, how it is monitored, and how I would rebuild it.**

Eventually, I want to be able to tear down significant portions of the environment and recreate them from code.

That is the point where the lab stops being a collection of certification exercises and starts looking like infrastructure engineering.

---

# Learning Log

I'll use the individual directories to document:

* Labs completed
* Commands used
* Architecture decisions
* Problems encountered
* Troubleshooting steps
* Important concepts
* Exam-relevant notes
* Lessons learned

When something breaks, the troubleshooting process is part of the lab — not an inconvenience to hide.

---

# The End Goal

This repository represents the transition from:

```text
"I know how to configure it."
```

to:

```text
"I understand why it works."
```

and eventually:

```text
"I can build, secure, troubleshoot, and reproduce it."
```

**AZ-104 and SC-500 are the milestones.**

**The real objective is becoming a capable Azure administrator who understands the infrastructure underneath the certification questions.**
