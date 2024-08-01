#!/bin/bash

# Function to display script usage
usage() {
    echo "Usage: $0 -privkey=<private_key> -contract=<contract_address>"
    exit 1
}

# Check if script is run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "Please run this script as root."
    exit 1
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -privkey=*)
            privkey="${key#*=}"
            ;;
        -contract=*)
            contract="${key#*=}"
            ;;
        *)
            usage
            ;;
    esac
    shift
done

# Check if required arguments are provided
if [ -z "$privkey" ] || [ -z "$contract" ]; then
    usage
fi

# Check if /etc/crankk.conf exists
if [ -f "/etc/crankk.conf" ]; then
    storage_dir="/data/streamr"
else
    storage_dir="/opt/streamr"
fi

# Create the directory if it doesn't exist
mkdir -p "$storage_dir/.streamr/config"

# Set permissions for directories
chmod -R 777 "$storage_dir"

# Create the JSON configuration file only if it doesn't exist
config_file="$storage_dir/.streamr/config/default.json"
if [ ! -f "$config_file" ]; then
    cat <<EOF | tee "$config_file" >/dev/null
{
    "\$schema": "https://schema.streamr.network/config-v3.schema.json",
    "client": {
        "auth": {
            "privateKey": "$privkey"
        },
        "environment": "polygon"
    },
    "plugins": {
        "operator": {
            "operatorContractAddress": "$contract"
        }
    }
}
EOF

    echo "Configuration file 'default.json' created successfully."
else
    echo "Configuration file 'default.json' already exists. Skipping creation."
fi

chmod 777 "$config_file"

# Stop and remove any existing Streamr container
if docker stop streamr >/dev/null 2>&1; then
    echo "Stopped existing Streamr container."
else
    echo "No existing Streamr container to stop."
fi

if docker rm streamr >/dev/null 2>&1; then
    echo "Removed existing Streamr container."
else
    echo "No existing Streamr container to remove."
fi

# Run Docker container with Streamr
if docker run -p 32200:32200 --name streamr --restart unless-stopped -d \
    -v "$storage_dir/.streamr:/home/streamr/.streamr" \
    --label com.centurylinklabs.watchtower.enable=true \
    streamr/node; then
    echo "Streamr Docker container started."
else
    echo "Failed to start Streamr Docker container."
fi
