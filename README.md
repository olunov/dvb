# dvb
Docksal Virtual Box

# To resize box install plugin
vagrant plugin install vagrant-disksize
and add:
config.disksize.size = '20GB'

To export run:
vagrant package --base docksal_virtual_box --output docksal_virtual_box.box