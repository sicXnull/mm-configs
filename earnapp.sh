#!/bin/bash

generate_md5sum() {
    echo -n "$1" | md5sum | awk '{ print $1 }'
}

RANDOM_STRING=$(date +%s | sha256sum | base64 | head -c 32)
MD5SUM=$(generate_md5sum "$RANDOM_STRING")
EARNAPP_DEVICE_ID="sdk-node-$MD5SUM"

echo "Generated EARNAPP_DEVICE_ID: $EARNAPP_DEVICE_ID"

docker run -d --name earnapp \
    --restart always \
    -v earnapp-data:/etc/earnapp \
    --env EARNAPP_UUID=$EARNAPP_DEVICE_ID \
    --network host \
    fazalfarhan01/earnapp:lite

echo "Docker container 'earnapp' started with EARNAPP_DEVICE_ID: $EARNAPP_DEVICE_ID"
