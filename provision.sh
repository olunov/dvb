USER_NAME=vagrant
USER_PASSWORD=vagrant
WORKING_DIR=/www

# Run Linux updates
sudo apt-get update -y

# Setting up unitils.
sudo apt-get install curl mc zip tar htop hashalot -y

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

# Setup Docsal.
su $USER_NAME -c 'curl -fsSL https://get.docksal.io | sh'

# To apply that change and use Docksal.
su $USER_NAME -c 'newgrp docker'

# add proxy settings.
echo 'DOCKSAL_VHOST_PROXY_IP="0.0.0.0"' >> /home/$USER_NAME/.docksal/docksal.env

# Disable DNS resolver.
echo 'DOCKSAL_NO_DNS_RESOLVER=true' >> /home/$USER_NAME/.docksal/docksal.env

# Reset proxy.
su $USER_NAME -c 'fin reset proxy'

# pulling docksal containers to cach them localy
docker pull docksal/db:1.1-mysql-5.6
docker pull docksal/cli:1.3-php7
docker pull docksal/cli:1.3-php5
docker pull docksal/web:2.1-apache2.4
