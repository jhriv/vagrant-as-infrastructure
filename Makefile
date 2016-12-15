.PHONY: menu all up roles force-roles ping ip
SSHCONFIG=.ssh-config
INVENTORY=hosts

menu:
	@echo 'up: Create VMs'
	@echo 'roles: Populate Galaxy roles from "roles.yml" or "config/roles.yml"'
	@echo 'force-roles: Update all roles, overwrting when required'
	@echo 'ansible.cfg: Create default ansible.cfg'
	@echo '$(SSHCONFIG): Create ssh configuration (use "make <file> SSHCONFIG=<file>" to override name)'
	@echo '$(INVENTORY): Create ansible inventory (use "make <file> INVENTORY=<file>" to overrride name)'
	@echo 'ip: Display the IPs of all the VMs'
	@echo 'all: Create all of the above'
	@echo
	@echo '"make all SSHCONF=sshconf INVENTORY=ansible-inv"'

all: up roles ansible.cfg $(SSHCONFIG) $(INVENTORY) ip

up:
	@vagrant up

roles: $(wildcard roles.yml config/roles.yml)
	@echo 'Downloading roles'
	@ansible-galaxy install --role-file=$< --roles-path=roles

force-roles:
	@echo 'Downloading roles'
	@ansible-galaxy install --role-file=$< --roles-path=roles --force


ansible.cfg: $(SSHCONFIG) $(INVENTORY)
	@echo "Creating $@"
	@echo '[defaults]' > $@
	@echo 'inventory = $(INVENTORY)' >> $@
	@echo '' >> $@
	@echo '[ssh_connection]' >> $@
	@echo 'ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -F $(SSHCONFIG)' >> $@

$(SSHCONFIG): Vagrantfile
	@echo "Creating $@"
	@vagrant ssh-config > $@

$(INVENTORY): Vagrantfile
	@echo "Creating $@"
	@vagrant status | perl -nE 'if (/^$$/.../^$$/){say qq($$1) if /^(\S+)/;}' > $@

ping:
	@ansible -m ping all

ip:
	@ansible -a 'hostname -I' all