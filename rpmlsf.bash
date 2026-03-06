#!/bin/bash
set -u

all=
owner=

function _usage {
    cat <<-EOF
	rpmlsf - List contents of rpm packages

	Usage:
	    rpmlsf [-a] [-l] PKG...
	    rpmlsf -h

	Options:
	   -a  list all packages matching a PKG
	   -l  use a long listing format
	   -h  print this help and exit

	The PKG arguments may either be package name expressions or file names.

	- @PACKAGE_STRING@
	EOF
    exit
}

while getopts 'alh' opt
do
    case $opt in
        a) all=a ;;
        l) owner='%-8{fileusername} %-8{filegroupname} ' ;;
        h) _usage ;;
    esac
done
shift $((OPTIND - 1))
[[ -z "$@" ]] && _usage

qf="[%-4{fileflags:fflags} %-11{filemodes:perms} $owner%{filenames}\\n]"

for arg in "$@"
do
    a=$all
    p=
    if [[ -f "$arg" ]]
    then
        a=
        p=p
    fi
    rpm -q$a$p --qf="$qf" --nodigest --nosignature "$arg"
done
