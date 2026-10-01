#store logs locally
#LOG_STORAGE_PATH=`pwd`/data

#store logs in the google bucket
LOG_STORAGE_PATH=`pwd`/bucket

# Local disk for the DB and for new uploads before they reach the bucket:
# sqlite on the bucket mount takes most of a second per commit, and a log
# takes seconds to write there.
LOCAL_PATH=/var/lib/flight-review
sudo mkdir -p $LOCAL_PATH/staging
sudo chown 1000:1001 $LOCAL_PATH $LOCAL_PATH/staging

# Both containers listen behind Caddy (see ops/Caddyfile), which serves HTTPS
# on 443 and redirects HTTP. USE_PROXY makes the app trust the X-Forwarded-*
# headers so websocket URLs come out as wss://.
#
# flight-review (port 5006) serves the pages and plots; flight-review-upload
# (port 5007) takes the upload POSTs, so uploads never wait behind a plot.
for ROLE in main upload; do
	if [ $ROLE = main ]; then NAME=flight-review; PORT=5006; PROCS=1
	else NAME=flight-review-upload; PORT=5007; PROCS=2; fi
	sudo docker run -d \
		--name=$NAME \
		--restart=always \
		--network=host \
		-e ROLE=$ROLE \
		-e PORT=$PORT \
		-e NUM_PROCS=$PROCS \
		-e USE_PROXY=1 \
		-e DOMAIN=flight-review.modalai.com \
		-e BOKEH_ALLOW_WS_ORIGIN=flight-review.modalai.com \
		-e FLIGHT_REVIEW_DB=/opt/service/local/logs.sqlite \
		-e FLIGHT_REVIEW_STAGING=/opt/service/local/staging \
		-v $LOG_STORAGE_PATH:/opt/service/data \
		-v $LOCAL_PATH:/opt/service/local \
		px4flightreview
done
