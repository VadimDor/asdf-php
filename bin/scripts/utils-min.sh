#!/bin/sh

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
