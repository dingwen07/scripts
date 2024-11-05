# scripts
Some commonly used Shell scripts

Automatically load scripts and sources in directory as **aliases** and **functions**.

## Usage
You might use this repository, or better, create your own repo.

Fork ONLY THE main BRANCH of this repository, or create an empty one with the following files:
- [`load_scripts`](load_scripts)
- [`update_scripts`](update_scripts)
- [`dummy.sh`](dummy.sh)
- [`dummy.source`](dummy.source)
- [`dummy.profile`](dummy.profile)

Then, if necessary, create **branches** for different platforms.

## Install
Install using the following command:
```bash
bash <(curl -sS https://raw.githubusercontent.com/dingwen07/scripts/refs/heads/main/install.sh) -r "https://github.com/dingwen07/scripts.git" -d <script_directory> -c <config_directory> [-i <interval>] [-b <branch>]
```

For example:
```bash
bash <(curl -sS https://raw.githubusercontent.com/dingwen07/scripts/refs/heads/main/install.sh) -r "https://github.com/dingwen07/scripts.git" -d "$HOME/Developer/Scripts" -c "$HOME/Documents/Config" -i 1 -b "platform-osx"
```
