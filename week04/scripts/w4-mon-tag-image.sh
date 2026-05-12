#!/bin/bash
set -euo pipefail

echo "=== Building and pushing vote ==="

SERVER=$(az acr show \
  --name acrdevopsevolutiondev \
  --query loginServer \
  --output tsv)

APP="vote"
VERSION="0.1.0"

COMMIT=$(git rev-parse --short HEAD)

TAG="${VERSION}-${COMMIT}"

IMAGE="${SERVER}/${APP}:${TAG}"

echo "Tag: $IMAGE"
echo ""

echo "Logging into ACR..."
az acr login --name acrdevopsevolutiondev

echo ""

cd /Users/kiran/DevOps/example-voting-app/vote
echo "Building"
docker build -t "$IMAGE" .

echo ""

echo "Pushing"
docker push "$IMAGE"

echo ""

echo "=== Done ==="
echo "Image: $IMAGE"



# === Building and pushing vote ===
# Tag: acrdevopsevolutiondev.azurecr.io/vote:v0.1.0-a3f9c2d

# Logging into ACR...
# Building...
# Pushing...

# === Done ===
# Image: acrdevopsevolutiondev.azurecr.io/vote:v0.1.0-a3f9c2d