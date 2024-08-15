#!/bin/bash

generate_md5sum() {
    echo -n "$1" | md5sum | awk '{ print $1 }'
}

UUID_FILE="EARNAPP_DEVICE_ID"

# Check if the UUID file exists
if [[ -f "$UUID_FILE" ]]; then
    # Read the UUID from the file
    EARNAPP_DEVICE_ID=$(cat "$UUID_FILE")
    echo "Using existing EARNAPP_DEVICE_ID: $EARNAPP_DEVICE_ID"
else
    # Generate a new UUID and save it to the file
    RANDOM_STRING=$(date +%s | sha256sum | base64 | head -c 32)
    MD5SUM=$(generate_md5sum "$RANDOM_STRING")
    EARNAPP_DEVICE_ID="sdk-node-$MD5SUM"
    
    echo "Generated EARNAPP_DEVICE_ID: $EARNAPP_DEVICE_ID"
    echo "$EARNAPP_DEVICE_ID" > "$UUID_FILE"
fi

docker run -d --name earnapp \
    --restart always \
    -v earnapp-data:/etc/earnapp \
    --env EARNAPP_UUID=$EARNAPP_DEVICE_ID \
    --label com.centurylinklabs.watchtower.enable=true \
    --network host \
    fazalfarhan01/earnapp:lite

echo "Docker container 'earnapp' started with EARNAPP_DEVICE_ID: $EARNAPP_DEVICE_ID"
