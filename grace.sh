#!/usr/bin/expect -f

# Set the timeout to 20 seconds
set timeout 20

# Retrieve the password securely from 1Password
set password [exec op read "op://Personal/UMD Directory ID/password"]

# Start the SSH session
spawn ssh -A dingwen@grace.umd.edu

# Wait for the password prompt
expect "Password:"
# Provide the password
send "$password\r"

# Check if a Duo Passcode was provided as a command line argument
# Moved after password to avoid TOTP expiration
if { $argc > 0 } {
    set duo_passcode [lindex $argv 0]
} else {
    set duo_passcode [exec op read "op://Personal/UMD Directory ID/one-time password?attribute=otp"]
}

# Check if a Duo Passcode needs to be sent
if { $duo_passcode != "" } {
    expect "Passcode or option"
    send "$duo_passcode\r"
}

# Hand over control to the user
interact
