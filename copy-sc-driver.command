#!/bin/bash

/usr/bin/sudo /bin/mkdir -p /usr/local/libexec/SmartCardServices/drivers
/usr/bin/osascript -e 'tell application "Finder" to duplicate (POSIX file "/usr/libexec/SmartCardServices/drivers/ifd-ccid.bundle" as alias) to folder (POSIX file "/usr/local/libexec/SmartCardServices/drivers" as alias)'
