# The Snowflake Problem

## What I built on VM1
* An azure VM (Ubuntu) based in WestUs region as I only had quota for basic Bpvs2 VMs under my sunscription. 


## What was different on VM2
* I did not remember the exact name of the VM I created on VM1 as quota is specific to 1 type of VMs. Also the the ARM64 based Ubuntu image was not compatible to create the VM. 

* Also security type on the VM had to be set to standard for it to be created, 


## What broke and how long it took to fix
* Couldn't remember which SSH key to use
* pip flag didn't work on this VM version
* Port hardcoded in app.py — had to find and fix it each time
* NSG blocking port 80, then port 5000 — had to remember to open it
* sudo vs user Python environment — Flask not found until reinstalled under root
* Had to check the runbook each time to remember the exact az vm create flags

## Time to recover per session
* Approximately 45-60 minutes each time with the runbook.
* Without the runbook: unknown — potentially hours.

## What would happen if production died tonight
* Recovery depends entirely on one markdown file and one person's memory.
* No automated verification that the rebuild matches the original.
* No way to know what packages are installed at what versions.
* No guaranteed reproducibility.