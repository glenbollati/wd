# If wanting to use another language for the main program, put something like
# this in .bashrc to interface with it, and adjust completion if needed
wd(){
	local target_path cmd
	cmd="wd.py"
	case "$1" in
		""|"l"|"list") $cmd --list ;;
		"h"|"--help")  ${cmd} --help ;;
		"s"|"set")     shift; ${cmd} --set "$@" ;;
		"c"|"clear")   shift; ${cmd} --clear ${@} ;;
		"e"|"edit")    vi "$(${cmd} --file)" ;;
		*)
			target_path="'$(${cmd} --target ${1} | sed -e "s/'/'\\\\''/g")'"
			echo "${target_path}"

			# eval to drop extra quoting
			eval target_path="${target_path}"

			if [ -z "$target_path" ]; then
				echo "Alias not found: $@"
				return 1;
			fi

			prev="$PWD"
			cd "${target_path}" || return 1
			echo "Moved to ${target_path}"
			wd set '-' "${prev}"
			;;
	esac
}
