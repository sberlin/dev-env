# Set up development environment with Vagrant

## Contents
* Vagrant base box is **bento/ubuntu-17.04** in [Vagrantfile](Vagrantfile)
* Use VirtualBox as provider
* Set up desktop or server via [config.yaml](config.yaml)
* System provisioning with [bootstrap.sh](bootstrap.sh)
* User provisioning with [bootstrap-user.sh](bootstrap-user.sh)

### System setup
* Install common applications and guest additions
* Set locale, keyboard layout and timezone

### User setup
* Create user, set password and add to the same groups as vagrant
* Create directories `git` and `opt` at `/opt/workspace/<username>`
* Download a zip file containing a `makefile`
  * with target `install` to apply further configurations
  * with configurable target to apply configurations for a desktop

## Dependencies
* [vagrant-proxyconf](https://github.com/tmatilai/vagrant-proxyconf)
* [vagrant-reload](https://github.com/aidanns/vagrant-reload)
