#!/bin/bash
#Exit immediately on error
set -e

# Set script vars
DOCKER_TAG="postgres"

echo "Building target for arm64"
docker buildx build --platform linux/arm64 -t $DOCKER_TAG .

echo "Stopping old container"
ssh "$PI_USER@$PI_IP" "docker stop $DOCKER_TAG " || true

echo "Removing old container"
ssh "$PI_USER@$PI_IP" "docker container rm $DOCKER_TAG " || true

# echo "Removing old image"
# ssh "$PI_USER@$PI_IP" "docker image rm $DOCKER_TAG " || true

echo "Pushing new image"
docker save $DOCKER_TAG | bzip2 | ssh -l $PI_USER $PI_IP docker load

echo "Starting Container"
ssh "$PI_USER@$PI_IP" "docker run -d --network host --restart unless-stopped --name $DOCKER_TAG \"$DOCKER_TAG\""
