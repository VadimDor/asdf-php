#!/bin/sh

#https://askubuntu.com/questions/1455037/what-does-set-eu-do-in-a-bash-script#:~:text=1%20Answer&text=%2De%20Exit%20immediately%20if%20a,with%20a%20non%2Dzero%20status.
# that means not continue on any error or any variable was not set
set -eu
#set -euo pipefail

. "$(dirname "$(dirname "$0")")/utils.sh"
# or another way - see https://stackoverflow.com/questions/192292/how-best-to-include-other-scripts
# source "$( dirname "${BASH_SOURCE[0]}" )/utils.sh"

lets_start 
curl -fsSL https://coder.com/install.sh | sh -s --
#  see https://coder.com/docs/code-server/latest/guide#expose-code-server
# SSH into your instance and edit the code-server config file to disable password authentication:

CONFIG_CS=~/.config/code-server/config.yaml

if [ ! -f "$CONFIG_CS" ]; then
[ ! -d "$(dirname $CONFIG_CS)" ] && mkdir "$(dirname $CONFIG_CS)"
touch $CONFIG_CS
cat << 'EOF' | sudo tee -a $CONFIG_CS >> /dev/null
bind-addr: 127.0.0.1:8080
auth: none
password: randompwd222 # Randomly generated for each config.yaml
cert: false
EOF
else 
 msg_colored f Replacing "auth: password" with "auth: none" in the code-server config.
 sed -i.bak 's/auth: password/auth: none/' "$CONFIG_CS"
fi

# Re/start code-server:
#[ ! -z "$(sudo systemctl restart code-server@$USER | grep "Unit code-server@$USER.service not found" )" ] && 
# [ service --status-all 2>&1 | grep -Fq code-server@$USER ] && \
    # sudo systemctl restart code-server@$USER || coder
set +e	-u
[ service --status-all 2>&1 | grep -Fq "coder.service"] && \
    sudo systemctl restart coder.service || coder server
error=$?
[ ! $error -eq 0 ] && echo Some error occured, exit code=$error	

# Start Coder now and on reboot
  # $ sudo systemctl enable --now coder
  # $ journalctl -u coder.service -b
# Or just run the server directly
  # $ coder server	
# sudo systemctl enable --now code-server@$USER
lets_finish $error
