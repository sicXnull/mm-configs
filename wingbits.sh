#!/bin/bash

# Default values
DEFAULT_FEEDER_ALT_M=""
DEFAULT_FEEDER_LAT=""
DEFAULT_FEEDER_LONG=""
DEFAULT_FEEDER_TZ=""
DEFAULT_FEEDER_NAME=""
DEFAULT_ADSB_SDR_PPM=""
DEFAULT_READSB_GAIN=""
DEFAULT_WINGBITS_DEVICE_ID=""
DEFAULT_ENABLE_AIRSPY=""
DEFAULT_URL_AIRSPY=""
DEFAULT_SERIAL_DEVICE=""

# Function to parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --FEEDER_ALT_M=*)
                FEEDER_ALT_M="${1#*=}"
                ;;
            --FEEDER_LAT=*)
                FEEDER_LAT="${1#*=}"
                ;;
            --FEEDER_LONG=*)
                FEEDER_LONG="${1#*=}"
                ;;
            --FEEDER_TZ=*)
                FEEDER_TZ="${1#*=}"
                ;;
            --FEEDER_NAME=*)
                FEEDER_NAME="${1#*=}"
                ;;
            --ADSB_SDR_PPM=*)
                ADSB_SDR_PPM="${1#*=}"
                ;;
            --READSB_GAIN=*)
                READSB_GAIN="${1#*=}"
                ;;
            --WINGBITS_DEVICE_ID=*)
                WINGBITS_DEVICE_ID="${1#*=}"
                ;;
            --ENABLE_AIRSPY=*)
                ENABLE_AIRSPY="${1#*=}"
                ;;
            --URL_AIRSPY=*)
                URL_AIRSPY="${1#*=}"
                ;;
            --SERIAL_DEVICE=*)
                SERIAL_DEVICE="${1#*=}"
                ;;
            *)
                echo "Unknown parameter: $1"
                exit 1
                ;;
        esac
        shift
    done
}

# Function to create .env file
create_env_file() {
    # Use parameter expansion to use default values if variables are unset
    cat > .env << EOF
FEEDER_ALT_M=${FEEDER_ALT_M:-$DEFAULT_FEEDER_ALT_M}
FEEDER_LAT=${FEEDER_LAT:-$DEFAULT_FEEDER_LAT}
FEEDER_LONG=${FEEDER_LONG:-$DEFAULT_FEEDER_LONG}
FEEDER_TZ=${FEEDER_TZ:-$DEFAULT_FEEDER_TZ}
FEEDER_NAME=${FEEDER_NAME:-$DEFAULT_FEEDER_NAME}
ADSB_SDR_PPM=${ADSB_SDR_PPM:-$DEFAULT_ADSB_SDR_PPM}
READSB_GAIN=${READSB_GAIN:-$DEFAULT_READSB_GAIN}
WINGBITS_DEVICE_ID=${WINGBITS_DEVICE_ID:-$DEFAULT_WINGBITS_DEVICE_ID}
ENABLE_AIRSPY=${ENABLE_AIRSPY:-$DEFAULT_ENABLE_AIRSPY}
URL_AIRSPY=${URL_AIRSPY:-$DEFAULT_URL_AIRSPY}
SERIAL_DEVICE=${SERIAL_DEVICE:-$DEFAULT_SERIAL_DEVICE}
EOF
    echo ".env file created successfully"
}

# Main execution
parse_args "$@"
create_env_file

# Download docker-compose.yml
echo "Downloading docker-compose.yml..."
wget https://raw.githubusercontent.com/sicXnull/wingbits-ultrafeeder/refs/heads/main/docker-compose.yml

# Start the containers
echo "Starting docker containers..."
docker-compose up -d