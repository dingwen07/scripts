#!/bin/bash

# Use localhost if no argument is provided
if [ "$#" -eq 0 ]; then
    destination="localhost"
elif [ "$#" -eq 1 ]; then
    destination="$1"
else
    echo "Usage: $(basename "$0") [destination]"
    exit 1
fi

# Use SSH to send the sleep command to the specified host
ssh "$destination" '/usr/bin/pmset displaysleepnow'
