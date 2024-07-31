#!/bin/bash

# Check if the word "tun" exists in /etc/modules
if ! grep -q "^tun$" /data/etc/modules; then
    # Add /dev/tun module at boot
    echo "tun" >> /data/etc/modules
    echo "tun module added to /data/etc/modules"
else
    echo "tun module already exists in data/etc/modules"
fi

# Check if /dev/net/tun exists
if [ ! -e /dev/net/tun ]; then
    # Load module if /dev/net/tun does not exist
    modprobe tun
    echo "/dev/net/tun did not exist, loaded tun module"
else
    echo "/dev/net/tun already exists, skipping modprobe"
fi
