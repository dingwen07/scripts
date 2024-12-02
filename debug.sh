#!/bin/bash

unset SCRIPTS_NOLOAD
export SCRIPTS_DIR=$(dirname "$(realpath "$0")")
export SCRIPTS_DEBUG=true

if [ -n "$1" ]; then
    git -C "$SCRIPTS_DIR" checkout "$1"
fi
source "$SCRIPTS_DIR/load_scripts"
