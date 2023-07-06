#!/bin/sh


# see https://betterdev.blog/minimal-safe-bash-script-template/
# https://gist.github.com/m-radzikowski/53e0b39e9a59a1518990e76c2bff8038



#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
#  or so: script_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

usage() {
  cat <<EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-f, --flag      Some flag description
-p, --param     Some param description
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

function printColored() { local B="\033[0;"; local C=""; case "${1}" in "red") C="31m";; "green") C="32m";; "yellow") C="33m";; "blue") C="34m";; esac; printf "%b%b\033[0m" "${B}${C}" "${2}"; }

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -f | --flag) flag=1 ;; # example flag
    -p | --param) # example named parameter
      param="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${param-}" ]] && die "Missing required parameter: param"
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "$@"
setup_colors

# script logic here

msg "${RED}Read parameters:${NOFORMAT}"
msg "- flag: ${flag}"
msg "- param: ${param}"
msg "- arguments: ${args[*]-}"


# this part taken from https://github.com/GhostWriters/DockSTARTer/blob/master/main.sh
# good intro here https://github.com/GhostWriters/DockSTARTer/blob/master/.github/CONTRIBUTING.md#shell-scripts



# see https://gist.github.com/vratiu/9780109
# Regular Colors
#    .---------- constant part!
#    vvvv vvvv-- the code from above
Red='\033[0;31m'		# Red
Green='\033[0;32m'		# Green
Blue='\033[0;34m'		# Blue
Yellow='\033[1;33m'		# Yellow
Purple='\033[0;35m'     # Purple
Cyan='\033[0;36m'       # Cyan
White='\033[0;37m'      # White
Black='\033[0;30m'      # Black

# Reset
Color_Off='\033[0m'     # Text Reset
NC='\033[0m' 			# No Color = Color_Off

# Background
On_Black='\033[40m'     # Black
On_Red='\033[41m'       # Red
On_Green='\033[42m'     # Green
On_Yellow='\033[43m'    # Yellow
On_Blue='\033[44m'      # Blue
On_Purple='\033[45m'    # Purple
On_Cyan='\033[46m'      # Cyan
On_White='\033[47m'     # White

# Bold
BBlack='\033[1;30m'      # Black
BRed='\033[1;31m'        # Red
BGreen='\033[1;32m'      # Green
BYellow='\033[1;33m'     # Yellow
BBlue='\033[1;34m'       # Blue
BPurple='\033[1;35m'     # Purple
BCyan='\033[1;36m'       # Cyan
BWhite='\033[1;37m'      # White

# Underline
UBlack='\033[4;30m'      # Black
URed='\033[4;31m'        # Red
UGreen='\033[4;32m'      # Green
UYellow='\033[4;33m'     # Yellow
UBlue='\033[4;34m'       # Blue
UPurple='\033[4;35m'     # Purple
UCyan='\033[4;36m'       # Cyan
UWhite='\033[4;37m'      # White

# Background
On_Black='\033[40m'      # Black
On_Red='\033[41m'        # Red
On_Green='\033[42m'      # Green
On_Yellow='\033[43m'     # Yellow
On_Blue='\033[44m'       # Blue
On_Purple='\033[45m'     # Purple
On_Cyan='\033[46m'       # Cyan
On_White='\033[47m'      # White

# High Intensty
IBlack='\033[0;90m'      # Black
IRed='\033[0;91m'        # Red
IGreen='\033[0;92m'      # Green
IYellow='\033[0;93m'     # Yellow
IBlue='\033[0;94m'       # Blue
IPurple='\033[0;95m'     # Purple
ICyan='\033[0;96m'       # Cyan
IWhite='\033[0;97m'      # White

# Bold High Intensty
BIBlack='\033[1;90m'     # Black
BIRed='\033[1;91m'       # Red
BIGreen='\033[1;92m'     # Green
BIYellow='\033[1;93m'    # Yellow
BIBlue='\033[1;94m'      # Blue
BIPurple='\033[1;95m'    # Purple
BICyan='\033[1;96m'      # Cyan
BIWhite='\033[1;97m'     # White

# High Intensty backgrounds
On_IBlack='\033[0;100m'  # Black
On_IRed='\033[0;101m'    # Red
On_IGreen='\033[0;102m'  # Green
On_IYellow='\033[0;103m' # Yellow
On_IBlue='\033[0;104m'   # Blue
On_IPurple='\033[10;95m' # Purple
On_ICyan='\033[0;106m'   # Cyan
On_IWhite='\033[0;107m'  # White

# Various variables you might want for your PS1 prompt instead
Time12h="\T"
Time12a="\@"
PathShort="\w"
PathFull="\W"
NewLine="\n"
Jobs="\j"

add_to_path() {
 local what2add=$1
 #- Running these two commands to add Homebrew to your PATH:
 egrep $what2add /etc/profile >/dev/null
 if [ $? -eq 1 ]; then
	echo -e "${Green}""...adding " $what2add " to PATH""${NC}"
	(echo; echo 'eval "$($what2add shellenv)"') >> /etc/profile
	  eval "$($what2add shellenv)"
	# to update your path for the remainder of the session :
	source ~/.profile 
	[ -d "$what2add" ]  && echo "export PATH=$PATH:/path/to/dir" >> /etc/profile
 else
	echo -e "${Yellow}""...path${NC}" $what2add "${Yellow}is already on PATH. Omitting this step..""${NC}"
 fi
}

