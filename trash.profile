trash() {
    for file in "$@"; do
        osascript -e "tell application \"Finder\" to delete POSIX file \"$(realpath "$file")\"" > /dev/null
    done
}
