#!/bin/bash

# functions
trash() { osascript -e "tell application \"Finder\" to delete POSIX file \"$(realpath "$1")\"" > /dev/null; }

# Apple Developer constants
APPLE_ID=$(op read "op://Private/z4sp6gvcgzeejgvf6mufvqwrme/username")
APP_PASSWORD=$(op read "op://Private/z4sp6gvcgzeejgvf6mufvqwrme/App Password/App Password")
TEAM_ID=$(op read "op://Personal/z4sp6gvcgzeejgvf6mufvqwrme/Developer/Team ID")

# Hello
echo "Sparse Binary Release Utility"

target=$1
target=$(realpath "$target")
target_basename=$(basename "$target")

echo "Target: $target"
echo "SHA256: $(shasum -a 256 "$target" | awk '{print $1}')"
echo "Team ID: $TEAM_ID"

read -p "Press Enter to continue to codesign"

# Codesign
CODESIGN_VARS="--deep --force --verify --verbose --timestamp --options runtime"
codesign $CODESIGN_VARS -s "$TEAM_ID" $target

# Notarize
/usr/bin/ditto -c -k --keepParent "$target" "$target_basename.zip"
read -p "Press enter to submit for Notarization"
xcrun notarytool submit --apple-id $APPLE_ID --password $APP_PASSWORD --team-id $TEAM_ID --wait "$target_basename.zip"

read -p "Press enter to Staple"

# Staple
xcrun stapler staple "$target"
spctl -vvv --assess --type exec $target

trash "$target_basename.zip"
mkdir $target_basename
cp $target $target_basename
