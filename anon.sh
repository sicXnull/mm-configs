#!/bin/bash

BASE_DIR="/opt"
if [ -f "/etc/crankk.conf" ]; then
    BASE_DIR="/data"
fi

NICKNAME=""
EMAIL=""
ETH_ADDRESS=""
FAMILY=""

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
        --family=*)
            FAMILY="${1#*=}"
            ;;
        *)
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
    shift
done

if [[ -z $NICKNAME || -z $EMAIL || -z $ETH_ADDRESS ]]; then
    echo "Usage: $0 --nickname=<nickname> --email=<email> --eth-address=<eth-address> [--family=<family>]"
    exit 1
fi

mkdir -p "$BASE_DIR/anon/"
mkdir -p "$BASE_DIR/anon/etc/anon/"
mkdir -p "$BASE_DIR/anon/run/anon/"
mkdir -p "$BASE_DIR/.nyx/"

touch "$BASE_DIR/anon/etc/anon/notices.log"

chmod -R 700 "$BASE_DIR/anon/run/anon/"
chown -R 100:101 "$BASE_DIR/anon/run/anon/"
chmod -R 777 "$BASE_DIR/anon/etc/anon/notices.log"

wget -O "$BASE_DIR/anon/relay.yaml" https://raw.githubusercontent.com/sicXnull/anon-install/main/docker/anon-relay/relay.yaml
wget -O "$BASE_DIR/anon/etc/anon/anonrc" https://raw.githubusercontent.com/sicXnull/anon-install/main/docker/anon-relay/anonrc
wget -O "$HOME/.nyx/config" https://raw.githubusercontent.com/sicXnull/anon-install/main/docker/anon-relay/config

cat <<EOF > "$BASE_DIR/anon/etc/anon/anonrc"
User anond 
DataDirectory /var/lib/anon
ControlSocket /run/anon/control
ControlSocketsGroupWritable 1
CookieAuthentication 1
CookieAuthFile /run/anon/control.authcookie
CookieAuthFileGroupReadable 1
ORPort 9001
ExitRelay 0
AgreeToTerms 1
Nickname $NICKNAME
ContactInfo $EMAIL @anon:$ETH_ADDRESS
Family $FAMILY
EOF

echo "anonrc file created successfully."

docker stop anon-relay
docker rm anon-relay

docker-compose -f "$BASE_DIR/anon/relay.yaml" up -d
