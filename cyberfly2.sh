#!/bin/bash

# Default values
KADENA_ACCOUNT=""
NODE_PRIV_KEY=""

# Function to display usage
usage() {
  echo "Usage: $0 --kadena_account=<KADENA_ACCOUNT> --node_priv_key=<NODE_PRIV_KEY>"
  exit 1
}

# Parse command-line arguments
for arg in "$@"
do
  case $arg in
    --kadena_account=*)
      KADENA_ACCOUNT="${arg#*=}"
      shift
      ;;
    --node_priv_key=*)
      NODE_PRIV_KEY="${arg#*=}"
      shift
      ;;
    *)
      usage
      ;;
  esac
done

# Validate inputs
if [[ -z "$KADENA_ACCOUNT" || -z "$NODE_PRIV_KEY" ]]; then
  echo "Error: Both --kadena_account and --node_priv_key must be provided."
  usage
fi

# Determine volumes path
if test -f /etc/crankk.conf; then
  DATA_PATH="/data/cyberfly"
else
  DATA_PATH="/opt/cyberfly"
fi

# Ensure DATA_PATH exists
mkdir -p "$DATA_PATH"

# Generate docker-compose.yml
bash -c "cat <<EOF > \"$DATA_PATH/docker-compose.yml\"
version: '3.8'

services:
  cyberflynodeui:
    image: \"cyberfly/cyberfly_node_ui:latest\"
    restart: always
    ports:
      - \"31000:80\" #nginx server port
    depends_on:
      - cyberflynode
    labels:
      - \"com.centurylinklabs.watchtower.enable=true\"

  cyberflynode:
    image: \"cyberfly/cyberfly_node:latest\"
    restart: always
    ports:
      - \"31001:31001\" #libp2p tcp port
      - \"31002:31002\" #libp2p websocket port
      - \"31003:31003\" #Cyberfly api port
    volumes:
      - ${DATA_PATH}/data:/usr/src/app/data
    environment:
      - KADENA_ACCOUNT=${KADENA_ACCOUNT}
      - NODE_PRIV_KEY=${NODE_PRIV_KEY}
      - MQTT_HOST=mqtt://cyberflymqtt
      - REDIS_HOST=redisstackserver
    depends_on:
      - cyberflymqtt
      - redisstackserver
    labels:
      - \"com.centurylinklabs.watchtower.enable=true\"

  cyberflymqtt:
    image: \"cyberfly/cyberfly_mqtt:latest\"
    restart: always
    ports:
      - \"31004:1883\" #mqtt tcp port
      - \"31005:9001\" #mqtt websocket port
    labels:
      - \"com.centurylinklabs.watchtower.enable=true\"

  redisstackserver:
    image: \"redis:8.0-M02-alpine3.20\"
    restart: always
    volumes:
      - ${DATA_PATH}/redis-data:/data
    labels:
      - \"com.centurylinklabs.watchtower.enable=true\"
EOF"

# Start the container
docker-compose -f "$DATA_PATH/docker-compose.yml" up -d

# Notify user
echo "docker-compose.yml has been generated and the containers have been started successfully in $DATA_PATH."
