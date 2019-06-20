# Docksal Virtual Box (DVB)
This project is about getting local development environment based on __Docksal__ (https://docksal.io) working on Windows 10 machines. Main difference of setting up Docksal on Windows 10 comparing to default way (see [deatils](https://docs.docksal.io/getting-started/setup/#install-windows)) is sources of project are stored on virtual machine and shared to host machine through Samba. 

# Installation
## Prerequisites
Make sure you have installed next software:
 - **VirtualBox** (v.6.0.4), https://www.virtualbox.org/wiki/Downloads - **required**
 - **Vagrant** (v.2.2.0), https://www.vagrantup.com/downloads.html - **required**
 - **cmder** (v.1.3, minimal), http://cmder.net/ - optional (for accessing local virtual machine)
 
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
3. If you have private key to be used for accessing remote servers, repositories, etc. from dev environment copy it to `C:\dvb\ssh_keys` in root directory and rename it to __id_rsa__. During installation it will be moved to home directory of vagrant user.
4. Open console shell, navigate to `C:\dvb` and run:
```
vagrant up
```
Don't close console shell untill installetion will be done. During installetion it may ask permissions for creating virtual network addapters in thise case click 'Yes'.

5. After finishing installetion map network drive (see [details](https://support.microsoft.com/en-us/help/4026635/windows-map-a-network-drive)). Use directory `\\192.168.81.101\share`, user: `vagrant`, password: `vagrant`. You can use any letter for disk mapping, but usually I prefer to set it to "Z". After that sahred directory for keeping project on virtual machine will be available on disk Z as on regular disk of you computer.

## Add new project
1. Login to virtual machine. To do that open console shell and navigate to `C:\dvb` and run `vagrant ssh`.
2. After logining to virtual machine create directory `demo` in `/www` (`mkdir /www/demo`) and navigate to it (`cd /www/demo`)
3. Run command to generate project configs: `fin config generate`. That will generate `.docksal` folder with basic configuration.
4. Run command to setup project instance: `fin project start`. That will download all container and their dependencies. New site will be available on `http://demo.docksal` by default.
5. On you Windows machine navigate to `c:\Windows\System32\drivers\etc\` and add to `hosts` file:
```
192.168.81.101 demo.docksal
```
6. Open `http://demo.docksal` in your browser.

For more details about installing project with docksal see [Docksal Docs](https://docs.docksal.io/getting-started/project-setup/).


# FAQ
- fin
- running composer
- db credentials
- How to copy/update id_rsa
- Resize disk size, config.disksize.size = '20GB'
- DOCKSAL_DNS_UPSTREAM=18.8.0.3
 To use Local network DNS server add this line to ~/.docksal/docksal.env.
- Setting up on Windows 7

# TODO:
- Xdebug, port forwarding