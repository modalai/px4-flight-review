echo "open browser at http://localhost:5006/, and upload the log file for processing"

docker run -it --rm \
	--name=flight-review \
	--network=host \
	-e PORT=5006 \
	-v `pwd`/data:/opt/service/data \
	px4flightreview
