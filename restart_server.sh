#!/bin/bash

set -e -x
CONTAINER_ID=`sudo docker ps -a -q --filter="name=flight-review"`

echo "Found flight review container id $CONTAINER_ID"

echo "Disabling container auto restart"
sudo docker update --restart=no $CONTAINER_ID

echo "Stopping container"
sudo docker stop $CONTAINER_ID

echo "Removing container"
sudo docker rm $CONTAINER_ID

echo "Staring a new container"
sudo ./start_server.sh

