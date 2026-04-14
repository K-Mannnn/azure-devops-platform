# Progress Journal

## Pre-Programme — Starting State

**Date:** [23.03.2026]

**Current skills:**
- Docker: Have basic knowldege and have deployed once using docker, docker compose in a home lab set up.
- Git/GitHub: Comfortable
- Linux: basic — can navigate, edit files, need to dig bit deeper how processes etc. work and what linux features make containers possible. 
- Azure: have used portal, understand basics, touched some services including app service.
- Terraform: seen it, not written it from scratch, undersand the syntax when I read it. Need to understand Terraform state etc. and Terraform in general on a deeper level. 
- Kubernetes: aware of concepts, have deployed once ina home lab set up. 
- CI/CD: understand the concept, have built basic pipelines in Azure DevOps. 
- Bash scripting: basic

**Why I am doing this:**
Bceoming a DevOps Engineer has been a dream for past couple of years, during this period I have researched the DevOps ecosystem enough that I understand what different tools, technologies, platforms exist and what stage they're used at. What I still need develop a deeper undestanding of is what tools and technologies solve what problem and when to use which one over others. How systems behave under stress and develop a solid approach to troubleshooting complex infrstructure. 

Have learned from various resources and now its time to get some practical experience under the belt. The structure of this course is my own design, I don't just want to learn  various tools but the way I have structured this programme is how technologies evolved hostrocially, and what pain points each resolved to bring us to present day. 

**Target role:**
DevOps / Cloud / Platform Engineer
MSPs first, enterprise long-term
Outside London | £40-55k first role

**Timeline:**
The programme has 36 weeks curriculum but it can take longer or faster. Key is to build — solid foundations over speed. 

**What I am most nervous about:**
I have devloped a very comprehensive list of things to do over 36 weeks. including 5 days a week (2- 3 hours per day). Have also included different challenges such as daily bash challenge, learning about Azure portal to prepare for AZ-104 along the way. So it will be challenging and showing up daily may not be possible along with full time job. 

**What I am most looking forward to:**
To work on production grade scenarios, and solve more real life problems as the project grows. 


***********************************************************
***********************************************************

# Progress

## Week 1 — Bare Metal to Containers
**Completed:** [date]

### What I built
- Linux VM on Azure provisioned via CLI
- Voting app running manually and as a systemd service
- NSG and ufw rules configured and tested
- Three Bash scripts: system state, health check, auto-deallocate
- Runbook, snowflake doc, networking layers doc, ADR 001

### What I understand now that I didn't before
- Difference between manually running an app on a VM and systemd managing it
- How to SSH securely to a cloud VM
- How to manage SSH keys
- Networking layers and connection between different cloud components such as the application, ufw, NSG. 
- How to diagnose and troubleshoot app not running from inside out
- Basics of bash scripting, template, conditions, how to run it remotely, changing permissions to script file.
- some Linux concepts such as difference between SIGTERM and SIGKILL and commands such as  ss -tlnp, ps aux, pgrep, journalctl.
- Some Aure CLI commands to understand VM state and extract data from them. 
- To run az commands on a VM in Azure, you have to install Azure CLI on it even though its already running in Azure. 


### What still confuses me
- Need to understand Networking on more deeper level, especially Azure Vnet etc. 
- Linux is an abyss, there's so much that goes under the hood that I'd like to develop a thorough understanding of. 
- Azure CLI commands seem to have some limitations in terms of what information can be extracted. 
- Seems like I haven't even scratched the surface with Bash Scripting. 


## Week 2 - ## Week 2 — Azure Networking Done Right
**Completed:** 14/04/2026

### What I built
- Azure organisational hierarchy understood — tenant to resource
- Three resource groups by lifecycle — networking, compute, data
- VNet with four subnets — CIDR calculated manually
- NSGs with network segmentation — data layer unreachable from internet
- Private DNS Zone with auto-registration
- Private Endpoint for storage — no public access
- Azure Bastion — SSH without public IPs
- Log Analytics Workspace with diagnostic settings
- KQL queries for NSG denies, CPU alerts, failed auth
- CPU alert rule firing on threshold

### What I understand now that I didn't before
- Azure DNS settings
- CIDR notations and how to calculate subnets
- How to convert IP addresses to integers and other way around
- How to set up bastion and its uses etc. 
- Azure monitoring - its components and uses. 
- Mathematical calucaltions in bash scripting

### What still confuses me
- This week was another layer of networking uncovered i.e. DNS, Subnets etc. but still a lot more to it. 
- Although touched a bit of monitoring but running some basic KQL queries unveiled the depth of Azure monitoring and how much more there is to it. 
- The connection between subnets, resource groups, NSGs etc. there were instances this week where incorrect NSG were applied to resources, and resources from different resource groups were unable to communicate efficiently due to incorrect rules set.  
