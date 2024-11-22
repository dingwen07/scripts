#!/bin/bash

# port=3390

# check if $SCRIPTS_CONFIG_DIR is set, if not use default $HOME/Documents/Config/
# also check if $SCRIPTS_CLOUDFLARED_TUNNEL_RDP_CONFIG_DIR is set, if not, use $SCRIPTS_CONFIG_DIR/cloudflare-tunnel-rdp
if [ -z "$SCRIPTS_CONFIG_DIR" ]; then
    SCRIPTS_CONFIG_DIR="$HOME/Documents/Config"
fi

if [ -z "$SCRIPTS_CLOUDFLARED_TUNNEL_RDP_CONFIG_DIR" ]; then
    CONFIG_DIR="$SCRIPTS_CONFIG_DIR/cloudflare-tunnel-rdp"
fi

# Read configuration file

source $CONFIG_DIR/config.conf

# check if loopback and port is set

if [ -z "$loopback" ]; then
    echo "loopback is not set"
    exit 1
fi

if [ -z "$port" ]; then
    echo "port is not set"
    exit 1
fi

# check if loopback is added
loopback_ips=$(ifconfig lo0 | grep 'inet ' | awk '{print $2}')
if ! echo "$loopback_ips" | grep -q "$loopback"; then
    echo "$loopback is not added to loopback interface, adding..."
    sudo ifconfig lo0 alias $loopback up
fi

# Read hosts in $HOME/Documents/Config/cloudflare-tunnel-rdp/hosts

index=0
hosts=()

for host in $CONFIG_DIR/hosts/*;
do
    # source configuration file
    unset hostname
    unset name
    source $host
    # check if host is defined
    if [ -z "$hostname" ]; then
        echo "Host is not defined in $host"
        exit 1
    fi

    # check if name is defined
    if [ -z "$name" ]; then
        echo "Name is not defined in $host"
        exit 1
    fi

    # print hostname and name, with index
    echo "Host $index: $name ($hostname)"
    # add host to array
    hosts+=($host)
    # increment index
    index=$((index+1))

    # reset hostname and name
    unset hostname
    unset name
done

# ask user to select host, if not provided in the first argument
if [ -z "$1" ]; then
    echo ""
    read -p "Select host: " host
else
    host=$1
fi

# source configuration file
source ${hosts[$host]}

# decide port
# while port is occupied, increment port
while lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; do
    echo "$loopback:$port is not available, trying next port..."
    echo "Note: Edit config to use a dedicated loopback and port for each host."
    port=$((port+1))
done

echo "Starting on $loopback:$port..."
cloudflared access rdp --hostname $hostname --url $loopback:$port
