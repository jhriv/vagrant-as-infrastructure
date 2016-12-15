# Vagrant as Infrastructure


Inspired by Maxim Chernyak's blog post [6 practices for super smooth Ansible experience](http://hakunin.com/six-ansible-practices).

The goal is to produce the convenient local playground, but skipping the ssh key insertion (Vagrant does that for us) and editing /etc/hosts (not available on Windows) but still allowing full access to the guest VMs.

## Method:

* Requires a `Vagrantfile` that creates the application stack systems
  See `Vagrant.sample` for a starting point.
* Install any required Galaxy roles (optional)
* Write out the ssh configuration (provided by Vagrant)
* Create an `ansible.cfg` that uses the above ssh configuration
* Prints out the private IP address of the VMs

## Roles

If `roles.yml` or `config/roles.yml` exists, the listed roles will be downloaded from Galaxy. If both exist, then `roles.yml` will take precedence.

## Special Notes

Ubuntu Xenial has significantly changed, so setting a private network IP fails. Trusty and Precise still work.
