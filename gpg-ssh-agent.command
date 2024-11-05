#!/bin/bash

/bin/ln -sf "$(/opt/homebrew/bin/gpgconf --list-dirs agent-ssh-socket)" "$(/bin/launchctl getenv SSH_AUTH_SOCK)"
