# Set up development environment with Ansible and Vagrant

## Contents
* Use VirtualBox as provider
* Set up desktop or server via [config.yaml](config.yaml)
* Provisioning with Ansible

## Dependencies
* [vagrant-proxyconf](https://github.com/tmatilai/vagrant-proxyconf)

## Configuration
For local execution use:
```bash
$ ansible-playbook --inventory localhost, --connection local setup.yml
```

