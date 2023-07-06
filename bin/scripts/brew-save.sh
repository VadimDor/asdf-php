#!/bin/bash

ASDF_HOME=${HOME}/.asdf/shims

#    .---------- constant part!
#    vvvv vvvv-- the code from above
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

add_to_path() {
 local what2add=$1
 #- Running these two commands to add Homebrew to your PATH:
 egrep $what2add /etc/profile >/dev/null
 if [ $? -eq 1 ]; then
	echo -e "${GREEN}""...adding " $what2add " to PATH""${NC}"
	(echo; echo 'eval "$($what2add shellenv)"') >> /etc/profile
	  eval "$($what2add shellenv)"
	# to update your path for the remainder of the session :
	source ~/.profile 
	[ -d "$(what2add)" ]  && echo "export PATH=$PATH:/path/to/dir" >> /etc/profile
 else
	echo -e "${YELLOW}""...path${NC}" $what2add "${YELLOW}is already on PATH. Omitting this step..""${NC}"
 fi
}

own_brew()  {
 echo -e "${GREEN}""...making the group 'sudo' the owner of the directory '/home/linuxbrew/.linuxbrew'""${NC}"
 echo $password | sudo -S chgrp  -R sudo /home/linuxbrew/.linuxbrew

 echo -e "${GREEN}""...giving the group 'sudo' read/write access and others just read access""${NC}"
 echo $password | sudo -S chmod  -R g=rwx,o=rx /home/linuxbrew/.linuxbrew
}


# for (( i = 38; i > 30; i-- )); do export j=$(expr $i + 8); export LINE=$LINE"\033[0;"$i"m#\033[1;"$i"m#\033["$j"m#"; done
for (( i = 38; i > 30; i-- )); do export LINE=$LINE"\033[0;"$i"m#\033[1;"$i"m#"; done
echo -e $LINE$LINE$LINE$LINE$LINE$LINE
echo -e '\033[40m'
 
echo -e "${GREEN}				Let's start${NC} "


# ------------------------------------------------------------------
# Am i Root user?
if [ $(id -u) -eq 0 ]; then
	#read -p "Enter username : " username
	#read -s -p "Enter password : " password
        username="temporal#user"
        password="temporal#password_kjbvwjhbvhjbeqjnfw"

	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo echo -e "${RED}""user $username exists!""${NC}"
		exit 1
	else
                sudo apt -y install perl  # mostly already installed by default but anyway
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p "$pass" "$username"
		if [ $? -eq 0 ]; then
                 echo -e "${GREEN}""...user $username has been added to system${NC}"
                 usermod -aG sudo "$username" 
		 getent group sudo | grep "$username"
		 echo -e "${GREEN}""...checking that $username user was added:""${NC}"
		 cat /etc/passwd | grep "$username"
		 id "$username" | grep sudo 

		 add_to_path "/home/linuxbrew/.linuxbrew/bin"

		 # https://en.wikipedia.org/wiki/Here_document   :

		 # see https://stackoverflow.com/questions/1988249/how-do-i-use-su-to-execute-the-rest-of-the-bash-script-as-that-user
		 echo -e "${GREEN}""...executing this part of the bash script as non root user""${NC}"

		 own_brew

		 sudo -i -u "$username" bash <<-EOS
		 echo -e "${GREEN}""...entering subshell as:" &&  whoami && echo -e "${NC}"

		 echo -e "${GREEN}""...checking sudo rights for $username""${NC}"
		 echo $password | sudo -S -v
		 #echo $password | sudo -S su "$username"

		 wget https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh && chmod +x install.sh
		 echo $password | sudo -S sleep 2 && sudo ./install.sh 

		 #echo $password | sudo -S sleep 2 && sudo /bin/bash -c "sudo $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
 
						EOS

		 echo -e "${GREEN}""...exited subshell as $(whoami)""${NC}"

		 echo -e "${YELLOW}""==> Homebrew has enabled anonymous aggregate formulae and cask analytics""${NC}"
		 echo -e "${YELLOW}""==> Read the docu and how to opt-out here:  https://docs.brew.sh/Analytics""${NC}"

		 #==> Next steps:
		 add_to_path "/home/linuxbrew/.linuxbrew/bin/brew"
		 echo -e "${GREEN}""...installing Homebrew's dependencies:""${NC}"
		    sudo apt-get install build-essential

		 echo -e "${YELLOW}""==> For more information, see: https://docs.brew.sh/Homebrew-on-Linux""${NC}"
		 echo -e "${YELLOW}""==> We recommend that you install GCC:    brew install gcc""${NC}"

		 # see https://devconnected.com/how-to-add-and-delete-users-on-debian-10-buster/
		 echo -e "${GREEN}""...deleting the temporal user""${NC}"
		 sudo deluser  --remove-home "$username"   #NOT --remove-all-files !!
		 #sudo visudo
		 # cat /etc/sudoers|grep "$username"
		 egrep "^$username" /etc/sudoers >/dev/null
		 if [ $? -eq 0 ]; then
			echo -e "${RED}""If you removed a sudo user on Debian, it is very likely that there is a remaining entry in your sudoers file!""${NC}"
			echo -e "${RED}""You will change this script to delete this entry in /etc/sudoers then""${NC}"
			exit 1
		 fi

		 own_brew

		 echo -e $LINE$LINE$LINE$LINE$LINE$LINE			 

                else 
                 echo -e "${RED}""Failed to add a user!""${NC}"
                fi
	fi
else
	echo -e "${RED}""Only root may add a user to the system.""${NC}"
	exit 2
fi

echo
  

