sudo docker run -d \
        --name=flight-review \
        --restart=always \
        --network=host \
        -e PORT=80 \
        -e BOKEH_ALLOW_WS_ORIGIN=flight-review.modalai.com \
        -v `pwd`/data:/opt/service/data \
        px4flightreview

