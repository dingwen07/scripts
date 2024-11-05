#!/bin/bash

# List of folder names
folders=("Applications" "DCIM" "DCIM.localized" "Desktop" "Documents" "Downloads" "DriveInfo.txt" 
         "IPSW.localized" "Library" "Miscellaneous" "Movies" "Music" "Pictures" "Sandbox" 
         "SteamLibrary" "Time Machine.localized" "Videos" "Virtual Disks.localized" 
         "Virtual Machines UTM.localized" "Virtual Machines.localized")

# Iterate over the list and apply the chmod command
for folder in "${folders[@]}"; do
    if [ -e "$folder" ]; then
        chmod +a "group:everyone deny delete" "$folder"
        echo "Applied permission to $folder"
    else
        echo "$folder does not exist in the current directory."
    fi
done
