#!/bin/bash

# Configurations
OP_CLI="op.exe"
HASH_UTIL="sha256sum"
OP_VAULT_ID="Personal"
OP_ITEM_NAME="Personal Key-Value Pairs"
OP_ITEM_CATEGORY="Secure Note"
OP_ITEM_FIELD_TYPE="password"

# If KEYVAL_ITEM is set
if [ -n "$KEYVAL_ITEM" ]; then
    OP_ITEM_NAME="$KEYVAL_ITEM"
fi

# Helper functions
print_escaped() {
    echo -n "$1" | python3 -c "import sys; print(repr(sys.stdin.buffer.read()))"
}

escape_equals() {
    echo "$1" | sed 's/=/\\=/g'
}



usage() {
    echo "args: $@" >&2
    echo "Usage: $0 <add|lookup|remove> key [value]" >&2
    exit 1
}

add_key() {
    local key=$1
    key_encoded=$(base32 <<< "$key")
    key_encoded=$(escape_equals "$key_encoded")
    value=$(base64)
    exec < /dev/tty
    decoded_value=$(base64 -d <<< "$value")
    escaped_value=$(print_escaped "$decoded_value")
    # truncate the value to 256 characters
    if [ ${#escaped_value} -gt 256 ]; then
        escaped_value=$(echo -n "$escaped_value" | cut -c 1-256)...
    fi
    echo "Adding key '$key' with value $escaped_value to item '$OP_ITEM_NAME' from vault '$OP_VAULT_ID'..." >&2
    if ! $OP_CLI item edit "$OP_ITEM_NAME" --vault "$OP_VAULT_ID" "$key_encoded[$OP_ITEM_FIELD_TYPE]=$value" < /dev/null > /dev/null; then
        echo "Failed to add key '$key' to item '$OP_ITEM_NAME'" >&2
        exit 2
    fi
    echo $key
}

lookup_key() {
    local key=$1
    key_encoded=$(base32 <<< "$key")
    # key_encoded=$(escape_equals "$key_encoded")
    echo "Looking up key '$key' in item '$OP_ITEM_NAME' from vault '$OP_VAULT_ID'..." >&2
    value=$($OP_CLI read op://"$OP_VAULT_ID"/"$OP_ITEM_NAME"/"$key_encoded")
    if [ -z "$value" ]; then
        echo "Key '$key' not found in item '$OP_ITEM_NAME' from vault '$OP_VAULT_ID'" >&2
        return 2
    fi
    base64 -d <<< "$value"
    if [ $? -ne 0 ]; then
        echo "Failed to decode value '$value'" >&2
        return 3
    fi
}

remove_key() {
    local key=$1
    lookup_key "$key" > /dev/null
    ret=$?
    if [ $ret -ne 0 ] && [ $ret -ne 3 ]; then
        return 2
    fi
    key_encoded=$(base32 <<< "$key")
    key_encoded=$(escape_equals "$key_encoded")
    echo "Removing key '$key' from item '$OP_ITEM_NAME' from vault '$OP_VAULT_ID'..." >&2
    if ! $OP_CLI item edit "$OP_ITEM_NAME" --vault "$OP_VAULT_ID" "$key_encoded[delete]=" < /dev/null > /dev/null; then
        echo "Failed to remove key '$key' from item '$OP_ITEM_NAME'" >&2
        return 2
    fi
    echo $key
}

lookup_key_stdin() {
    # Accept key from stdin and lookup the value in the item
    err=0
    while read key; do
        lookup_key "$key"
        if [ $? -ne 0 ]; then
            err=4
        fi
    done
    return $err
}

remove_key_stdin() {
    # Accept key from stdin and remove the key from the item
    err=0
    while read key; do
        remove_key "$key"
        if [ $? -ne 0 ]; then
            err=4
        fi
    done
    return $err
}


# Pre-execution checks
# Check if the item exists
if ! $OP_CLI item get "$OP_ITEM_NAME" --vault "$OP_VAULT_ID" < /dev/null > /dev/null 2>&1; then
    echo "Item '$OP_ITEM_NAME' not found in vault '$OP_VAULT_ID', creating..." >&2
    if ! $OP_CLI item create --category "$OP_ITEM_CATEGORY" --title "$OP_ITEM_NAME" --vault "$OP_VAULT_ID" < /dev/null >&2; then
        echo "Failed to create item '$OP_ITEM_NAME' in vault '$OP_VAULT_ID'" >&2
        exit 2
    fi
fi

# Main
case "$#" in
    0)
        lookup_key_stdin
        ;;
    1)
        case "$1" in
            lookup | get | read | load)
                lookup_key_stdin
                ;;
            remove | rm | del)
                remove_key_stdin
                ;;
            *)
                usage
                exit 1
                ;;
        esac
        ;;
    2)
        case "$1" in
            add | put | set)
                add_key "$2"
                ;;
            lookup | get | read | load)
                lookup_key "$2"
                ;;
            remove | rm | del)
                remove_key "$2"
                ;;
            *)
                usage
                exit 1
                ;;
        esac
        ;;
    3)
        case "$1" in
            add | put | set)
                printf "$3" | add_key "$2"
                ;;
            *)
                usage
                exit 1
                ;;
        esac
        ;;
    *)
        usage
        exit 1
        ;;
esac

# Return value:
# 0: Success
# 1: Invalid arguments
# 2: 1Password CLI operation failed
# 3: Base64 decoding failed
# 4: Exception in batch operation
