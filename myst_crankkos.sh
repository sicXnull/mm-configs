#!/bin/bash

#add /dev/tun module at boot
echo "tun" > /data/etc/modules

#load module

modprobe tun

#stop any myst containers

docker stop myst
docker rm myst

#spin up new myst instance

docker run --restart always -d \
    --dns 1.1.1.1 --dns 1.0.0.1 --dns 8.8.8.8 --hostname myst --cap-add NET_ADMIN \
    -p 0.0.0.0:4449:4449 -p 0.0.0.0:56000-56100:56000-56100/udp -v /dev/net/tun:/dev/net/tun \
    -v /data/myst:/var/lib/mysterium-node --name myst mysteriumnetwork/myst:latest \
    --vendor.id=crankk --udp.ports=56000:56100 service --agreed-terms-and-conditions

# Check if the Docker container started successfully
if [ $? -eq 0 ]; then
    echo "myst installation successful"
else
    echo "myst installation failed"
fi

