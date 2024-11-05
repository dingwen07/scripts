#!/bin/bash

# findApp.sh
# https://stackoverflow.com/a/51806092
# ==========
NAME_APP=$1
PATH_LAUNCHSERVICES="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"
${PATH_LAUNCHSERVICES} -dump | grep -o "/.*${NAME_APP}.app" | grep -v -E "Caches|TimeMachine|Temporary|/Volumes/${NAME_APP}" | uniq
