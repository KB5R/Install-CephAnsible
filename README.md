# Ansible script for setting up a server for installing Ceph

## Quick start
**Install Ansible**
`https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html`

```
git clone https://github.com/KB5R/Install-CephAnsible
cd Install-CephAnsible
ansible-playbook install_ceph.yaml -i hosts_ansible
```
### You also need to configure the Inventory file and update_sysctl.yaml
