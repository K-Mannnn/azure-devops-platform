
#!/bin/bash
# W2 Bash Challenge — Friday
# Challenge: DNS debug script

Host=$1

echo "=== DNS Debug: google.com ==="
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

echo  "--- nslookup ---"
 
Server=$(nslookup "$Host" | grep "Server" | awk '{print $2}')
echo  "Server: "$Server""


Address=$(nslookup "$Host" | grep -m 1 "Address" | awk '{print $2}')
echo  "Address: "$Address""

Name=$(nslookup "$Host" | grep -m 1 "Name" | awk '{print $2}')
echo  "Name: "$Name""

IPAddress=$(nslookup "$Host" | awk '/Non-authoritative answer:/ {found=1; next} found && /^Address:/ {print $2; exit}')
echo  "Address: "$IPAddress""


echo ""

echo "--- dig (short) ---"
dig +short $Host | head -n 1

echo ""
 
echo "--- resolution chain ---"
Resolver=$(dig $Host | awk -F': ' '/SERVER:/ {split($2,a,"#"); print a[1]}')
echo "Resolver: nameserver "$Resolver""

echo ""

echo "--- HTTP status ---"
curl -o /dev/null -s -w "%{http_code}\n" $Host

echo ""
 
echo "=== END ==="

