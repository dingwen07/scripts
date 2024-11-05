#!/bin/bash

# Configurations
OP_CLI="op"
HASH_UTIL="sha256sum"
OP_VAULT_ID="Personal"
OP_ITEM_NAME="Personal Hashes Reference"
OP_ITEM_CATEGORY="Secure Note"
OP_ITEM_FIELD_TYPE="password"

# Pre-execution checks
# Check if the item exists
if ! $OP_CLI item get "$OP_ITEM_NAME" --vault "$OP_VAULT_ID" > /dev/null 2>&1; then
    echo "Item '$OP_ITEM_NAME' not found in vault '$OP_VAULT_ID', creating..." >&2
    if ! $OP_CLI item create --category "$OP_ITEM_CATEGORY" --title "$OP_ITEM_NAME" --vault "$OP_VAULT_ID"; then
        echo "Failed to create item '$OP_ITEM_NAME' in vault '$OP_VAULT_ID'" >&2
        exit 2
    fi
fi

# Helper functions
print_escaped() {
    echo -n "$1" | python3 -c "import sys; print(repr(sys.stdin.read()))"
}

add_hash() {
    local hash=$1
    local value=$2
    decoded_value=$(base64 -d <<< "$value")
    escaped_value=$(print_escaped "$decoded_value")
    # truncate the value to 1000 characters
    if [ ${#escaped_value} -gt 1000 ]; then
        escaped_value=$(echo -n "$escaped_value" | cut -c 1-1000)...
    fi
    echo "Adding hash '$hash' with value $escaped_value to item '$OP_ITEM_NAME' from vault '$OP_VAULT_ID'..." >&2
    # value=$(echo -n "$value" | base64)
    if ! $OP_CLI item edit "$OP_ITEM_NAME" --vault "$OP_VAULT_ID" "$hash[$OP_ITEM_FIELD_TYPE]=$value" > /dev/null; then
        echo "Failed to add hash '$hash' to item '$OP_ITEM_NAME'" >&2
        exit 2
    fi
    echo $hash
}

lookup_hash() {
    local hash=$1
    echo "Looking up hash '$hash' in item '$OP_ITEM_NAME' from vault '$OP_VAULT_ID'..." >&2
    value=$($OP_CLI read op://"$OP_VAULT_ID"/"$OP_ITEM_NAME"/"$hash")
    if [ -z "$value" ]; then
        echo "Hash '$hash' not found in item '$OP_ITEM_NAME' from vault '$OP_VAULT_ID'" >&2
        exit 2
    fi
    base64 -d <<< "$value"
    if [ $? -ne 0 ]; then
        echo "Failed to decode value '$value'" >&2
        exit 3
    fi
}

read_hash() {
    # Accept input from stdin until EOF, hash entire stdin and add it to the item
    input=$(base64)
    exec < /dev/tty
    echo ""
    hash=$(base64 -d <<< "$input" | $HASH_UTIL | awk '{print $1}')
    add_hash "$hash" "$input"
}

# Main execution
case "$#" in
    0)
        read_hash
        ;;
    1)
        if [ "$1" == "add" ]; then
            read_hash
        else
            # Lookup the hash value in the item
            lookup_hash "$1"
        fi
        ;;
    2)
        if [ "$1" == "add" ]; then
            # Add the hash value and string
            hash=$(echo -n "$2" | $HASH_UTIL | awk '{print $1}')
            add_hash "$hash" "$(echo -n "$2" | base64)"
        elif [ "$1" == "get" ] || [ "$1" == "load" ] || [ "$1" == "lookup" ]; then
            # Lookup the hash value in the item
            lookup_hash "$2"
        else
            echo "Invalid arguments" >&2
            exit 1
        fi
        ;;
    *)
        echo "Invalid number of arguments" >&2
        exit 1
        ;;
esac

# echo "Operation completed successfully"

# Return value:
# 0: Success
# 1: Invalid arguments
# 2: 1Password CLI operation failed
# 3: Base64 decoding failed
