
#!/bin/bash
# subnet calculator


CIDR=$1                          
IP=$(echo $CIDR | cut -d'/' -f1) 
PREFIX=$(echo $CIDR | cut -d'/' -f2) 
Total=$((2**(32-PREFIX)))

# Convert dotted IP → 32-bit integer
# If an IP is A.B.C.D then the conversion formula is : 
# IPint ​= A×256^3 + B×256^2 +C×256^1+D×256^0 
# OR IPint ​= (A<<24)+(B<<16)+(C<<8)+D (this is more common in programming)
ip_to_int() {
  local IFS=.
  read -r o1 o2 o3 o4 <<< "$CIDR"
  echo $(( ((o1 << 24) + (o2 << 16) + (o3 << 8) + o4 )))
}

# Convert 32-bit integer → dotted IP

# Given a 32-bit integer N:
# A (1st octet) = (N >> 24) & 255
# B (2nd octet) = (N >> 16) & 255
# C (3rd octet) = (N >> 8) & 255
# D (4th octet) = N & 255
# So the IP becomes:A.B.C.D
int_to_ip() {
  local ip=$1
  echo "$(( (ip >> 24) & 255 )).$(( (ip >> 16) & 255 )).$(( (ip >> 8) & 255 )).$(( ip & 255 ))"
}


# run the ip_to_int function with the IP from the CIDR notation provided to get convert it into an integer value
ip_int=$(ip_to_int "$IP")

# Calculate the mask using equation below where 0FFFFFFFF = 11111111 11111111 11111111 11111111 and << (32-PREFIX) pushes 0s left. 
mask=$(( 0xFFFFFFFF << (32 - PREFIX) & 0xFFFFFFFF ))

# Convert the network ip into integer using ip_int value and AND it with mask.
network_int=$(( ip_int & mask ))

# convert the Broadcast ip integer value using network_int value above and OR it with mask inverted. trailing 0FFFFFFFF is just to keep it within 32 bits range. 
broadcast_int=$((network_int | ~mask & 0xFFFFFFFF ))

# Calculcate first ip in the range's integer value using network_int value and adding 1. 
first_ip_int=$(( network_int + 1))

# Calculate last ip in the range's integer value using broadcast_int value and subtracting 1.
last_ip_int=$((broadcast_int - 1))


# Desired script Output
echo "=== Subnet Calculator ==="

echo ""

echo "Input: $CIDR"

echo ""

echo "Network: $(int_to_ip $network_int)"
echo "Broadcast: $(int_to_ip $broadcast_int)"
echo "Host range: $(int_to_ip $first_ip_int) - $(int_to_ip $last_ip_int)"
echo "Usable hosts: $(( Total - 2 ))"
echo "Azure IPs:    $(( Total - 5 ))"











