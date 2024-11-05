#!/bin/bash

# Check if an argument was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $(basename $0) ApplicationName"
    exit 1
fi

APP_NAME="$1"

# AppleScript command to get the bundle ID
BUNDLE_ID=$(osascript -e "id of app \"$APP_NAME\"")

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "$BUNDLE_ID"
else
    echo "Error: Could not find the bundle ID of $APP_NAME" >&2
fi
