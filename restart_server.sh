#!/bin/bash

set -e -x
for NAME in flight-review flight-review-upload flight-review-plot-2 flight-review-plot-3; do
	CONTAINER_ID=`sudo docker ps -a -q --filter="name=^${NAME}$"`
	if [ -z "$CONTAINER_ID" ]; then continue; fi

	echo "Found $NAME container id $CONTAINER_ID"

	echo "Disabling container auto restart"
	sudo docker update --restart=no $CONTAINER_ID

	echo "Stopping container"
	sudo docker stop $CONTAINER_ID

	echo "Removing container"
	sudo docker rm $CONTAINER_ID
done

echo "Starting new containers"
sudo ./start_server.sh
