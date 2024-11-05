#!/bin/bash

# Check args
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 inputfile.png [outputfile.icns]"
    echo "Note: inputfile.png should be PNG format and at least 1024x1024 pixels."
    exit 1
fi

INPUT_FILE=$1

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File $INPUT_FILE not found."
    exit 1
fi

# Set the output file name, either as the second argument or replace png extension with icns
OUTPUT_FILE=${2:-$(echo $INPUT_FILE | sed 's/.png$/.icns/')}

# Create a iconset directory
ICONSET_DIR="$(basename "$INPUT_FILE" .png).iconset"
mkdir -p "$ICONSET_DIR"

# Generate the different icon sizes
sips -z 16 16     "$INPUT_FILE" --out "$ICONSET_DIR/icon_16x16.png"
sips -z 32 32     "$INPUT_FILE" --out "$ICONSET_DIR/icon_16x16@2x.png"
sips -z 32 32     "$INPUT_FILE" --out "$ICONSET_DIR/icon_32x32.png"
sips -z 64 64     "$INPUT_FILE" --out "$ICONSET_DIR/icon_32x32@2x.png"
sips -z 128 128   "$INPUT_FILE" --out "$ICONSET_DIR/icon_128x128.png"
sips -z 256 256   "$INPUT_FILE" --out "$ICONSET_DIR/icon_128x128@2x.png"
sips -z 256 256   "$INPUT_FILE" --out "$ICONSET_DIR/icon_256x256.png"
sips -z 512 512   "$INPUT_FILE" --out "$ICONSET_DIR/icon_256x256@2x.png"
sips -z 512 512   "$INPUT_FILE" --out "$ICONSET_DIR/icon_512x512.png"
cp "$INPUT_FILE" "$ICONSET_DIR/icon_512x512@2x.png"

# Create the ICNS file
iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_FILE"

# Remove the temporary iconset directory
rm -R "$ICONSET_DIR"

echo "ICNS file created at $OUTPUT_FILE"
