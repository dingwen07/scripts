trash () {
	osascript -e "tell application \"Finder\" to delete POSIX file \"$(realpath "$1")\"" > /dev/null
}
