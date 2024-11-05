#!/bin/bash

# Check for the correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file_path> <target_directory>"
    exit 1
fi

FILE_PATH=$1
TARGET_DIR=$2

# Check if the file exists
if [ ! -e "$FILE_PATH" ]; then
    echo "File not found: $FILE_PATH"
    exit 1
fi

# Check if the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Directory not found: $TARGET_DIR"
    exit 1
fi

# Get the file size in bytes
FILE_SIZE=$(gdu -sB1 "$FILE_PATH" | awk '{print $1}')
echo "File size: $(numfmt --to=iec-i --suffix=B $FILE_SIZE)"

# Get the total physical memory in bytes
TOTAL_RAM=$(sysctl -n hw.memsize)
echo "Total physical RAM: $(numfmt --to=iec-i --suffix=B $TOTAL_RAM)"

# Calculate half of the physical memory
HALF_RAM=$((TOTAL_RAM / 2))

# Print a warning if the file size is larger than half of the physical RAM and pause
if [ "$FILE_SIZE" -gt "$HALF_RAM" ]; then
    echo "Warning: File size is larger than half of the physical RAM."
    read -p "Press [Enter] to continue or [Ctrl+C] to abort..."
fi

# Calculate the size needed for the RAM disk with some overhead (1.1 times the file size)
SIZE=$(echo "$FILE_SIZE * 1.1 / 512" | bc)
SIZE=${SIZE%.*}

echo "Will create a RAM disk of size: $(echo "$SIZE * 512" | bc | numfmt --to=iec-i --suffix=B)"

# Create the RAM disk
RAMDISK_DEVICE=$(hdiutil attach -nomount ram://$SIZE)
if [ $? -ne 0 ]; then
    echo "Failed to create RAM disk"
    exit 1
fi

echo "RAM disk created: $RAMDISK_DEVICE"

# Make an APFS filesystem on the RAM disk
diskutil apfs create $RAMDISK_DEVICE "RAMDisk"

# Find the mount point of the RAM disk
MOUNT_POINT=$(df | grep "RAMDisk" | awk '{print $9}')

if [ -z "$MOUNT_POINT" ]; then
    echo "Failed to mount RAM disk"
    exit 1
fi

echo "RAM disk mounted at: $MOUNT_POINT"

# Copy the file to the RAM disk
echo "Copying file to RAM disk..."
osascript -e "tell application \"Finder\" to duplicate POSIX file \"$FILE_PATH\" to POSIX file \"$MOUNT_POINT\""

echo "File copied to RAM disk, starting the copy test..."

# Start the timer
START_TIME=$(gdate +%s%N)

# Copy the file from the RAM disk to the target directory
SRC="$MOUNT_POINT/$(basename "$FILE_PATH")"
# Tell Finder to copy the file, overwriting if necessary
osascript -e "tell application \"Finder\" to duplicate POSIX file \"$SRC\" to POSIX file \"$TARGET_DIR\" with replacing"

# End the timer
END_TIME=$(gdate +%s%N)

# Calculate the time used in seconds
TIME_USED=$(echo "scale=9; ($END_TIME - $START_TIME) / 1000000000" | bc)

# Calculate the copy speed in bytes per second
COPY_SPEED=$(echo "scale=2; $FILE_SIZE / $TIME_USED" | bc)
# convert to human readable format
COPY_SPEED=$(numfmt --to=iec-i --suffix=B $COPY_SPEED)

# Print the time used and the copy speed
echo "Time used: $TIME_USED seconds"
echo "Copy speed: $COPY_SPEED per second"

# Clean up: detach the RAM disk
hdiutil detach $RAMDISK_DEVICE

# Clean up: ask if the user wants to delete the file from the target directory
read -p "Delete copied file? [Y/n] " DELETE_FILE
DELETE_FILE=${DELETE_FILE:-Y}
if [ "$DELETE_FILE" == "Y" ] || [ "$DELETE_FILE" == "y" ]; then
    # tell Finder to trash the file
    osascript -e "tell application \"Finder\" to delete POSIX file \"$TARGET_DIR/$(basename "$FILE_PATH")\""
    echo "File deleted from target directory"
fi

exit 0
