#!/bin/bash

/bin/ln -sf "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" "$(/bin/launchctl getenv SSH_AUTH_SOCK)"
