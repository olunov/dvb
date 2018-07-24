# dvb
Docksal Virtual Box

# To resize box install plugin
vagrant plugin install vagrant-disksize
# and add:
config.disksize.size = '20GB'

# To export:
# Login to VB:
vagrant ssh
# Assign exec permissions to scripts/pre-pack.ssh
chmod +x /vagrant/scripts/pre-pack.ssh
# Run scripts/pre-pack.ssh
bash /vagrant/scripts/pre-pack.ssh
# Exit VB by Ctrl+D or type exit in the shell.
vagrant package --base docksal_virtual_box --output docksal_virtual_box.box

# To check available virtual boxes.
vagrant box list

# To delete virtualbox image.
vagrant box remove <virtualbox-image-name>

# To refresh VirtualBox image

# Debug ssh
vagrant ssh -- -vvv

# To browse docksal docker containers
https://hub.docker.com/r/docksal/

# To generate sha256sum for file.
sha256sum docksal_virtual_box-v0.2.box > sha256sum.txt
