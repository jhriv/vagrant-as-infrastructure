# Master Makefile for Vagrant as Infrastructure.

ETC_HOSTS ?= .etc-hosts.yml
INVENTORY ?= .inventory
MAIN ?= main.yml
REPO ?= https://raw.githubusercontent.com/jhriv/vagrant-as-infrastructure
RETRYPATH ?= .ansible-retry
ROLES_PATH ?= roles
SAMPLEVAGRANTFILE ?= $(REPO)/$(VERSION)/Vagrantfile.sample
SSHCONFIG ?= .ssh-config
VAULTPASSWORDFILE ?= .vaultpassword
VERSION := 1.3.4
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
	version

menu:
	@echo 'up: Brings up all Vagrant boxes (same as "vagrant up")'
	@echo 'roles: Install Ansible Galaxy roles from "roles.yml" or "config/roles.yml"'
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

all: up roles $(SSHCONFIG) $(INVENTORY) ansible.cfg main ip

ansible.cfg: $(SSHCONFIG) $(INVENTORY)
	@echo 'Creating $@'
	@echo '[defaults]' > $@
	@echo 'inventory = $(INVENTORY)' >> $@
	@echo 'retry_files_save_path = $(RETRYPATH)' >> $@
	@echo 'roles_path = $(ROLES_PATH)' >> $@
	@test -f $(VAULTPASSWORDFILE) \
		&& echo 'vault_password_file = $(VAULTPASSWORDFILE)' >> $@ \
		|| true
	@echo '' >> $@
	@echo '[ssh_connection]' >> $@
	@echo 'ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -F $(SSHCONFIG)' >> $@

clean:
	@echo 'Removing ansible files'
	@rm -f ansible.cfg $(SSHCONFIG) $(INVENTORY)

clean-roles:
	@echo 'Removing local ansible roles'
	@rm -rf '$(ROLES_PATH)'/*

copyright:
	@echo 'Copyright 2016-2018 John H. Robinson, IV'

$(ETC_HOSTS):
	@echo 'Downloading $@'
	@curl --silent --show-error --output $@ $(REPO)/$(VERSION)/$@

etc-hosts: $(ETC_HOSTS) ansible.cfg
	@ansible-playbook $<

# Because of the pipe, extraordinary means have to be used to save the return
# code of "vagrant status"
$(INVENTORY): $(wildcard .vagrant/machines/*/*/id)
	@echo 'Creating $@'
	@( ( ( vagrant status; echo $$? >&3 ) \
		|  perl -x $(WHOAMI) > $@ ) 3>&1 ) \
		|  ( read x; exit $$x ) \
		|| ( RET=$$?; rm $@; exit $$RET )

ip: ansible.cfg
	@ansible all --args='hostname -I' \
		|| { ret=$$?; \
			echo 'Do you need to install python? (make python)'; \
			exit $$ret; \
		}

license:
	@curl --silent --show-error $(REPO)/$(VERSION)/LICENSE

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
			     sudo apt-get install --assume-yes python python-apt ) \
			|| true'

roles: $(wildcard roles.yml config/roles.yml)
	@echo 'Downloading roles'
	@ansible-galaxy install --role-file=$< --roles-path='$(ROLES_PATH)'

roles-force: $(wildcard roles.yml config/roles.yml)
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
$(SSHCONFIG): $(wildcard .vagrant/machines/*/*/id)
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
	@curl --silent --show-error --output $(WHOAMI) $(REPO)/master/Makefile

Vagrantfile: | GUESTS.rb
Vagrantfile GUESTS.rb:
	@if [ -f $@.sample ]; then \
		echo 'Copying $@.sample'; \
		cp $@.sample $@; \
	else \
		echo 'Downloading $@'; \
		curl --silent --show-error --output $@ $(REPO)/$(VERSION)/$@.sample; \
	fi

version:
	@echo '$(VERSION)'

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
# find all records in @i with a dash, strip the trailing -suffix off, add to %g
%g = map { $_=>1 } ( map {/^(\S+)-/} @i );

map { say } sort @i; # displays sorted @i, one record per line

# for every %g (group), display it and all boxes with that prefix
for $g (sort keys %g) {
  say qq(\n[$g]\n), join ( qq(\n), grep { /^$g-/ } @i );
}

__END__

endif
