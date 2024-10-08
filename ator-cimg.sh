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
    chroot /host sudo curl -L https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose
    chroot /host sudo chown root: /usr/bin/docker-compose
    chroot /host sudo chmod +x /usr/bin/docker-compose
fi

chroot /host /bin/bash -x <<'EOF1'
# Create directories
sudo mkdir -p /opt/anon/
sudo mkdir -p /opt/anon/etc/anon/
sudo mkdir -p /opt/anon/run/anon/
sudo mkdir -p /root/.nyx/

# Create log file
sudo touch /opt/anon/etc/anon/notices.log

# Set permissions
sudo chmod -R 700 /opt/anon/run/anon/
sudo chown -R 100:101 /opt/anon/run/anon/
sudo chown 100:101 /opt/anon/etc/anon/notices.log

# Add user
sudo useradd -M anond

# Download configuration files
sudo wget -O /opt/anon/relay.yaml https://raw.githubusercontent.com/ATOR-Development/anon-install/main/docker/anon-relay/relay.yaml
sudo wget -O /opt/anon/etc/anon/anonrc https://raw.githubusercontent.com/ATOR-Development/anon-install/main/docker/anon-relay/anonrc
sudo wget -O /root/.nyx/config https://raw.githubusercontent.com/ATOR-Development/anon-install/main/docker/anon-relay/config
EOF1

# Create the content for the anonrc file
cat <<EOF > /host/opt/anon/etc/anon/anonrc
User anond
DataDirectory /var/lib/anon
ControlSocket /run/anon/control
ControlSocketsGroupWritable 1
CookieAuthentication 1
CookieAuthFile /run/anon/control.authcookie
CookieAuthFileGroupReadable 1
Log notice file /etc/anon/notices.log
ORPort 9001
ExitRelay 0
AgreeToTerms 1
Nickname $NICKNAME
ContactInfo $EMAIL @anon:$ETH_ADDRESS
EOF
echo "anonrc file created successfully."

# Start Docker container
chroot /host sudo docker-compose -f /opt/anon/relay.yaml up -d

