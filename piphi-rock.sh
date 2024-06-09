#!/bin/bash

# Download configuration files
wget -O /data/piphi.yml https://raw.githubusercontent.com/sicXnull/mm-configs/main/piphi-rock.yml

# clear old containers
docker stop piphi-network-image
docker stop db
docker stop grafana

docker rm piphi-network-image
docker rm db
docker rm grafana

# Start Docker container
docker-compose -f /data/piphi.yml up -d