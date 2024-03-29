# Master Makefile for Vagrant as Infrastructure.

ETC_HOSTS ?= $(VAIDIR)etc-hosts.yml
INVENTORY ?= $(VAIDIR)inventory
MAIN ?= main.yml
REPO ?= https://raw.githubusercontent.com/jhriv/vagrant-as-infrastructure
RETRYPATH ?= $(VAIDIR)retry
ROLES_PATH ?= roles
SAMPLEVAGRANTFILE ?= $(REPO)/$(VERSION)/Vagrantfile.sample
SSHCONFIG ?= $(VAIDIR)ssh-config
VAIDIR ?= .vai/
VAULTPASSWORDFILE ?= $(VAIDIR)vaultpassword
VERSION := 2.3.0
WHOAMI := $(lastword $(MAKEFILE_LIST))
.PHONY: menu \
	all \
	clean \
	clean-roles \
	copyright \
	etc-hosts \
	ip \
	license \
	main \
	ping \
	python \
	roles \
	roles-force \
	root-key \
	up \
	update \
	version \
	versions

menu:
	@echo 'up: Brings up all Vagrant boxes (same as "vagrant up")'
	@echo 'roles: Install Ansible Galaxy roles from "requirements.yml" or "config/requirements.yml"'
	@echo '$(SSHCONFIG): Create ssh configuration (SSHCONFIG)'
	@echo '$(INVENTORY): Create ansible inventory (INVENTORY)'
	@echo 'ansible.cfg: Create default ansible.cfg'
	@echo 'main: Runs the $(MAIN) playbook, if present'
	@echo 'ip: Report the IPs of all the VMs'
	@echo 'all: Do all of the above'
	@echo ''
	@echo 'clean: Removes ansible files'
	@echo 'clean-roles: Removes everything from $(ROLES_PATH)'
	@echo 'copyright: Displays copyright information'
	@echo 'etc-hosts: Add host records to all guests'
	@echo 'license: Displays license information'
	@echo 'menu: Display this menu'
	@echo 'ping: Pings all guests (via Ansible ping module)'
	@echo 'python: Installs python on Debian systems'
	@echo 'roles-force: Update all roles, overwriting when required'
	@echo 'root-key: Copies vagrant ssh key for root'
	@echo 'update: Downloads latest version from GitHub'
	@echo '        WARNING: this *will* overwrite $(WHOAMI).'
	@echo 'Vagrantfile: Downloads sample Vagrantfile and GUESTS.rb'
	@echo 'version: Displays version'
	@echo 'versions: Displays dependency versions, suitable for issue submission'

all: up roles $(SSHCONFIG) $(INVENTORY) ansible.cfg main ip

ansible.cfg: $(SSHCONFIG) $(INVENTORY)
	@echo 'Creating $@'
	@echo '[defaults]' > $@
	@echo 'inventory = $(INVENTORY)' >> $@
	@echo 'retry_files_save_path = $(RETRYPATH)' >> $@
	@echo 'roles_path = $(ROLES_PATH)-local:$(ROLES_PATH):~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles' >> $@
	@echo 'stdout_callback = debug' >> $@
	@test -f $(VAULTPASSWORDFILE) \
		&& echo 'vault_password_file = $(VAULTPASSWORDFILE)' >> $@ \
		|| true
	@echo '' >> $@
	@echo '[ssh_connection]' >> $@
	@echo 'ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -F $(SSHCONFIG)' >> $@

clean:
	@echo 'Removing ansible files'
	@rm -f ansible.cfg '$(SSHCONFIG)' '$(INVENTORY)'
	@rmdir '$(VAIDIR)' 2>/dev/null || true

clean-roles:
	@echo 'Removing local ansible roles'
	@rm -rf '$(ROLES_PATH)'/*
	@rmdir '$(ROLES_PATH)' 2>/dev/null || true

copyright:
	@echo 'Copyright 2022 John H. Robinson, IV'

$(ETC_HOSTS): $(VAIDIR)
	@echo 'Downloading $(subst $(VAIDIR),,$@)'
	@curl --silent --show-error --fail --output $@ $(REPO)/$(VERSION)/$(subst $(VAIDIR),,$@)

etc-hosts: $(ETC_HOSTS) ansible.cfg
	@ansible-playbook $<

.gitignore:
	@if [ -f $@.sample ]; then \
		echo 'Copying $@.sample'; \
		cp $@.sample $@; \
	else \
		echo 'Downloading $@'; \
		curl --silent --show-error --fail --output $@ $(REPO)/$(VERSION)/$@.sample; \
	fi

# Because of the pipe, extraordinary means have to be used to save the return
# code of "vagrant status"
$(INVENTORY): $(wildcard .vagrant/machines/*/*/id) $(VAIDIR)
	@echo 'Creating $@'
	@( ( ( vagrant status; echo $$? >&3 ) \
		|  perl -x $(WHOAMI) > $@ ) 3>&1 ) \
		|  ( read x; exit $$x ) \
		|| ( RET=$$?; rm $@; exit $$RET )

