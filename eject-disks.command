#!/bin/bash

# Counter
count=0
success=0

# List all external drives (omitting internal and network drives, and disk images), then eject them
for disk in $(diskutil list | grep "external" | grep -v "disk image" | awk '{print $1}'); do
    count=$((count+1))
    echo "Ejecting $disk..."
    diskutil eject $disk
    # retry if failed
    if [ $? -ne 0 ]; then
        echo "Failed to eject $disk. Retrying..."
        diskutil eject $disk
        if [ $? -ne 0 ]; then
            echo "Failed to eject $disk."
            continue
        fi
    fi
    success=$((success+1))
done

echo "Done."
echo "$success/$count drives ejected."

exit $((count-success))
