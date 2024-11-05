#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -r <repository> -d <script-directory> -c <config-directory> [-i <interval>] [-b <branch>]"
    exit 1
}

# Default values
INTERVAL=1
BRANCH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--repository)
            REPO=$2
            shift 2
            ;;
        -d|--script-directory)
            SCRIPTS_DIR=$2
            shift 2
            ;;
        -c|--config)
            SCRIPTS_CONFIG_DIR=$2
            shift 2
            ;;
        -i|--interval)
            INTERVAL=$2
            shift 2
            ;;
        -b|--branch)
            BRANCH=$2
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Check if mandatory arguments are provided
if [[ -z "$REPO" || -z "$SCRIPTS_DIR" || -z "$SCRIPTS_CONFIG_DIR" ]]; then
    usage
fi

# Check if the config directory exists
if [[ ! -d "$SCRIPTS_CONFIG_DIR" ]]; then
    echo "Error: Config directory '$SCRIPTS_CONFIG_DIR' does not exist."
    exit 1
fi

# Clone the repository to SCRIPTS_DIR
git clone "$REPO" "$SCRIPTS_DIR"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to clone repository."
    exit 1
fi

# Get the default branch if not provided
if [[ -z "$BRANCH" ]]; then
    cd "$SCRIPTS_DIR" || exit 1
    BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    cd - >/dev/null || exit 1
fi

# Create config file in SCRIPTS_CONFIG_DIR
echo "REFRESH_INTERVAL=$INTERVAL" > "$SCRIPTS_CONFIG_DIR/scripts.conf"
echo "GIT_BRANCH=$BRANCH" >> "$SCRIPTS_CONFIG_DIR/scripts.conf"

# Checkout the branch
git -C "$SCRIPTS_DIR" checkout "$BRANCH" > /dev/null

echo ""
echo "Installation complete."
echo "Please add the following lines to your .zshrc or .bashrc file to enable script loading:"
echo ""

# Print output for adding to .zshrc or .bashrc
echo "# Load Personal Scripts"
echo "export SCRIPTS_DIR=$SCRIPTS_DIR"
echo "export SCRIPTS_CONFIG_DIR=$SCRIPTS_CONFIG_DIR"
echo 'source "$SCRIPTS_DIR/update_scripts"'
echo 'source "$SCRIPTS_DIR/load_scripts"'
