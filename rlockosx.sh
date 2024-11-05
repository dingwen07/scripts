#!/bin/bash

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $(basename $0) <destination>"
    exit 1
fi

# Assign the first argument as the host
destination="$1"

# Use SSH to send the sleep command to the specified host
ssh "$destination" '/usr/bin/pmset displaysleepnow'
