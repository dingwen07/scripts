#!/bin/bash

# Codesign
CODESIGN_VARS="--deep --force --verify --verbose --timestamp --options runtime"
codesign $CODESIGN_VARS -s "$TEAM_ID" $1
