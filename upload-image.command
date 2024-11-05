#!/bin/bash

# if $SCRIPTS_CONFIG_DIR is not set, use default $HOME/Documents/Config/

if [ -z "$SCRIPTS_CONFIG_DIR" ]; then
    SCRIPTS_CONFIG_DIR="$HOME/Documents/Config"
fi

CONFIG_FILE="$SCRIPTS_CONFIG_DIR/upload-image.conf"
source $CONFIG_FILE

# check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <image file>"
    exit 1
fi

# Check if the file exists and handle spaces in filenames
FILE="$1"
if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

# confirm with user
echo "Uploading $FILE to $host:$target"
read -p "Continue (y/n)? " -n 1 -r
echo # move to a new line

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Upload canceled."
    exit 1
fi

# Calculate relative path with date and encode spaces in filenames
rest=$(date +%Y/%m/%d)/$(basename "$FILE" | sed 's/ /\\ /g')
ssh -p $port $user@$host "mkdir -p $target/$(dirname $rest)"

# Use quotes to handle spaces in scp command
scp -P $port "$FILE" $user@$host:"$target/$rest"

# Check if scp was successful
if [ $? -ne 0 ]; then
    echo "Error copying file"
    exit 1
fi

# urlencode the final output URL
urlencode() {
    python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))" "$1"
}

urlencoded_rest=$(urlencode "$rest")
url="$remote/$urlencoded_rest"
echo "URL: $url"
