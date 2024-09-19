#!/bin/bash
#Exit immediately on error
set -e

echo "Are you sure? (y/n)"
HOST=$DB_IP

read -r line

if [ "$line" = "y" ]; then
    ssh "$PI_USER@$HOST" "sudo chown -R $PI_USER:$PI_USER /var/lib/postgres"
    ssh "$PI_USER@$HOST" "sudo rm -R /var/lib/postgres"
fi


