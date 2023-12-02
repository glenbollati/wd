# add these to .bashrc

awd(){
	local wdfile="$HOME/.wd"
	local toadd tocheck path
	if [ -z "$2" ]; then
		echo "You must provide an alias and a path"; return 1
	fi
	path="$(realpath $2)"

	if ! [ -e "$path" ]; then
		echo "Target does not exist: $2"; return 1
	fi
	toadd="$1 $path"

	if grep -qx "$toadd" "$wdfile"; then
		printf "%s\n%s\n" "$toadd" "$(grep -vx $toadd $wdfile)" > "$wdfile"
	elif grep -Eq "^$1 .*$" "$wdfile"; then
		echo "Alias exists: $1"; return 1
	else
		printf "%s\n%s\n" "$toadd" "$(cat $wdfile)" > "$wdfile"
	fi
}

cwd(){
	local wdfile="$HOME/.wd"
	while [ -n "$1" ]; do
		case "$1" in
			"all") printf '' > "$wdfile" ;;
			"") continue ;;
			*)
				if ! grep -Eq "^$1 .*$" "$wdfile"; then
					echo "Alias not found: $1"; return 1
				fi	
				printf "%s\n" "$(grep -Ev "^$1 .*$" $wdfile)" > "$wdfile"
				;;
		esac
		shift
	done
}

wd(){
	local wdfile="$HOME/.wd"
	touch "$wdfile"
	case "$1" in
		"") cat "$wdfile" ;;
		"a"|"add") 
			shift
			awd "$@"
			;;
		"clear") shift; cwd "$@" ;;
		"r"|"replace") shift; cwd "$1"; awd "$@" ;;
		"e"|"edit") [-n "$EDITOR" ] && $EDITOR "$wdfile" || vi "$wdfile" ;;
		"") return 1 ;;
		*)
			if ! grep -Eq "^$1 .*$" "$wdfile"; then
				echo "Alias not found: $1"; return 1
			fi

			prev="$PWD"
			local wdir="$(grep -Em 1 "^$1 .*$" "$wdfile" | awk '{print $2}')"
			cd "$wdir" && echo "Moved to $wdir"

			# Save where we jumped from as "p"
			if grep -Eq "^p .*$" "$wdfile"; then
				cwd "p"
			fi
			awd "p" "$prev"
			;;
	esac
}
_wd(){
	local cur prev opts aliaslist
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    prevprev="${COMP_WORDS[COMP_CWORD-2]}"
    opts="add clear edit"
	aliaslist="$(wd | grep -Eo '^[[:alnum:]]+ ')"

	case "$prev" in
		"wd")
			COMPREPLY=( $(compgen -W "${opts} ${aliaslist}" -- ${cur}) )
			;;
		"clear")
			COMPREPLY=( $(compgen -W "${aliaslist}" -- ${cur}) )
			;;
	esac
	case "$prevprev" in
		"a"|"add")
			compopt -o plusdirs -o nospace
			COMPREPLY=( $(compgen -d ${cur}) )
			;;
	esac

	return 0
}

complete -F _wd wd
