#!/bin/bash

# Apple Developer constants
APPLE_ID=$(op read "op://Private/z4sp6gvcgzeejgvf6mufvqwrme/username")
APP_PASSWORD=$(op read "op://Private/z4sp6gvcgzeejgvf6mufvqwrme/App Password/App Password")
TEAM_ID=$(op read "op://Personal/z4sp6gvcgzeejgvf6mufvqwrme/Developer/Team ID")

xcrun notarytool submit --apple-id $APPLE_ID --password $APP_PASSWORD --team-id $TEAM_ID --wait "$1"
