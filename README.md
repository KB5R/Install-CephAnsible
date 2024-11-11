# Ansible script for setting up a server for installing Ceph

**Install Ansible**
```
https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html
```
**Installing Ansible on Fedora Linux**
```
sudo dnf install ansible
```
**Installing Ansible on Ubuntu**
```
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```
**Installing Ansible on Arch Linux**
```
sudo pacman -S ansible
```
## Quick start
```
git clone https://github.com/KB5R/Install-CephAnsible
cd Install-CephAnsible
ansible-playbook install_ceph.yaml -i hosts_ansible
```
### You also need to configure the Inventory file and install_ceph.yaml
### More detailed information on setting up the playbook is in modules
