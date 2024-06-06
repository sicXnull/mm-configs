#!/bin/bash

# Initialize variables
NICKNAME=""
EMAIL=""
ETH_ADDRESS=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --nickname=*)
            NICKNAME="${1#*=}"
            ;;
        --email=*)
            EMAIL="${1#*=}"
            ;;
        --eth-address=*)
            ETH_ADDRESS="${1#*=}"
            ;;
        *)
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
    shift
done

# Check if all required arguments are provided
if [[ -z $NICKNAME || -z $EMAIL || -z $ETH_ADDRESS ]]; then
    echo "Usage: $0 --nickname=<nickname> --email=<email> --eth-address=<eth-address>"
    exit 1
fi

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

# Create directories

mkdir -p /data/anon/
mkdir -p /data/anon/etc/anon/
mkdir -p /data/anon/run/anon/
mkdir -p /data/.nyx/

# Create log file
touch /data/anon/etc/anon/notices.log

# Set permissions
chmod -R 700 /data/anon/run/anon/
chown -R 100:101 /data/anon/run/anon/
chmod -R 777 /data/anon/etc/anon/notices.log

# Download configuration files
wget -O /data/anon/relay.yaml https://raw.githubusercontent.com/sicXnull/anon-install/main/docker/anon-relay/relay.yaml
wget -O /data/anon/etc/anon/anonrc https://raw.githubusercontent.com/sicXnull/anon-install/main/docker/anon-relay/anonrc
wget -O /root/.nyx/config https://raw.githubusercontent.com/sicXnull/anon-install/main/docker/anon-relay/config

# Create the content for the anonrc file
cat <<EOF > /data/anon/etc/anon/anonrc
User anond 
DataDirectory /var/lib/anon
ControlSocket /run/anon/control
ControlSocketsGroupWritable 1
CookieAuthentication 1
CookieAuthFile /run/anon/control.authcookie
CookieAuthFileGroupReadable 1
ORPort 9001
ExitRelay 0
Nickname $NICKNAME
ContactInfo $EMAIL @anon:$ETH_ADDRESS
EOF

echo "anonrc file created successfully."

# clear old containers

docker stop anon-relay
docker rm anon-relay

# Start Docker container
docker-compose -f /data/anon/relay.yaml up -d
