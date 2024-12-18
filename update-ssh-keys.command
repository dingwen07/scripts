#!/bin/zsh

# if $SCRIPTS_CONFIG_DIR is not set, use default "$HOME/Documents/Config"
if [ -z "$SCRIPTS_CONFIG_DIR" ]; then
    SCRIPTS_CONFIG_DIR="$HOME/Documents/Config"
fi

CONFIG_FILE="$SCRIPTS_CONFIG_DIR/update-ssh-keys.conf"
ROAMING_KEYS_DIR="$SCRIPTS_CONFIG_DIR/ssh-keys"


# if $GITHUB_USERNAME is not set, use default "dingwen07"
if [ -z "$SCRIPTS_GITHUB_USERNAME" ]; then
    SCRIPTS_GITHUB_USERNAME="dingwen07"
fi
GITHUB_USERNAME=$SCRIPTS_GITHUB_USERNAME

# if $SSH_AUTHORIZED_KEYS is not set, use default "$HOME/.ssh/authorized_keys"
if [ -z "$SCRIPTS_SSH_AUTHORIZED_KEYS" ]; then
    SCRIPTS_SSH_AUTHORIZED_KEYS="$HOME/.ssh/authorized_keys"
fi
SSH_AUTHORIZED_KEYS=$SCRIPTS_SSH_AUTHORIZED_KEYS

echo "This script will modify $SSH_AUTHORIZED_KEYS with keys from following sources:"
echo " - GitHub Account: $GITHUB_USERNAME"
echo " - $ROAMING_KEYS_DIR/*"
echo "You will be prompted for authentication"
echo "Press Enter to continue..."
if ! read; then
    echo "Aborted."
    exit 0
fi

# rm "$SSH_AUTHORIZED_KEYS"
sudo -k
sudo rm -f "$SSH_AUTHORIZED_KEYS"

# Populate with GitHub keys
echo "# GitHub keys" >> "$SSH_AUTHORIZED_KEYS"
curl "https://github.com/$GITHUB_USERNAME.keys" >> "$SSH_AUTHORIZED_KEYS"
echo "" >> "$SSH_AUTHORIZED_KEYS"

# Populate with roaming keys
echo "Following roaming keys will be added:"
echo "# Roaming keys" >> "$SSH_AUTHORIZED_KEYS"
for key in "$ROAMING_KEYS_DIR"/*; do
    echo "`basename $key`: `head -n 1 $key`"
    echo "# `basename $key`" >> "$SSH_AUTHORIZED_KEYS"
    head -n 1 "$key" >> "$SSH_AUTHORIZED_KEYS"
    echo "" >> "$SSH_AUTHORIZED_KEYS"
done
echo "# End of roaming keys" >> "$SSH_AUTHORIZED_KEYS"

# Protect authorized_keys
echo "Updating permissions..."
sudo chmod 644 "$SSH_AUTHORIZED_KEYS"

echo "Done."
