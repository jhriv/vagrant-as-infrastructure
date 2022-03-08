# Vagrant as Infrastructure

Inspired by Maxim Chernyak's blog post
[6 practices for super smooth Ansible experience][6P]

The goal is to produce the convenient local playground, but skipping the ssh
key insertion (Vagrant does that for us) and editing /etc/hosts (not available
on Windows) while still allowing full access to the guest VMs.

## Makefile

[Makefile][MF] is all you need. Everything else can be downloaded automatically,
or use your own personal versions.

### Minimal Invocation

Download the [Makefile][MF], then

* `make Vagrantfile all`

or
* `vagrant init centos/7; make all`

## Requirements

* [GNU Make][M]
* [Vagrant][V]
* A provider ([VirtualBox][VB], [Parallels][PL], [VMware][VM], [etc][OP])
* [Ansible][A]
* [perl][P]

### Optional

* [curl][C]

## Usage

* `make all` does the following:
   * `make up` Brings up all Vagrant boxes (same as `vagrant up`)
   * `make roles` Install Ansible Galaxy roles from "requirements.yml" or "config/requirements.yml"
   * `make .vai/ssh-config` Create ssh configuration
   * `make .vai/inventory` Create ansible inventory
   * `make ansible.cfg` Create default ansible.cfg
   * `make main` Run main.yml playbook, if present
   * `make ip` Display the IPs of all the VMs[\*](#caveats)

Other commands:

* `make Vagrantfile` Downloads sample `Vagrantfile` and `GUESTS.rb`
* `make GUESTS.rb` Downloads sample `GUESTS.rb` (used by sample `Vagrantfile`)
* `make clean-roles` Removes installed ansible roles[\*](#caveats)
* `make clean` Removes ansible files
* `make copyright` Displays copyright information
* `make etc-hosts` Add host records to all guests
* `make license` Displays license information
* `make roles-force` Update all roles, overwriting when required
* `make ping` Pings all guests via Ansible's ping module
* `make python` Installs python on Alpine/Debian/Ubuntu systems[\*](#python)
* `make root-key` Copies vagrant ssh key for root user access
* `make update` Downloads latest version from GitHub[\*](#caveats)
* `make version` Displays installed version

## Method

* Uses a provided or downloaded `Vagrantfile` to create the application stack
  systems. See `Vagrantfile.sample` and `GUESTS.rb.sample` for a starting point.
* Install any required Galaxy roles (optional)
* Write the ssh configuration (as provided by Vagrant)
* Create `ansible.cfg` that uses the above ssh configuration

Your Ansible playbooks can now access the Vagrant VMs as if they were a part
of your infrastructure, either by name or by [group](#hosts-and-groups).

## Overrides

The Makefile will accept command line options, or read from similarly named
environmental variables:

* `ETC_HOSTS` etc-hosts playbook[\*](#caveats)
* `INVENTORY` ansible inventory file[\*](#caveats)
* `MAIN` default playbook to run, if present
* `REPO` upstream repository
* `RETRYPATH` directory to place retry files[\*](#caveats)
* `ROLES_PATH` ansible roles path
* `SAMPLEVAGRANTFILE` upstream Vagrantfile.sample
* `SSHCONFIG` location of generated ssh configuration[\*](#caveats)
* `VAIDIR` directory to place Ansible files[\*](#caveats)
* `VAULTPASSWORDFILE` path to ansible vault password file[\*](#caveats)

## Roles

If `requirements.yml` or `config/requirements.yml` exists, the listed roles
will be downloaded from Galaxy. If both exist, then `requirements.yml` will
take precedence.

## Hosts and Groups

The inventory will group related hosts into groups. Related hosts all share
the same prefix. `web-1`, `web-2`, `web-3` will all be a part of `[web]`. Only
the last suffix is considered. `web-east-1` would be in only `[web-east]`.

## etc-hosts

Update all guests' `/etc/hosts` with all other guests' internal networking IPs
to allow name-based addressing without relying on external DNS.

## Vagrantfile/GUESTS.rb

See [README.Vagrantfile][VF].

## Semantic Versioning

This project follows [SemVer][SV].

## Caveats

The `clean-roles` target will clean _all_ the roles, even ones manually
installed.

The `ip` target may fail on non-Linux guests.

The `update` target will overwrite the Makefile.

The `etc-hosts` target works best when there is only one additional interface.

Certain variables, `ETC_HOSTS`, `INVENTORY`, `ROLES_PATH`, `SSHCONFIG`,
`VAIDIR`, and `VAULTPASSWORDFILE` will break if there is embedded whitespace.

<!-- References -->
[6P]: http://hakunin.com/six-ansible-practices
[A]: https://github.com/ansible/ansible
[C]: https://curl.haxx.se/
[VF]: README.Vagrantfile.md
[MF]: Makefile
[M]: https://www.gnu.org/software/make/
[OP]: https://www.vagrantup.com/docs/providers/
[P]: https://www.perl.org/get.html
[PL]: https://www.parallels.com/
[VB]: https://www.virtualbox.org/wiki/Downloads
[V]: https://www.vagrantup.com/downloads.html
[VM]: https://www.vmware.com/
[SV]: https://semver.org/
