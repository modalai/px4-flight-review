#!/bin/bash

PORT_VALUE=${PORT:-5006}
DOMAIN_VALUE=${DOMAIN:-*}
NUM_PROCS_VALUE=${NUM_PROCS:-1}

WORK_PATH=/opt/service
DATA_PATH=${WORK_PATH}/data
DB_PATH=${FLIGHT_REVIEW_DB:-${DATA_PATH}/logs.sqlite}

# app setup
if [ ! -d ${DATA_PATH} ]; then
	mkdir -p ${DATA_PATH}
fi
if [ -n "${FLIGHT_REVIEW_STAGING}" ]; then
	mkdir -p "${FLIGHT_REVIEW_STAGING}"
fi

if [ "${ROLE}" = "upload" ] || [ "${ROLE}" = "plot" ]; then
	# the main container creates or restores the DB: wait for it
	while [ ! -f ${DB_PATH} ]; do sleep 1; done
	if [ "${ROLE}" = "upload" ]; then
		python3 ${WORK_PATH}/store_staged_logs.py &
	fi
else
	if [ ! -f ${DB_PATH} ]; then
		if [ "${DB_PATH}" != "${DATA_PATH}/logs.sqlite" ] && [ -f ${DATA_PATH}/logs.sqlite ]; then
			mkdir -p "$(dirname ${DB_PATH})"
			sqlite3 ${DATA_PATH}/logs.sqlite ".backup ${DB_PATH}.tmp" && mv ${DB_PATH}.tmp ${DB_PATH}
		else
			python3 ${WORK_PATH}/setup_db.py
		fi
	fi
	if [ "${DB_PATH}" != "${DATA_PATH}/logs.sqlite" ]; then
		# keep a copy of the local DB in the storage path
		(while sleep ${DB_BACKUP_INTERVAL:-600}; do python3 ${WORK_PATH}/store_db_backup.py; done) &
	fi
fi

if [ -n "${USE_PROXY}" ]; then
	echo "Use Proxy!"
	python3 ${WORK_PATH}/serve.py \
		--port=${PORT_VALUE} \
		--address=0.0.0.0 \
		--num-procs=${NUM_PROCS_VALUE} \
		--allow-websocket-origin=${DOMAIN_VALUE} \
		--use-xheaders
else
	python3 ${WORK_PATH}/serve.py --port=${PORT_VALUE} --num-procs=${NUM_PROCS_VALUE}
fi