own_dirs()  {
 local what2own=$1
 if [ -d "$what2own" ]; then
	echo -e "${Green}""...making the group 'sudo' the owner of the directory '$what2own'""${NC}"
	echo $password | sudo -S chgrp  -R sudo $what2own

	echo -e "${Green}""...making the root to owner of the directory '$what2own'""${NC}"
	echo $password | sudo -S chown  -R root $what2own

	echo -e "${Green}""...giving the group 'sudo' read/write access and others just read access""${NC}"
	echo $password | sudo -S chmod  -R g=rwx,o=rx $what2own
 fi
}

indie_line()  {
 local $LINE
 # for (( i = 38; i > 30; i-- )); do export j=$(expr $i + 8); export LINE=$LINE"\033[0;"$i"m#\033[1;"$i"m#\033["$j"m#"; done
 for (( i = 38; i > 30; i-- )); do export LINE=$LINE"\033[0;"$i"m#\033[1;"$i"m#"; done
 echo -e $LINE$LINE$LINE$LINE$LINE
 LINE=""
}

msg_colored() {
 local msg_kind=${$1:-'f'}
 local msg_text=${$2:-'all is OK so far'}
 echo -e "${Red}"$msg_text"${NC}"
 
 case $msg_kind in
        "e")			# error
				echo -e "${Red}${msg_text}${NC}"
                ;;
        "f")			# flow / keep in touch
				echo -e "${Green}""...${msg_text}""${NC}"
                ;;
        "i")			# information
				echo -e "${Yellow}${msg_text}${NC}"
                ;;		
        "w")			# warning
				echo -e "${Yellow}${msg_text}${NC}"
                ;;				
        *)				# nothing provided
                echo "Not a valid argument for message"
                ;;
esac
}

lets_start() {
 indie_line
 echo -e "${Green}				Let's start${NC} "
}

lets_finish() {
 local errcode=$1
 if [ $errcode -eq 0 ]; then
   indie_line
   echo -e "${On_Green}"
   echo -e "${On_Black}\n"
 else
   echo -e "${On_Red}"
   echo -e "${On_Black}\n"
   msg_colored e "Error occure. Error code="$errcode
 fi
}

cleanup() {
    echo “Trapped signal: $1”
    # script cleanup here
  }

 trap_sig() {
    for sig ; do
      trap “cleanup $sig” “$sig”
    done
  }

test_signals(){
  trap_sig INT TERM ERR EXIT PIPE
}

function do_pf() {
    MSG="$1"
    printf '%s\n' "$MSG"
}

function do_npf() {
    MSG="$1"
    printf '%s' "$MSG"
}

BLCHAR='-'
BORDER='80'

function do_bl() {
    BCHAR="$1"
    if [[ "$BCHAR" == '' ]]; then
        BCHAR="$BLCHAR"
    fi
    printf -v borderline '%*s' "$BORDER"
    echo ${borderline// /$BCHAR}
}


# func for logging:
function do_log() {
       LOGMSG="$1"
       RUNLOGFILE="$RUNLOG"
       LOGDATE=date "+%m-%d-%Y.%H%M.%N"
       printf '%s\n' "$LOGDATE|$LOGMSG" >> "$RUNLOGFILE"
}

# A typical function would utilize the logging like this:
function test_hello_any_function() {
      do_log "${FUNCNAME[0]}"
      do_pf "hello"
      }
	  
start_apache() {
 if [ -x /etc/rc.d/rc.httpd ]; then
    /etc/rc.d/rc.httpd start
 fi
}

backup_sample() {
if [ -d ./backups ]; then mv important_file ./backups/; fi
}

get-script_dir() {
 script_dir=${0%/*}
 echo $script_dir
}
get-basename() {
 basename=${0##*/}
 echo $basename
}

# If that does not exist, then try to find that library (named load.functions in that case) 
# in the path and home directory (you may add whatever you like) a
# and then include it with the source command (or mostly known as , )
exit_code() {
 if [[ type -t exit_code"" != 'funtion' ]]; then
  DIR="$HOME $(echo $PATH | tr ':' ' ' )"
  mylib=$(find "${DIR}" -type f -name load.functions -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -f2- --delimiter=' ')
  [[ -z ${mylib} || ! -f ${mylib} ]] && { echo "cannot load functions. abort"; exit 1; }
  source "${mylib}"
 else
  echo "cannot load functions. abort"
  exit 1
 fi
}

#  N.B.: This lets you put the main script logic near the top and keeps the logical flow top-to-bottom.
# main() {
  # script logic
#}
# ...
  # bottom of file
# main "$@"

# N.B.:  cd-ing to the script dir is going to break for any script which accept relative paths as arguments. 
# This can be avoided by wrapping the cd call with a pushd  popd  :
# pushd $PWD > /dev/null
#  cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
  # ...do something here
# popd > /dev/null