_IP_CMD=/sbin/ip -family inet address show scope global up \
	| awk "BEGIN {FS=\"[ /]+\"} /inet/{print \$$3}"
ip: ansible.cfg
	@ansible all --module-name=shell --args='$(_IP_CMD)' \
		|| { ret=$$?; \
			echo 'Do you need to install python? (make python)'; \
			exit $$ret; \
		}

license:
	@curl --silent --show-error --fail $(REPO)/$(VERSION)/LICENSE

main: ansible.cfg
	@test -f '$(MAIN)' \
		&& { ansible-playbook '$(MAIN)' || exit $$?; } \
		|| echo 'No $(MAIN) present, skipping.'

ping: ansible.cfg
	@ansible -m ping all

python: ansible.cfg
	@ansible all \
		--module-name=raw \
		--args='command -v apt-get &>/dev/null \
			&& ( sudo apt-get update; \
				apt-cache show python3 >/dev/null \
					&& sudo apt-get install --assume-yes python3 \
					|| sudo apt-get install --assume-yes python python-apt ) \
			|| ( command -v apk &> /dev/null \
				&& ( sudo apk update; \
					sudo apk add python3 ) \
			) || true'

roles: $(wildcard requirements.yml config/requirements.yml)
	@echo 'Downloading roles'
	@ansible-galaxy install --role-file=$< --roles-path='$(ROLES_PATH)'

roles-force: $(wildcard requirements.yml config/requirements.yml)
	@echo 'Downloading roles (forced)'
	@ansible-galaxy install --role-file=$< --roles-path='$(ROLES_PATH)' --force

root-key: ansible.cfg
	@ansible all \
		--become \
		--module-name=file \
		--args='dest=/root/.ssh state=directory mode=0700 owner=root group=root'
	@ansible all \
		--become \
		--module-name=copy \
		--args='src=.ssh/authorized_keys dest=/root/.ssh/authorized_keys remote_src=true'

# Only get the configs of running boxes. If no boxes, exist, call "up" target
$(SSHCONFIG): $(wildcard .vagrant/machines/*/*/id) $(VAIDIR)
# "test -f" returns true; wildcard returns empy if nothing matches;
# appending / (which will never be a file) ensures failure if no vagrant
# boxes exist, in any state
# No running vagrant boxes still results in an error
	@test -f $(firstword $(wildcard .vagrant/machines/*/*/id) / ) || $(MAKE) up
	@echo 'Creating $@'
# We lose the status of "vagrant status". Oh, the irony.
	@vagrant ssh-config $$( vagrant status | grep ' running ' | awk '{print $$1}' ) > $@ \
		|| ( RET=$$?; rm $@; exit $$RET; )

up:
	@vagrant up

update:
	@echo 'Downloading latest Makefile'
	@curl --silent --show-error --fail --output $(WHOAMI) $(REPO)/master/Makefile

Vagrantfile: | GUESTS.rb
Vagrantfile GUESTS.rb:
	@if [ -f $@.sample ]; then \
		echo 'Copying $@.sample'; \
		cp $@.sample $@; \
	else \
		echo 'Downloading $@'; \
		curl --silent --show-error --fail --output $@ $(REPO)/$(VERSION)/$@.sample; \
	fi

$(VAIDIR):
	@mkdir $(VAIDIR)

version:
	@echo '$(VERSION)'

versions:
	@echo "- Version: $$($(MAKE) version 2>/dev/null || echo Unknown)"
	@echo "- Platform: $$(uname -s -r 2>/dev/null || echo Unknown)"
	@echo "- Make version: $$({ $(MAKE) --version 2>/dev/null || echo Unknown; } | head -1)"
	@echo "- Vagrant version: $$(vagrant -v 2>/dev/null || echo Unknown)"
	@echo "- VirtualBox version: $$(VBoxManage -v 2>/dev/null || echo N/A)"

ifeq (1,2) # perl script to convert vagrant status to ansible inventory, with groups
# ifeq is used to prevent make(1) from interpreting the perl script
# use "vagrant status | perl -x Makefile" to test

#!/usr/bin/env perl
use v5.10;

while (<>) {
  # adds all box names to @i; names are the first word of second paragraph
  # boxes are collected, despite state (running, poweroff, not created)
  if (/^$/.../^$/) {
    push @i, qq($1) if /^(\S+)/;
  }
}

# using a hash as an ad-hoc uniq
# find all box names with a dash or underscore, strip the trailing
# suffix(es) off, add to group names
@u=@i;
while (@u) {
  $_ = shift @u;
  if (/^(\S+)[-_]/) {
    ($_=$1) =~ tr/-/_/; # "-" in ansible group names is illegal, convert to "_"
    $g{$_} = 1;
    unshift (@u, $_) if (/\S+_/); # more processing if more suffixes left
  }
}

map { say } sort @i; # displays sorted box names, one record per line

# for every group, display it and all boxes with that prefix, mindful of - -> _
for $g (sort keys %g) {
  ($r = $g) =~ s/_/[-_]/g; # box names don't get the - -> _ conversion
  say qq(\n[$g]\n), join ( qq(\n), grep { /^$r[-_]/ } @i );
}

__END__

endif
