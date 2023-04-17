# Docksal Virtual Box (DVB)
This project is about getting local development environment based on **Docksal** (https://docksal.io) working on Windows 10 machines. Main difference of setting up Docksal on **Windows 10** comparing to default way (see [deatils](https://docs.docksal.io/getting-started/setup/#install-windows)) is sources of project are stored on virtual machine and shared to host machine through Samba. That makes improvement in performance and no dependency on WSL.

# Installation
## Prerequisites
Make sure you have installed next software:
 - **VirtualBox** (v.6.0.4), https://www.virtualbox.org/wiki/Downloads - **required**
 - **Vagrant** (v.2.2.0), https://www.vagrantup.com/downloads.html - **required**
 - **cmder** (v.1.3, minimal), http://cmder.net/ - **optional** (for accessing local virtual machine).
 
 I didn't check if DVB works with latest version of VirtualBox and Vagrant, but I assume there should be no problems with that.

## Setting Up
1. Run cmder (or other console shell) and navigate to directory where you would clone dvb sources (assuming it is `C:\dvb`) and make git clone: 
```
git clone git@github.com:olunov/dvb.git .
```
2. Install vagrant plugin for resizing virtual machine disk, run in console shell:
```
vagrant plugin install vagrant-disksize
```
3. If you have private key to be used for accessing remote servers, repositories, etc. from dev environment copy it to `C:\dvb\ssh_keys` in root directory and rename it to **id_rsa**. During installation it will be moved to home directory of vagrant user.
4. Open console shell, navigate to `C:\dvb` and run:
```
vagrant up
```
Don't close console shell untill installation will be done. During installation it may ask permissions for creating virtual network addapters in thise case click 'Yes'.

5. After finishing installation map network drive (see [details](https://support.microsoft.com/en-us/help/4026635/windows-map-a-network-drive)). Use directory `\\192.168.81.101\share`, user: `vagrant`, password: `vagrant`. You can use any letter for disk mapping, but usually I prefer to set it to "Z". After that shared directory for keeping project on virtual machine will be available on disk Z as on regular disk of your computer.

## Add new project
1. Login to virtual machine. To do that open console shell and navigate to `C:\dvb` and run `vagrant ssh`.
2. After logining to virtual machine create directory `demo` in `/www` (`mkdir /www/demo`) and navigate to it (`cd /www/demo`)
3. Run command to generate project configs: `fin config generate`. That will generate `.docksal` folder with basic configuration.
4. Run command to setup project instance: `fin project start`. That will download all container and their dependencies. 
5. On you Windows machine navigate to `c:\Windows\System32\drivers\etc\` and add to `hosts` file:
```
192.168.81.101 demo.docksal
```
6. Open `http://demo.docksal` in your browser.

For more details about installing project with docksal see [Docksal Docs](https://docs.docksal.io/getting-started/project-setup/).

## Install Site
Here will be installed Drupal 8 as example. Assuming previously here were done steps from "Add new project" section above.

1. Login to virtual machine and go to `/www/demo` directory.
2. Run command to download latest sources of Drupal8 with composer:
```
fin composer create-project drupal-composer/drupal-project:8.x-dev drupal8 --stability dev --no-interaction
```

**IMPORTANT**: this way should be considered as example (or alternative) way of installing Drupal. See more details on [drupal.org](https://www.drupal.org/docs/develop/using-composer/using-composer-to-install-drupal-and-manage-dependencies#download-core).

3. Run command to move downloaded sources from `drupal8` directory to current directory (`/www/demo`):
```
mv drupal8/* .
```
4. Let's update docroot directory for current docksal instance:
```
fin config set DOCROOT=web
```
5. Let's restart project to apply docroot. From project directory `/www/demo` run `fin up`. That will reload all projects containers.
6. Let's install Drupal site. To do that run command:
```
fin drush si --account-name=admin --account-pass=123 --site-name="Drupal 8 Site"
```
Use next credentials in order to setup DB connection:
- Database name: `default`
- Database username: `user` 
- Database password: `user`
- Database host: `db`

After finishing open `http://demo.docksal` in your browser. Use credential **admin/123** to login to new site. 

# FAQ
**Q**: What is `fin`?  
**A**: fin is set of shell commands in order to manage docksal environment and projects container. For more details see [docs](https://docs.docksal.io/fin/fin/).

**Q**: How can I install composer to docksal?  
**A**: Composer is already installed in `cli` container. Use fin to run composer, see examples below:
- `fin composer -v`
- `fin composer require 'drupal/schema_metatag:^1.3'`
- `fin composer update`

**Q**: What are default DB credentials?  
**A**: They are:
- DB name: `default`
- DB user: `user` 
- DB pass: `user`
- DB host: `db`

**IMPORTANT**: Please note **DB HOST** is `db`, not `localhost` or `127.0.0.1`.

**Q**: I forgot to copy **id_rsa** to ssh_keys directory before running `vagrant up`, and now I'm missing my ssh private key.  
**A**: To add your private key to DVB:  
1. Copy your private key to `C:\dvd\ssh_keys` and rename to `id_rsa`:
2. Login to virtual machine and run commands:
```
mv /vagrant/ssh_keys/id_rsa /home/vagrant/.ssh 
chmod 0600 /home/vagrant/.ssh/id_rsa
```

**Q**: How can I increase disk size of virtual machine to 60GB?  
**A**: Navigate to `C:\dvd` and open for editing `Vagrantfile`, update `config.disksize.size` to `60GB`, save the file and run `vagrant reload`.

**Q**: At some point my site doesn't see external hostes. For example I can't download any modules by running composer. It says it is not able to resolve hostnames.  
**A**: You can try to set `DOCKSAL_DNS_UPSTREAM` to IP address of Google's  (`8.8.8.8` or `8.8.4.4`) or CloudFlare's DNS (`1.1.1.1`). To do that open `/home/vagrant/.docksal/docksal.env` and set DOCKSAL_DNS_UPSTREAM to IP address like:
```
DOCKSAL_DNS_UPSTREAM=8.8.8.8
```
and run `fin system reset dns`. If that didn't help probably netowrk policy restricts using public DNS server. Try to update `DOCKSAL_DNS_UPSTREAM` with IP address of DNS server in your network. To get it open `cmd` and type `ipconfig /all` and find `Ethernet adapter Ethernet` (if your host machine is connected over Ethernet) or `Wireless LAN adapter Wi-Fi` (if it is connected over Wi-Fi), and you should get:
```
Ethernet adapter Ethernet:
...
   DNS Servers . . . . . . . . . . . : 22.10.0.5
                                       22.10.0.6
...
```
Use one of them to update `DOCKSAL_DNS_UPSTREAM`.  
**NOTE:** From different network (for example if you work from home) that may require to update it.  
For more details see [docs](https://docs.docksal.io/core/system-dns/#override-the-default-upstream-dns-settings).

**Q**: Will DVB work on Windows 7?  
**A**: To be honest I have not checked that. But there should be no problems with that since all of that about setting up inside of ubuntu virtual box.

**Q**: There are issues with accessing the site when host machine is connected to VPN.  
**A**: Make next steps.
1. Uncomment lines in Vagrantfile:
```
config.vm.network "forwarded_port", guest: 80, host: 8080
config.vm.network "forwarded_port", guest: 443, host: 8443
```
2. Add host (for example `sample.com`) to you host file in your host machine:
```
127.0.0.1 sample.com
```
3. Access the site over URLs: http://sample.com:8080, https://sample.com:8443 

Check https://github.com/docksal/docksal/issues/1124 for more details regarding issue of running Docksal on host machine in VPN.

**Q**: How to enable XDebug?  
**A**: Make next steps.
1. It requires to use host machine's (Windows) IP address. To get it ssh to VM and type command `who`, it should print some thing like:
`vagrant  pts/0        2023-04-17 07:20 (10.0.2.2)`
2. Add `docksal-local.yml` file in `.docksal` directory and add there:
```
services:
  cli:
    environment:
    - "XDEBUG_CONFIG=client_host=10.0.2.2 client_port=9003"
    - "XDEBUG_MODE=debug"
```
save changes.
3. Add `docksal-local.env` file in `.docksal` directory and add there:
`XDEBUG_ENABLED="1"`
save changes.
4. Run command `fin up`.
5. Enable XDebug extension in browser.
6. Enjoy.
---
For more details about configuring and using Docksal check [docs.docksal.io](https://docs.docksal.io/).

# TODO: 
- phpstorm
- code sniffer
- unit test
