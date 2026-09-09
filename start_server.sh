#store logs locally
#LOG_STORAGE_PATH=`pwd`/data

#store logs in the google bucket
LOG_STORAGE_PATH=`pwd`/bucket

# The app listens on 5006 behind Caddy (see ops/Caddyfile), which serves
# HTTPS on 443 and redirects HTTP. USE_PROXY makes the app trust the
# X-Forwarded-* headers so websocket URLs come out as wss://.
sudo docker run -d \
        --name=flight-review \
        --restart=always \
        --network=host \
        -e PORT=5006 \
        -e USE_PROXY=1 \
        -e DOMAIN=flight-review.modalai.com \
        -e BOKEH_ALLOW_WS_ORIGIN=flight-review.modalai.com \
        -v $LOG_STORAGE_PATH:/opt/service/data \
        px4flightreview

