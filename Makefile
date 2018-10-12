# Master Makefile for Vagrant as Infrastructure.

ETC_HOSTS ?= .etc-hosts.yml
INVENTORY ?= .inventory
REPO ?= https://raw.githubusercontent.com/jhriv/vagrant-as-infrastructure
RETRYPATH ?= .ansible-retry
ROLES_PATH ?= roles
SAMPLEVAGRANTFILE ?= $(REPO)/$(VERSION)/Vagrantfile.sample
SSHCONFIG ?= .ssh-config
VAULTPASSWORDFILE ?= .vaultpassword
VERSION := 0.6.1
WHOAMI := $(lastword $(MAKEFILE_LIST))
.PHONY: menu all clean clean-roles up roles force-roles Vagrantfile-force ping ip update version

menu:
	@echo 'up: Create VMs'
	@echo 'roles: Populate Galaxy roles from "roles.yml" or "config/roles.yml"'
	@echo 'ansible.cfg: Create default ansible.cfg'
	@echo '$(SSHCONFIG): Create ssh configuration (use "make <file> SSHCONFIG=<file>" to override name)'
	@echo '$(INVENTORY): Create ansible inventory (use "make <file> INVENTORY=<file>" to overrride name)'
	@echo 'ip: Display the IPs of all the VMs'
	@echo 'all: Create all of the above'
	@echo
	@echo '"make all SSHCONFIG=sshconf INVENTORY=ansible-inv"'
	@echo ''
	@echo 'python: Installs python on Debian systems'
	@echo 'ping: Pings all guests (via Ansible ping module)'
	@echo 'root-key: Copies vagrant ssh key for root'
	@echo 'clean: Removes ansible files'
	@echo 'clean-roles: Removes installed ansible roles'
	@echo 'force-roles: Update all roles, overwriting when required'
	@echo 'etc-hosts: Add host records to all guests'
	@echo 'Vagrantfile: Downloads sample Vagrantfile and GUESTS.rb'
	@echo 'version: Prints current version'
	@echo 'update: Downloads latest version from github'
	@echo '        WARNING: this *will* overwrite $(WHOAMI).'

all: up roles ansible.cfg $(SSHCONFIG) $(INVENTORY) ip

clean:
	@echo 'Removing ansible files'
	@rm -f ansible.cfg $(SSHCONFIG) $(INVENTORY)

clean-roles:
	@echo 'Removing local ansible roles'
	@rm -rf $(ROLES_PATH)/*

up:
	@vagrant up

roles: $(wildcard roles.yml config/roles.yml)
	@echo 'Downloading roles'
	@ansible-galaxy install --role-file=$< --roles-path=$(ROLES_PATH)

force-roles: $(wildcard roles.yml config/roles.yml)
	@echo 'Downloading roles (forced)'
	@ansible-galaxy install --role-file=$< --roles-path=$(ROLES_PATH) --force

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

$(SSHCONFIG): $(wildcard .vagrant/machines/*/*/id)
	@echo 'Creating $@'
	@vagrant ssh-config > $@ \
		|| ( RET=$$?; rm $@; exit $$RET; )

# Because of the pipe, extraordinary means have to be used to save the return
# code of "vagrant status"
$(INVENTORY): $(wildcard .vagrant/machines/*/*/id)
	@echo 'Creating $@'
	@( ( ( vagrant status; echo $$? >&3 ) \
		|  perl -x $(WHOAMI) > $@ ) 3>&1 ) \
		|  ( read x; exit $$x ) \
		|| ( RET=$$?; rm $@; exit $$RET )

Vagrantfile: | GUESTS.rb
Vagrantfile GUESTS.rb:
	@if [ -f $@.sample ]; then \
		echo 'Copying $@.sample'; \
		cp $@.sample $@; \
	else \
		echo 'Downloading $@'; \
		curl --silent --show-error --output $@ $(REPO)/$(VERSION)/$@.sample; \
	fi

ping: ansible.cfg
	@ansible -m ping all

ip: ansible.cfg
	@ansible all --args='hostname -I' \
		|| { ret=$$?; \
			echo 'Do you need to install python? (make python)'; \
			exit $$ret; \
		}

python: ansible.cfg
	@ansible all \
		--module-name=raw \
		--args='sudo apt-get update; \
			sudo apt-get install --assume-yes python python-apt'

$(ETC_HOSTS):
	@echo 'Downloading $@'
	@curl --silent --show-error --output $@ $(REPO)/$(VERSION)/$@

etc-hosts: $(ETC_HOSTS) ansible.cfg
	@ansible-playbook $<

root-key: ansible.cfg
	@ansible all \
		--become \
		--module-name=file \
		--args='dest=/root/.ssh state=directory mode=0700 owner=root group=root'
	@ansible all \
		--become \
		--module-name=copy \
		--args='src=.ssh/authorized_keys dest=/root/.ssh/authorized_keys remote_src=true'

update:
	@echo 'Downloading latest Makefile'
	@curl --silent --show-error --output $(WHOAMI) $(REPO)/master/Makefile

version:
	@echo '$(VERSION)'

ifeq (1,2) # perl script to convert vagrant status to ansible inventory, with groups
# ifeq is used to prevent make(1) from interpreting the perl script
# use "vagrant status | perl -x Makefile" to test

#!/usr/bin/env perl
use v5.10;

while (<>) {
  # adds all box names to @i; names are the first word of second paragraph
  if (/^$/.../^$/) {
    push @i, qq($1) if /^(\S+)/;
  }
}

# using a hash as an ad-hoc uniq
# find all records in @i with a dash, strip the trailing -suffix off, add to %g
%g = map { $_=>1 } ( map {/^(\S+)-/} @i );

map { say } sort @i; # prints sorted @i, one record per line

# for every %g (group), print it and all boxes with that prefix
for $g (sort keys %g) {
  say qq(\n[$g]\n), join ( qq(\n), grep { /^$g-/ } @i );
}

__END__

endif
