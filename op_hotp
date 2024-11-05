#!/bin/bash

CONFIG_DIR="$HOME/Documents/Config/op-hotp"

if [ "$#" -eq 1 ]; then
  # check $CONFIG_DIR/$1.txt exists
    if [ ! -f "$CONFIG_DIR/$1.txt" ]; then
        echo "Config file $CONFIG_DIR/$1 does not exist"
        exit 1
    fi
    bash -c "$0 $(cat "$CONFIG_DIR/$1.txt")"
    exit
fi

# Check if the required arguments are provided
if [ "$#" -ne 4 ]; then
    echo $#
    echo "Usage: $0 <Vault ID> <Item ID> <HOTP Secret Field ID> <HOTP Counter Field ID>"
    exit 1
fi

# Assign arguments to variables
VAULT_ID=$1
ITEM_ID=$2
HOTP_SECRET_FIELD_ID=$3
HOTP_COUNTER_FIELD_ID=$4

# Read the HOTP secret and counter from 1Password
HOTP_SECRET=$(op read "op://$VAULT_ID/$ITEM_ID/$HOTP_SECRET_FIELD_ID")
HOTP_COUNTER=$(op read "op://$VAULT_ID/$ITEM_ID/$HOTP_COUNTER_FIELD_ID")

# Compute the OTP using oathtool
OTP=$(oathtool --hotp --base32 -c $HOTP_COUNTER $HOTP_SECRET)

# Output the OTP
echo $OTP

# Increment the counter
NEW_COUNTER=$((HOTP_COUNTER + 1))

# Update the counter in 1Password
# if "/" in $HOTP_COUNTER_FIELD_ID, replace with "."
if [[ $HOTP_COUNTER_FIELD_ID == */* ]]; then
    HOTP_COUNTER_FIELD_ID=$(echo $HOTP_COUNTER_FIELD_ID | tr '/' '.')
fi
op item edit "$ITEM_ID" "$HOTP_COUNTER_FIELD_ID=$NEW_COUNTER" > /dev/null
