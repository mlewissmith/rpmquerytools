#!/usr/bin/bash
set -u

VERBOSITY=1
LOOKUP=true
LOOKDOWN=true

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

cNFO=${ANSI_FAINT}${ANSI_CYAN}
cPKG=${ANSI_BRIGHTCYAN}
cCAP=${ANSI_ITALIC}${ANSI_FAINT}
cDEP=${ANSI_BOLD}${ANSI_GREEN}
c000=${ANSI_RESET}


function _usage { pod2usage --verbose 0 $0; exit ${1:-0}; }
function _help { pod2usage --verbose 1 $0; exit ${1:-0}; }
function _longhelp { pod2usage --verbose 2 $0; exit ${1:-0}; }
function _version { echo "@PACKAGE_STRING@" ; exit ${1:-0}; }

function vecho { [[ $VERBOSITY -ge 1 ]] && echo "$@"; }

function rpmq { rpm --query --queryformat=${QF:-'%{NAME}\n'} --nodigest --nosignature "$@"; }

function _rpmwhy {
    capability=$1
    tag=${2:-""}

    if [[ -n $tag ]] && [[ $tag != $capability ]]
    then this="${cPKG}${tag}${cCAP}:${capability}${c000}"
    else this="${cPKG}${capability}${c000}"
    fi

    local IFS=$'\n'

    for requiredby in $(rpmq --whatrequires $capability)
    do
        [[ $? == 0 ]] || break
        echo -e "$this required-by ${cDEP}${requiredby}${c000}"
    done

    for recommendedby in $(rpmq --whatrecommends $capability)
    do
        [[ $? == 0 ]] || break
        echo -e "$this recommended-by ${cDEP}${recommendedby}${c000}"
    done

    for suggestedby in $(rpmq --whatsuggests $capability)
    do
        [[ $? == 0 ]] || break
        echo -e "$this suggested-by ${cDEP}${suggestedby}${c000}"
    done

    # supplements <=> reverse recommends
    # for supplements in $(QF="[%{SUPPLEMENTS}\n]" rpmq $capability)
    # do
    #     [[ $? == 0 ]] || break
    #     echo -e "$capability supplements ${cDEP}${supplements}${c000}"
    # done

    # enhances <=> reverse suggests
    # for enhances in $(QF="[%{ENHANCES}\n]" rpmq $capability)
    # do
    #     [[ $? == 0 ]] || break
    #     echo -e "$capability enhances ${cDEP}${enhances}${c000}"
    # done
}

while getopts :PCqh-: opt
do
    case $opt in
        P) LOOKUP=false ;;
        C) LOOKDOWN=false ;;
        q) VERBOSITY=0 ;;
        h) _usage ;;
        -) case $OPTARG in
               help) _help ;;
               man) _longhelp ;;
               version) _version ;;
               *) _usage 1 ;;
           esac
           ;;
        *) _usage 1 ;;
    esac
done
shift $(($OPTIND - 1))
[[ -z "$@" ]] && _usage

for arg in "$@"
do
    _rpmwhy $arg

    $LOOKUP && for providedby in $(rpmq --whatprovides $arg)
    do
        [[ $? == 0 ]] || break
        if [[ $providedby != $arg ]]
        then
            vecho -e "${cNFO}${arg} provided-by ${providedby}${c000}"
            _rpmwhy $providedby $providedby
        fi
        #echo
        $LOOKDOWN && for provided in $(QF="[%{PROVIDES}\n]" rpmq $providedby)
        do
            [[ $provided == $arg ]] && continue
            [[ $provided == $providedby ]] && continue
            vecho -e "${cNFO}${providedby} provides ${provided}${c000}"
            _rpmwhy $provided $providedby
        done
        #echo
    done
done

################################################################################
exit
: <<__DOCEND__

=pod

=head1 NAME

rpmwhy - list dependents of rpm packages

=head1 SYNOPSIS

B<rpmwhy> [I<OPTIONS>] I<PACKAGENAME>|I<FILENAME>|I<CAPABILITY> ...

B<rpmwhy> B<-h>|B<--help>|B<--man>|B<--version>

=head1 DESCRIPTION

B<rpmwhy>(1) lists the provided capabilities of a given package, and the
installed packages which require those capabilities.  Specifically:

=over

=item *

which packages require the capability.

=item *

which packages require the parent package owning the capability.
Option B<-P> suppresses this.

=item *

which packages require the capabilities provided by the package owning the
capability.
Option B<-C> suppresses this.

=back

=head1 OPTIONS

=head2 General options

=over

=item B<-P>

Suppress details for providing parent package.

=item B<-C>

Suppress details for child capabilities of parent package.

=item B<-q>

Suppress program progress output.

=back

=head2 Information options

=over

=item B<-h>

Brief help.

=item B<--help>

Long help.

=item B<--man>

Manpage.

=item B<--version>

Display program version.

=back

=head1 BUGS

B<rpmwhy>(1) calls B<rpm -q> under the hood, potentially I<many> times.
Therefore it can be slow.

=head1 SEE ALSO

L<< B<@PACKAGE_NAME@>|@PACKAGE_URL@ >>.

B<rpmlsf>(1),
B<rpmwhat>(1),
B<rpmquerytools>(7),
B<rpm>(8).

=cut

__DOCEND__
