# Vagrant as Infrastructure

Inspired by Maxim Chernyak's blog post [6 practices for super smooth Ansible experience](http://hakunin.com/six-ansible-practices).

The goal is to produce the convenient local playground, but skipping the ssh
key insertion (Vagrant does that for us) and editing /etc/hosts (not available
on Windows) but still allowing full access to the guest VMs.

## Requirements

* GNU Make
* Vagrant
* A provider (VirtualBox, VMware, etc)
* Ansible
* perl

### Optional

* curl

## Usage

* `make all` does the following:
   * `make up` Brings up all vagrant boxes
   * `make roles` Populate Galaxy roles from "roles.yml" or "config/roles.yml"
   * `make ansible.cfg` Create default ansible.cfg
   * `make .ssh-config` Create ssh configuration
   * `make .inventory` Create ansible inventory
   * `make main` Run main.yml playbook, if present
   * `make ip` Display the IPs of all the VMs

Other commands:

* `make Vagrantfile` Downloads sample Vagrantfile and GUESTS.rb
* `make clean-roles` Removes installed ansible roles
* `make clean` Removes ansible files
* `make copyright` Displays copyright information
* `make etc-hosts` Add host records to all guests
* `make license` Displays license information
* `make roles-force` Update all roles, overwriting when required
* `make ping` Pings all guests via Ansible's ping module
* `make python` Installs python on Debian systems
* `make root-key` Copies vagrant ssh key for root
* `make update` Downloads latest version from GitHub
* `make version` Displays current version

## Method

* Uses a provided or downloaded `Vagrantfile` to create the application stack
  systems. See `Vagrantfile.sample` and `GUESTS.rb.sample` for a starting point.
* Install any required Galaxy roles (optional)
* Write the ssh configuration (as provided by Vagrant)
* Creates `ansible.cfg` that uses the above ssh configuration
* Displays the IP address of the VMs

## Overrides

The Makefile will accept command line arguments, or read from similarly named
environmental variables:

* `ETC_HOSTS` etc-hosts playbook
* `INVENTORY` ansible inventory file
* `MAIN` default playbok to run, if present
* `REPO` upstream repository
* `RETRYPATH` directory to play .retry files
* `ROLES_PATH` ansible roles path
* `SAMPLEVAGRANTFILE` upstream Vagrantfile.sample
* `SSHCONFIG` location of generated ssh configuration
* `VAULTPASSWORDFILE` path to ansible vault password file

## Roles

If `roles.yml` or `config/roles.yml` exists, the listed roles will be
downloaded from Galaxy. If both exist, then `roles.yml` will take precedence.

## Hosts and Groups

The inventory will group related hosts into groups. Related hosts all share
the same prefix. `web-1`, `web-2`, `web-3` will all be a part of `[web]`. Only
the last suffix is considered. `web-east-1` would be in only `[web-east]`.

## etc-hosts

Update all guests' `/etc/hosts` with all other guests' internal networking IPs
to allow name-based addressing without relying on external DNS.

## Caveats

The `clean-roles` target will clean _all_ the roles, even ones manually
installed.

The `ip` target may fail on non-Linux guests.

The `update` target will overwrite the Makefile.

The `etc-hosts` target works best when there is only one additional interface.

Certain variables, `ETC_HOSTS`, `INVENTORY`, and `SSHCONFIG`, will break if
there is embedded whitespace.
