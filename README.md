# Set up development environment with Ansible and Vagrant

## Contents
* Use VirtualBox as provider
* Set up desktop or server via [config.yaml](config.yaml)
* Provisioning with Ansible

## Dependencies
* [vagrant-proxyconf](https://github.com/tmatilai/vagrant-proxyconf)

## Configuration
For local execution append Ansible hosts:
```
# /etc/ansible/hosts
localhost ansible_connection=local
```

