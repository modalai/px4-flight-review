CONTAINERS="flight-review flight-review-upload flight-review-plot-2 flight-review-plot-3"

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
# flight-review (port 5006) serves the pages and plots and keeps the DB backed
# up; flight-review-plot-2/3 (5008, 5009) serve pages and plots too, so one
# slow plot does not hold up the others (Caddy keeps each browser on one of
# them); flight-review-upload (port 5007) takes the upload POSTs, so uploads
# never wait behind a plot.
for NAME in $CONTAINERS; do
	case $NAME in
	flight-review) ROLE=main; PORT=5006; PROCS=1 ;;
	flight-review-upload) ROLE=upload; PORT=5007; PROCS=2 ;;
	flight-review-plot-2) ROLE=plot; PORT=5008; PROCS=1 ;;
	flight-review-plot-3) ROLE=plot; PORT=5009; PROCS=1 ;;
	esac
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
