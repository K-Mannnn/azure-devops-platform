# Week 1 — Manual Infrastructure Runbook

## Day 1 — Provision Linux VM on Azure by Hand
### Commands run

az group create \
  --name rg-devops-wus1 \
  --location westus

az vm create \
  --resource-group rg-devops-wus1 \
  --name vm-arm-b2pts-01 \
  --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-arm64:latest \
  --size Standard_B2pts_v2 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --security-type Standard
...


uname -a        
* confirms I'm on on ARM64 — incorrect image type was causing issues with VM creation. 

df -h           
* B1s/B2ps has ~30GB disk — about 6% has been used and rest is available

free -m         
* shows about 1GB total RAM is available and how much is already in use and availble for use.

top             
* CPU is almost 100% idle → VM is idle, no heavy workload, Memory is mostly in buff/cache → Linux caching disk, very normal, Only systemd and a few kernel threads are using RAM and CPU, No zombie or stuck processes → VM is healthy


cd ~
git clone https://github.com/dockersamples/example-voting-app.git
cd example-voting-app
ls

* clones the voting app from Github and checked its content. 

sudo apt update && sudo apt install -y git python3 python3-pip nodejs npm

* Installed system updates and installed app dependencies. 

python3 --version
* Python 3.10.12

node --version
* v12.22.9

npm --version
* 8.5.1

sudo pip3 install -r requirements.txt


sudo python3 app.py
 * Serving Flask app 'app'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:80
 * Running on http://10.0.0.5:80
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 857-236-534

### What I observed

http://<VM:PublicIP>
* Not reachable

### Fix

az vm open-port \
  --resource-group rg-devops-wus1 \
  --name vm-arm-b2pts-01 \
  --port 80

* NSG was blocking access to VM. cmd above opened port 80 and made it reachable from the internet. 


### What broke / decisions made

* The VM initially failed because the chosen size (Standard_B2pts_v2) only supports ARM64, but an x64 image was used.

* After switching to an ARM64 Ubuntu image, creation still failed due to Trusted Launch being enabled, which that VM size doesn’t support.

* SSH access failed because the VM’s public key came from Cloud Shell, not the local machine, so local keys didn’t match.

* Attempting to use the Cloud Shell private key failed until permissions were corrected (chmod 600).

* The issues were resolved by:
   Using a compatible ARM64 image
   Setting security type to Standard
   Either using the Cloud Shell private key with correct permissions or updating the VM    to accept the local public key.

* pip --break-system-packages flag not recognised
Older pip version on the VM didn't support the flag.
Fix: ran pip3 install -r requirements.txt without the flag, then --user when needed.

* Flask Permission denied on startup
Flask tries to bind to port 80, which requires root on Linux.
Fix: ran sudo python3 app.py

* ModuleNotFoundError: No module named 'flask'
sudo uses root's Python environment, which didn't have Flask installed — only the user's Python did.
Fix: ran sudo pip3 install -r requirements.txt to install under root.

* App not reachable in browser
Two parts — wrong protocol (https instead of http), and NSG blocking port 80.
Fix: used http:// and ran az vm open-port --port 80 to open the NSG rule.

## Day 2 — [topic]
### Commands run
...