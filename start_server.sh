#store logs locally
#LOG_STORAGE_PATH=`pwd`/data

#store logs in the google bucket
LOG_STORAGE_PATH=`pwd`/bucket

sudo docker run -d \
        --name=flight-review \
        --restart=always \
        --network=host \
        -e PORT=80 \
        -e BOKEH_ALLOW_WS_ORIGIN=flight-review.modalai.com \
        -v $LOG_STORAGE_PATH:/opt/service/data \
        px4flightreview

