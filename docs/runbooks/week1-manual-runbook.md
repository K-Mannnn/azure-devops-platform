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




# Week 1 — Manual Infrastructure Runbook

## Day 2 — Linux as Your Cockpit

### Process Management
```bash
ssh -i ~/.ssh/<private-key> <username>@<ip-address>
```
SSH into the VM.
```bash
sudo python3 app.py
```
Starts the Flask voting app manually. Requires sudo — port 80 needs root.

---

#### The Redis Error
Running the vote service standalone throws:
`redis.exceptions.ConnectionError: redis:6379 — Temporary failure in name resolution`

**Root cause:** App expects a Docker network where `redis` resolves to a container.
On a bare VM, no Redis is running and no DNS exists for service names.
**Fix in Week 2:** `docker compose` brings all services up together on a shared network.

---
```bash
ps aux
```
Snapshot of all running processes — owner, PID, CPU%, memory%, command.
Useful for spotting resource hogs, background daemons, and debugging.
```bash
ps aux | grep [p]ython3
```
Filters for Python processes only. The `[p]` bracket trick stops grep matching itself.
```bash
sudo kill -SIGTERM <PID>
```
Graceful stop — asks the process to finish in-flight operations before exiting.
Well-behaved processes close sockets, flush logs, clean up files.
Note: no visible difference from SIGKILL on this simple Flask app — Flask doesn't
explicitly handle SIGTERM. On a database or stateful app the difference is critical.
```bash
sudo kill -SIGKILL <PID>
```
Immediate kill — no cleanup, no warning. OS terminates the process instantly.
Use only when SIGTERM fails or the process is unresponsive.

---

### Filesystem
```bash
find /var/log -name '*.log' -mtime -1
```
All log files modified in the last 24 hours. Useful for knowing where to look
during an incident without tailing everything.
```bash
du -sh /var/log/*
```
Size of each log directory. First place to look when disk is filling up.
```bash
df -h
```
Disk space per filesystem. `du` = how much space files use. `df` = how much
space is left. They answer different questions — check `df` first in any incident.

---

### Log Inspection
```bash
tail -f /var/log/syslog
```
Live system log feed. Opened a second SSH terminal and ran commands —
watched activity appear in real time in the first terminal.
```bash
journalctl -f
```
systemd's live journal. More structured than syslog — better filtering
and scoped to specific services. Preferred over syslog for service debugging.
```bash
grep -i error /var/log/syslog | tail -50
```
Last 50 error lines from syslog. `-i` = case-insensitive.
Pipe to `tail -50` so you see the most recent errors, not ones from weeks ago.

---

### Network
```bash
ss -tlnp
```
All listening ports with process names. Confirmed Flask on port 5000 after
service file fix.
```bash
netstat -rn
```
Routing table — how the system decides where to send network traffic.
```bash
curl -v http://localhost:5000
```
Tests the Flask endpoint with full request/response headers.
`-v` (verbose) shows the full HTTP conversation — useful for debugging
connection issues beyond just "does it respond."

---

### systemd Service File

Created `/etc/systemd/system/voting-app.service` to keep the app running
automatically and survive reboots.
```ini
[Unit]
Description=Voting App — Flask Frontend
After=network.target

[Service]
User=azureuser
WorkingDirectory=/home/azureuser/example-voting-app/vote
Environment="FLASK_RUN_PORT=5000"
ExecStart=/usr/bin/python3 app.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

#### Issue — Port hardcoded in app.py
`FLASK_RUN_PORT` environment variable was ignored because port 80 is hardcoded
in `app.py`. Diagnosed with:
```bash
grep -i port ~/example-voting-app/vote/app.py
```

Fixed by editing `app.py` directly:
```python
# Before
app.run(host='0.0.0.0', port=80, debug=True, threaded=True)
# After
app.run(host='0.0.0.0', port=5000, debug=True, threaded=True)
```

**Week 2 note:** Docker handles this cleanly via environment variables in the
compose file — no hardcoded ports needed.
```bash
sudo systemctl daemon-reload
sudo systemctl restart voting-app
sudo systemctl status voting-app
```
Reloaded config and restarted. Service showing `active (running)`.

---

### Resilience Tests
```bash
sudo kill -SIGKILL <PID>
sleep 6
sudo systemctl status voting-app
```
Killed the process — systemd restarted it automatically with a new PID.
`RestartSec=5` means it waits 5 seconds before restarting.
```bash
sudo reboot
# wait 60 seconds, SSH back in
sudo systemctl status voting-app
curl http://localhost:5000
```
App survived reboot. systemd started it automatically on boot — no manual
intervention needed.

**This is the concept behind Kubernetes Deployments in Act 3 — same behaviour,
higher abstraction. When you write your first Deployment manifest you'll
recognise exactly what it replaces.**

---

### Deferred to Wednesday Bash Challenge
- Health check script (`health-check.sh`) — checks process, port, HTTP response