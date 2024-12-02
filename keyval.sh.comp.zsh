
_keyval() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local -a commands
    commands=(
        "add:Add a key-value pair"
        "put:Add a key-value pair"
        "set:Add a key-value pair"
        "lookup:Retrieve a value by key"
        "get:Retrieve a value by key"
        "read:Retrieve a value by key"
        "load:Retrieve a value by key"
        "remove:Remove a key-value pair"
        "rm:Remove a key-value pair"
        "del:Remove a key-value pair"
    )

    _arguments \
        '1:command:->command' \
        '2:key: ' \
        '3:value: ' && return 0

    case $state in
        command)
            _describe -t commands 'keyval commands' commands
            ;;
        key)
            ;;
        value)
            ;;
    esac
}

# Bind the function to the `keyval` command
compdef _keyval keyval
compdef _keyval $(realpath keyval.sh)
