# put this in .bashrc
wd(){
	local wdfile="$HOME/.wd"
	touch "$wdfile"
	local maxindex="$(wc -l $wdfile | cut -d' ' -f1)"

	case "$1" in
		"h"|"--help")
			echo "USAGE: wd <alias>                       cd to path pointed to by alias"
			echo "   OR: wd h or --help                   display help information"
			echo "   OR: wd l or --list                   list aliases and their paths"
			echo "   OR: wd s or --set    <alias> <path>  set alias to point to path"
			echo "   OR: wd c or --clear  <alias>         clear alias"
			echo "   OR: wd t or --target <alias>         print path pointed to by alias"
			echo "   OR: wd e or --edit                   open file for editing in vi"
			;;
		""|"l"|"--list")
			cat "$wdfile"
			;;
		"a"|"add")
			echo "'add' is deprecated, use 'set' instead";
			return 1
			;;
		"s"|"--set")
			shift; local key="$1"
			shift; local path="${@}"
			if [ -z "${path}" ]; then
				echo "You must provide an alias and a path"
				return 1
			fi
			local path="$(realpath ${path})"
			local toadd="${key} ${path}"
			printf "%s\n%s\n" "$toadd" "$(grep -Ev "^$key " $wdfile)" | sort > "$wdfile.tmp"
			mv "$wdfile.tmp" "$wdfile"
			;;
		"c"|"--clear")
			shift
			while [ -n "$1" ]; do
				printf "%s\n" "$(grep -Ev "^$1 .*$" $wdfile)" > "$wdfile.tmp"
				mv "$wdfile.tmp" "$wdfile"
				shift
			done
			;;
		"t"|"--target")
			shift
			if ! grep -Eq "^$1 .*$" "$wdfile"; then
				return 1
			fi
			local target="$(grep -Em 1 "^$1 .*$" "$wdfile" | cut -d' ' -f2-)"
			local target="${target##+([[:space:]])}"
			local target="${target%%+([[:space:]])}"
			printf "%s\n" "${target}"
			;;
		"e"|"--edit")
			vi "$wdfile"
			;;
		*)
			target_path="'$(wd --target ${1} | sed -e "s/'/'\\\\''/g")'"

			# eval to drop extra quoting
			eval target_path="${target_path}"

			if [ -z "$target_path" ]; then
				echo "Alias not found: $@"
				return 1;
			fi

			prev="$PWD"
			cd "${target_path}" || return 1
			echo "Moved to ${target_path}"
			wd --set '-' "${prev}"
			;;
	esac
}

_wd(){
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local prevprev="${COMP_WORDS[COMP_CWORD-2]}"
    local opts="h --help l --list s --set c --clear t --target e --edit"
	local aliaslist="$(wd | cut -d' ' -f1)"

	case "$prev" in
		"wd")
			COMPREPLY=( $(compgen -W "${opts} ${aliaslist}" -- ${cur}) )
			;;
		"c"|"--clear"|"s"|"--set"|"t"|"--target")
			COMPREPLY=( $(compgen -W "${aliaslist}" -- ${cur}) )
			;;
	esac
	case "$prevprev" in
		"s"|"--set")
			compopt -o plusdirs -o nospace
			COMPREPLY=( $(compgen -d ${cur}) )
			;;
	esac
	return 0
}
complete -F _wd wd

# can use the following to set the alias "p" to whatever non-$HOME directory bash was last in
# _prompt_command() {
# 	# [...]
# 	# Save latest working directory
# 	local p=$(pwd)
# 	[ "${p}" != "$HOME" ] && wd --set p "${p}"
# } 
#
# PROMPT_COMMAND=_prompt_command
