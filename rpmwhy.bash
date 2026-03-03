#!/usr/bin/bash
set -u

# weak (reverse) dependencies:
# Recommends <=> Supplements
# Suggests <=> Enhances

ANSI_RESET="\e[0m"
ANSI_BOLD="\e[1m"
ANSI_FAINT="\e[2m"
ANSI_ITALIC="\e[3m"
ANSI_UNDERLINE="\e[4m"

ANSI_BLACK="\e[30m"
ANSI_RED="\e[31m"
ANSI_GREEN="\e[32m"
ANSI_YELLOW="\e[33m"
ANSI_BLUE="\e[34m"
ANSI_MAGENTA="\e[35m"
ANSI_CYAN="\e[36m"
ANSI_WHITE="\e[37m"

ANSI_BRIGHTBLACK="\e[90m"
ANSI_BRIGHTRED="\e[91m"
ANSI_BRIGHTGREEN="\e[92m"
ANSI_BRIGHTYELLOW="\e[93m"
ANSI_BRIGHTBLUE="\e[94m"
ANSI_BRIGHTMAGENTA="\e[95m"
ANSI_BRIGHTCYAN="\e[96m"
ANSI_BRIGHTWHITE="\e[97m"

EMPH=${ANSI_BOLD}${ANSI_GREEN}

function _usage { pod2usage $0; }
function _man { pod2usage --verbose 2 $0; }
function rpmq { rpm --query --queryformat=${QF:-'%{NAME}\n'} --nodigest --nosignature "$@"; }

function _rpmwhy {
    this=$1
    local IFS=$'\n'

    for requiredby in $(rpmq --whatrequires $this)
    do
        [[ $? == 0 ]] || break
        echo -e "$this required-by ${EMPH}${requiredby}${ANSI_RESET}"
    done

    for recommendedby in $(rpmq --whatrecommends $this)
    do
        [[ $? == 0 ]] || break
        echo -e "$this recommended-by ${EMPH}${recommendedby}${ANSI_RESET}"
    done

    for supplements in $(QF="[%{SUPPLEMENTS}\n]" rpmq $this)
    do
        [[ $? == 0 ]] || break
        echo -e "$this supplements ${EMPH}${supplements}${ANSI_RESET}"
    done

    for suggestedby in $(rpmq --whatsuggests $this)
    do
        [[ $? == 0 ]] || break
        echo -e "$this suggested-by ${EMPH}${suggestedby}${ANSI_RESET}"
    done

    for enhances in $(QF="[%{ENHANCES}\n]" rpmq $this)
    do
        [[ $? == 0 ]] || break
        echo -e "$this enhances ${EMPH}${enhances}${ANSI_RESET}"
    done
}

while getopts qvhH opt
do
    case $opt in
        h) _usage ; exit 0 ;;
        H) _man ; exit 0 ;;
        *) _usage ; exit 1 ;;
    esac
done
shift $(($OPTIND - 1))

for arg in "$@"
do
    _rpmwhy $arg
    for providedby in $(rpmq --whatprovides $arg)
    do
        [[ $? == 0 ]] || break
        [[ $arg == $providedby ]] ||
            echo "$arg provided-by $providedby"
        for provided in $(QF="[%{PROVIDES}\n]" rpmq $providedby)
        do
            [[ $providedby == $provided ]] ||
                echo "$providedby provides $provided"
            [[ $provided == $arg ]] ||
                _rpmwhy $provided
        done
    done
done

################################################################################
exit
: <<__DOCEND__

=pod

=head1 NAME

rpmwhy - Why is a given package on my system?

=head1 SYNOPSIS

B<rpmwhy> I<PACKAGE>|I<FILE>|I<CAPABILITY> ...

B<rpmwhy> B<-h>|B<-H>

=head1 DESCRIPTION

B<rpmwhy> is a wrapper around B<rpm -q --what{requires,recommends}>.

=head1 OPTIONS

=over 4

=item B<-h>

Brief help

=item B<-H>

Long help

=back

=head1 SEE ALSO

   rpm --test --erase PACKAGE

=cut


__DOCEND__
