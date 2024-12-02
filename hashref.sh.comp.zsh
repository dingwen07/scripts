
_hashref() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local -a commands
    commands=(
        "add:Add a value"
        "put:Add a value"
        "get:Retrieve a value by hash"
        "lookup:Retrieve a value by hash"
        "read:Retrieve a value by hash"
        "load:Retrieve a value by hash"
        "remove:Remove a hash-value pair"
        "rm:Remove a hash-value pair"
        "del:Remove a hash-value pair"
    )

    _arguments \
        '1:command:->command' \
        '2:key: ' \
        '3:value: ' && return 0

    case $state in
        command)
            _describe -t commands 'hashref commands' commands
            ;;
        key)
            ;;
        value)
            ;;
    esac
}

# Bind the function to the `hashref` command
compdef _hashref hashref
compdef _hashref $(realpath hashref.sh)
