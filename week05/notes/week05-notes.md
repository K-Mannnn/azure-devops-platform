### Week5 Day 1 - Docker

Docker is basically a polished interface around two Linux kernel features:

- Namespaces → isolation (“what a process can see”)
- cgroups → resource control (“what a process can use”)

Everything else in Docker builds on top of these.

# The Linux kernel provides 8 namespace types total:

* mnt (mount)
* pid
* net
* ipc
* uts
* user
* cgroup
* time

These are the base for containers as each namespace provides a type of system isolation. 

| Namespace     | What it isolates for containers                                                    |
| ------------- | ---------------------------------------------------------------------------------- |
| `mnt` (mount) | Gives the container its own filesystem mount view                                  |
| `pid`         | Gives the container its own process tree and PID numbering                         |
| `net`         | Gives the container its own network stack, interfaces, IPs, and ports              |
| `ipc`         | Isolates shared memory, semaphores, and message queues between containers          |
| `uts`         | Lets the container have its own hostname and domain name                           |
| `user`        | Maps container users/groups separately from the host (enables rootless containers) |
| `cgroup`      | Hides/virtualizes the cgroup hierarchy visible inside the container                |
| `time`        | Gives the container independent boot time and clock offsets                        |


- Namespaces do NOT limit resources. They only control: visibility and isolation

# Cgroups (Control Groups) are a Linux kernel feature for managing and limiting system resources per process group

They control resources like:

* CPU usage
* memory (RAM)
* disk I/O
* network bandwidth
* number of processes
* They prevent one container/process from consuming all host resources
* Containers use cgroups for resource quotas and accounting
* Unlike namespaces, cgroups do not isolate views of the system — they enforce resource limits and scheduling

# Summary: 

- A container is not a VM, not magic, not a black box — it's a Linux process with two kernel features applied to it: namespaces (restrict what it can see) and cgroups (restrict what it can use). Everything else Docker does is built on top of those two primitives.

- Understanding this means when a container misbehaves you debug it like a Linux process

## Important Docker commands (what they reveal)

### Container inspection
- `docker inspect ... NetworkSettings` → networking (IP, ports, bridge)
- `docker inspect ... Mounts` → filesystem mounts / volumes
- `docker inspect ... HostConfig.Resources` → CPU & memory limits (cgroups)
- `docker inspect ... State` → runtime state + host PID mapping

### Runtime monitoring
- `docker stats` → live CPU, memory, network, I/O usage (cgroup metrics)

### Image structure
- `docker history nginx` → shows image layers from Dockerfile instructions

### Inside container
- `docker run -it nginx bash` → enter isolated filesystem/process space

### Storage driver
- `mount | grep overlay` → confirms overlay filesystem (layered image system)

---

## Key takeaway
Containers are not lightweight VMs.

They are:
> Processes + namespaces (isolation) + cgroups (limits) + layered filesystem (images)

Everything in Docker builds from this foundation.