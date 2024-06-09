#!/bin/bash

if [ ! -x /usr/bin/docker-compose ]; then
    echo "docker-compose not found. Installing..."
    # Download docker-compose
    sudo curl -L https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose
    # Set ownership to root
    sudo chown root: /usr/bin/docker-compose
    # Make it executable
    sudo chmod +x /usr/bin/docker-compose
    echo "docker-compose installed successfully."
else
    echo "docker-compose is already installed."
fi

# Download configuration files
wget -O /data/piphi.yml https://

# clear old containers
docker stop piphi-network-image
docker stop db
docker stop grafana

docker rm piphi-network-image
docker rm db
docker rm grafana

# Start Docker container
docker-compose -f /data/piphi.yml up -d