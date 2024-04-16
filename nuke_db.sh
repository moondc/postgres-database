#!/bin/bash
#Exit immediately on error
set -e

echo "Are you sure? (y/n)"

read -r line

if [ "$line" = "y" ]; then
    ssh "$PI_USER@$PI_IP" "sudo chown -R $PI_USER:$PI_USER /var/lib/postgres"
    ssh "$PI_USER@$PI_IP" "sudo rm -R /var/lib/postgres"
fi


