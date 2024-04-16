#!/bin/bash
#Exit immediately on error
set -e

source ./env

# Set script vars
DOCKER_TAG="postgres"

echo "Setting permissions"
ssh "$PI_USER@$PI_IP" "sudo mkdir /var/lib/postgres"
ssh "$PI_USER@$PI_IP" "sudo chown 70:70 /var/lib/postgres"

echo "Building target for arm64"
docker buildx build --platform linux/arm64 -t $DOCKER_TAG .

echo "Stopping old container"
ssh "$PI_USER@$PI_IP" "docker stop $DOCKER_TAG " || true

echo "Removing old container"
ssh "$PI_USER@$PI_IP" "docker container rm $DOCKER_TAG " || true

echo "Grabbing current image id"
OLD_IMAGE=$(ssh "$PI_USER@$PI_IP" "docker images --filter=reference='postgres' --format '{{.ID}}'")
echo $OLD_IMAGE

echo "Pushing new image"
docker save $DOCKER_TAG | bzip2 | ssh -l $PI_USER $PI_IP docker load

echo "Starting Container"
ssh "$PI_USER@$PI_IP" "docker run -d -e POSTGRES_DB=$POSTGRES_DB -e POSTGRES_USER=$POSTGRES_USER -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD --network host -v /var/lib/postgres:/var/lib/postgresql/data --restart unless-stopped --name $DOCKER_TAG \"$DOCKER_TAG\""

if [ -n "$OLD_IMAGE" ]; then
  echo "Removing old image"
  ssh "$PI_USER@$PI_IP" "docker image rm $OLD_IMAGE " || true
fi