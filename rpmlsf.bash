#!/bin/bash
set -u

function _usage {
    cat <<-EOF
	rpmlsf - List contents of rpm packages

	Usage:
	    rpmlsf PKG...
	    rpmlsf -h

	Options:
	   -h  print this help and exit

	The PKG arguments may either be package name expressions or file names.

	- @PACKAGE_STRING@
	EOF
    exit
}

while getopts 'alh' opt
do
    case $opt in
        h) _usage ;;
    esac
done
shift $((OPTIND - 1))
[[ -z "$@" ]] && _usage

for arg in "$@"
do
    p=
    [[ -f "$arg" ]] && p=p
    rpm -q$p \
        --queryformat="[%-2{fileflags:fflags} %-11{filemodes:perms} %-6{fileusername} %-6{filegroupname} %{filenames}\n]" \
        --nodigest --nosignature "$arg"
done
