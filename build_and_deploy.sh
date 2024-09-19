#!/bin/bash
#Exit immediately on error
set -e

source ./env

# Set script vars
DOCKER_TAG="postgres"
HOST=$DB_IP

echo "Setting permissions"
ssh "$PI_USER@$HOST" "sudo mkdir /var/lib/postgres" || true
ssh "$PI_USER@$HOST" "sudo chown 70:70 /var/lib/postgres"

echo "Setting builder to default"
docker buildx use default

echo "Building target for arm64"
docker buildx build --platform linux/arm64 -t $DOCKER_TAG . --load

echo "Stopping old container"
ssh "$PI_USER@$HOST" "docker stop $DOCKER_TAG " || true

echo "Removing old container"
ssh "$PI_USER@$HOST" "docker container rm $DOCKER_TAG " || true

echo "Pushing new image"
docker save $DOCKER_TAG | bzip2 | ssh -l $PI_USER $HOST docker load

echo "Starting Container"
ssh "$PI_USER@$HOST" "docker run -d -e POSTGRES_DB=$POSTGRES_DB -e POSTGRES_USER=$POSTGRES_USER -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD --network host -v /var/lib/postgres:/var/lib/postgresql/data --restart unless-stopped --name $DOCKER_TAG \"$DOCKER_TAG\""

echo "Removing dangling images"
ssh "$PI_USER@$HOST" 'docker image rm $(docker images -f "dangling=true" -q)'
