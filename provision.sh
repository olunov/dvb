#!/bin/bash

USER_NAME=vagrant
USER_PASSWORD=vagrant
WORKING_DIR=/www

# Run Linux updates
sudo apt-get update -y

# Setting up unitils.
sudo apt-get install curl mc zip tar htop hashalot nmap -y

# Creating working directory.
sudo mkdir $WORKING_DIR
sudo chown ${USER_NAME}:${USER_NAME} $WORKING_DIR
sudo chmod 0755 $WORKING_DIR

# Setting samba server.
sudo apt-get install samba -y

# Update samba settings file.
sudo chown root:root /etc/samba/smb.conf
sudo cat <<EOF >> /etc/samba/smb.conf
[share]
   comment = work storage
   path = ${WORKING_DIR}
   browseable = yes
   read only = no
   quest ok = no
   create mask = 0755
EOF

# Add samba user
(echo "$USER_PASSWORD"; echo "$USER_PASSWORD") | smbpasswd -s -a $USER_NAME

# Restart samba server.
sudo service smbd stop
sudo service smbd start

# If id_rsa exists in ssh_keys move it to vagrant user .ssh directory.
SSH_KEY=/vagrant/ssh_keys/id_rsa
if [ -f ${SSH_KEY} ]; then
   mv ${SSH_KEY} /home/${USER_NAME}/.ssh
   chmod 0600 /home/${USER_NAME}/.ssh/id_rsa
fi

# Setup Docsal.
su $USER_NAME -c 'curl -fsSL https://get.docksal.io | sh'

# To apply that change and use Docksal.
su $USER_NAME -c 'newgrp docker'

# add proxy settings.
echo 'DOCKSAL_VHOST_PROXY_IP="0.0.0.0"' >> /home/$USER_NAME/.docksal/docksal.env

# Disable DNS resolver.
echo 'DOCKSAL_NO_DNS_RESOLVER=true' >> /home/$USER_NAME/.docksal/docksal.env

# Reset proxy.
su $USER_NAME -c 'fin system reset'

# Enable color prompt support.
BASHRC=/home/$USER_NAME/.bashrc

# Use sed to remove the comment from the force color line in the .bashrc file.
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' $BASHRC

# Install bash git prompt.
#git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1
su $USER_NAME -c "git clone https://github.com/magicmonty/bash-git-prompt.git /home/$USER_NAME/.bash-git-prompt --depth=1"

echo 'GIT_PROMPT_THEME=Crunch' >> $BASHRC
echo 'GIT_PROMPT_ONLY_IN_REPO=1' >> $BASHRC
echo 'source ~/.bash-git-prompt/gitprompt.sh' >> $BASHRC

# Reload the .bashrc file
source $BASHRC
