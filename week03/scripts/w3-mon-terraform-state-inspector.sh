
#!/bin/bash
# W3 Bash Challenge — Monday
# Challenge: Terraform State Inspector script



if [ -z "$1" ]; then
  echo "Usage: ./w3-mon-tf-state-inspector.sh <path-to-tfstate>"
  exit 1
fi

TF=$1

if [ ! -f "$TF" ]; then
  echo "Error: state file not found: $TF"
  exit 1
fi

echo "=== Terraform State Inspector ==="
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "State file: $(basename $TF)"

echo ""

echo "--- Resources managed ---"
cat $TF | jq -r '.resources[] | "\(.type)\t\(.name)\t\(.instances[0].attributes.name)\t\(.instances[0].attributes.location)"' 

echo ""

echo "--- Summary ---"
echo "Total Resources: $(jq '.resources | length' "$TF")"
echo "--- Resource Type Counts ---"
jq -r '.resources[].type' "$TF" | sort | uniq -c | awk '{print $2 "\t" $1}'

echo ""
echo "=============================="