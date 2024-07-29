#!/bin/bash

# Function to display script usage
usage() {
    echo "Usage: sudo $0 -privkey <private_key> -contract <contract_address>"
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
        -privkey)
        privkey="$2"
        shift
        shift
        ;;
        -contract)
        contract="$2"
        shift
        shift
        ;;
        *)
        usage
        ;;
    esac
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
sudo mkdir -p "$storage_dir"
sudo mkdir -p "$storage_dir/config"
sudo chmod 777 -R "$storage_dir"

# Create the JSON configuration file only if it doesn't exist
if [ ! -f "$storage_dir/.streamr/config/default.json" ]; then
    cat <<EOF | sudo tee "$storage_dir/.streamr/config/default.json" >/dev/null
{
    "client": {
        "auth": {
            "privateKey": "$privkey"
        },
        "environment": "polygonAmoy"
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

# Stop and remove any existing Streamr container
sudo docker stop streamr >/dev/null 2>&1
sudo docker rm streamr >/dev/null 2>&1

# Run Docker container with Streamr
sudo docker run -p 32200:32200 --name streamr --restart unless-stopped -d -v "$storage_dir/.streamr:/home/streamr/.streamr" streamr/node

echo "Streamr Docker container started."
