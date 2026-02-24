#!/usr/bin/expect -f

# ---------------------------------
# CIMS SSH Login Script
# Configuration:
set OP_CMD "op"
set OP_USERNAME "op://Personal/67slu4lrsqp7j6uxsj35qvl4pa/username"
set OP_PASSWORD "op://Personal/67slu4lrsqp7j6uxsj35qvl4pa/password"
set OP_DUO_PASSCODE "op://Personal/m26ohbiibq3rv73rcbpixdzvg4/one-time password?attribute=otp"
# ---------------------------------

# Set the timeout to 20 seconds
set timeout 20

# Retrieve credentials from 1Password
set username [exec $OP_CMD read $OP_USERNAME]
set password [exec $OP_CMD read $OP_PASSWORD]
set netid [lindex [split $username "@"] 0]

# Start the SSH session
spawn ssh -A -o PreferredAuthentications=password,keyboard-interactive -o PubkeyAuthentication=no $netid@access.cims.nyu.edu

# Wait for the password prompt
expect "Password:"
# Provide the password
send "$password\r"

# Check if a Duo Passcode was provided as a command line argument
# Moved after password to avoid TOTP expiration
if { $argc > 0 } {
    set duo_passcode [lindex $argv 0]
} else {
    set duo_passcode [exec $OP_CMD read $OP_DUO_PASSCODE]
}

# Check if a Duo Passcode needs to be sent
if { $duo_passcode != "" } {
    expect "Passcode or option"
    send "$duo_passcode\r"
}

# Hand over control to the user
interact
