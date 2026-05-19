### W5D1 - Day 1 Docker from First Principles — What a Container Actually Is

- Prove a container is just a process

# Run nginx in a container
docker run -d --name mynginx nginx

# Now look at the HOST process table
ps aux | grep nginx

- Key observation: 
nginx that's running inside a container is still showing up in host process list. Hence proves a container is just a linux process. 

# See the container from Docker's perspective
docker ps

Just shows nginx running anf no other processes. 

# See the container's PID namespace
docker inspect mynginx --format '{{.State.Pid}}'

- Returns the host PID of the container's init process

# What does docker stop mynginx actually do

docker stop mynginx

- Sends SIGTERM to container's PID 1, essentially stopping the container. 

- So Docker always targets: the PID 1 process of the container namespace, 

- no PID 1 = no container


# Pitfall test: 

# Run nginx and write a file inside it:
docker run -d --name test-ephemeral nginx
docker exec test-ephemeral bash -c "echo 'important data' > /tmp/myfile.txt"
docker exec test-ephemeral cat /tmp/myfile.txt  

- it's there

# Now delete and recreate
docker rm -f test-ephemeral
docker run -d --name test-ephemeral nginx
docker exec test-ephemeral cat /tmp/myfile.txt  

- gone

