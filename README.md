# Vagrant as Infrastructure

Inspired by Maxim Chernyak's blog post [6 practices for super smooth Ansible experience](http://hakunin.com/six-ansible-practices).

The goal is to produce the convenient local playground, but skipping the ssh key insertion (Vagrant does that for us) and editing /etc/hosts (not available on Windows) but still allowing full access to the guest VMs.

## Requirements:

* GNU Make
* Vagrant
* A provider (VirtualBox, VMware, etc)

## Method:

* Uses a provided or downloaded `Vagrantfile` to create the application stack systems.
  See `Vagrantfile.sample` for a starting point.
* Install any required Galaxy roles (optional)
* Write the ssh configuration (as provided by Vagrant)
* Creates `ansible.cfg` that uses the above ssh configuration
* Displays the IP address of the VMs

## Roles

If `roles.yml` or `config/roles.yml` exists, the listed roles will be downloaded from Galaxy. If both exist, then `roles.yml` will take precedence.

## Caveats:

The `clean-roles` target will clean _all_ the roles, even ones manually installed.

The `ip` target may fail on non-Linux guests.
