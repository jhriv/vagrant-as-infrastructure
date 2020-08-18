# -*- mode: ruby -*-
# vi: set ft=ruby :

# Reasonable Defaults - can be overridden with environmental variables
_IP_NETWORK=ENV.fetch('IP_NETWORK','172.16.1')
_DEFAULT_BOX=ENV.fetch('DEFAULT_BOX', 'ubuntu/focal64')
_DEFAULT_PROVIDER=ENV.fetch('VAGRANT_DEFAULT_PROVIDER', 'virtualbox')

# List guests in separate file
require_relative 'GUESTS';

Vagrant.configure(2) do |config|

  # Provider
  if defined?(PROVIDER)
    config.vm.provider "#{PROVIDER}"
  else
    config.vm.provider "#{_DEFAULT_PROVIDER}"
  end

  GUESTS.each_with_index do |guest, i|
    config.vm.define "#{guest[:name]}", primary: i==0 do |box|
      box.vm.box_check_update = false

      # :box Define OS
      box.vm.box = ( guest.key?(:box) ? guest[:box] : _DEFAULT_BOX )

      # :ip IP
      if guest.has_key?(:ip)
        if guest[:ip] == 'dhcp'
          box.vm.network 'private_network', type: guest[:ip]
        else
          box.vm.network 'private_network',
            ip: guest[:ip].to_s.match('\.') ? guest[:ip] : "#{_IP_NETWORK}.#{guest[:ip].to_s}"
        end
      end

      # :needs_python Install python, if requested / assumed needed
      if guest.has_key?(:needs_python) \
          ? guest[:needs_python]
          : /ubuntu|debian/i =~ box.vm.box
        box.vm.provision 'shell',
          name: 'Installing python',
          inline: <<-'SCRIPT'
            if command -v apt-get > /dev/null; then
              export DEBIAN_FRONTEND=noninteractive
              apt-get update  --quiet=2
              apt-get install --quiet=2 --option=Dpkg::Use-Pty=0 --assume-yes python python-apt
            fi
          SCRIPT
      end

      # :ports Port forwarding
      if guest.has_key?(:ports)
        guest[:ports].each do |port|
          if port.is_a? Integer
            box.vm.network "forwarded_port", guest: port, host: port
          else # elif port.is_a? Hash
            box.vm.network "forwarded_port",
              guest:        port[:guest],
              auto_correct: port.has_key?(:auto_correct) ? port[:auto_correct] : true,
              guest_ip:     port.has_key?(:guest_ip)     ? port[:guest_ip]     : nil,
              host_ip:      port.has_key?(:host_ip)      ? port[:host_ip]      : nil,
              host:         port.has_key?(:host)         ? port[:host]         : port[:guest],
              id:           port.has_key?(:id)           ? port[:id]           : nil,
              protocol:     port.has_key?(:protocol)     ? port[:protocol]     : nil
          end
        end
      end

      # :cpus/:gui:/:memory CPU / GUI / RAM
      box.vm.provider "virtualbox" do |v|
        v.cpus   = guest[:cpus]   if guest.has_key?(:cpus)
        v.gui    = guest[:gui]    if guest.has_key?(:gui)
        v.memory = guest[:memory] if guest.has_key?(:memory)
      end
      box.vm.provider "parallels" do |v|
        v.cpus   = guest[:cpus]   if guest.has_key?(:cpus)
        if guest.has_key?(:gui)
          v.customize ["set", :id, "--startup-view", guest[:gui] ? "window" : "headless"]
        end
        v.memory = guest[:memory] if guest.has_key?(:memory)
      end
      box.vm.provider "vmware_fusion" do |v|
        v.vmx["numvcpus"] = guest[:cpus]   if guest.has_key?(:cpus)
        v.gui             = guest[:gui]    if guest.has_key?(:gui)
        v.vmx["memsize"]  = guest[:memory] if guest.has_key?(:memory)
      end
      box.vm.provider "vmware_workstation" do |v|
        v.vmx["numvcpus"] = guest[:cpus]   if guest.has_key?(:cpus)
        v.gui             = guest[:gui]    if guest.has_key?(:gui)
        v.vmx["memsize"]  = guest[:memory] if guest.has_key?(:memory)
      end

      # :sync Sync'd folder
      unless guest.has_key?(:sync)
        box.vm.synced_folder '.', '/vagrant', disabled: true
      else
        box.vm.synced_folder '.', '/vagrant', disabled: ! guest[:sync]
      end

      # :update Update OS
      if guest.has_key?(:update) && guest[:update]
        box.vm.provision 'shell',
          inline: <<-'SCRIPT'
            if command -v apt-get > /dev/null; then
              export DEBIAN_FRONTEND=noninteractive
              apt-get update  --quiet=2
              apt-get upgrade --quiet=2 --option=Dpkg::Use-Pty=0 --assume-yes
            fi
            if command -v yum > /dev/null; then
              yum upgrade --quiet --assumeyes
            fi
          SCRIPT
      end

      ## PROVISIONERS

      # Ansible
      if guest.has_key?(:ansible)
        if guest[:ansible].is_a? Array
          guest[:ansible].each do |playbook|
            box.vm.provision "ansible" do |ansible|
              ansible.playbook = playbook
            end
          end
        else
          box.vm.provision "ansible" do |ansible|
            ansible.playbook = guest[:ansible]
          end
        end
      end

      # File
      if guest.has_key?(:file)
        if guest[:file].is_a? Array
          guest[:file].each do |file|
            box.vm.provision "file", source: file, destination: "#{file}"
          end
        else
          box.vm.provision "file", source: guest[:file], destination: "#{guest[:file]}"
        end
      end

      # Shell
      if guest.has_key?(:shell)
        if guest[:shell].is_a? Array
          guest[:shell].each do |script|
            box.vm.provision "shell" do |shell|
              shell.path = script
              shell.name = File.basename(script)
            end
          end
        else
          box.vm.provision "shell" do |shell|
            shell.path = guest[:shell]
            shell.name = File.basename(guest[:shell])
          end
        end
      end

    end # config.vm.define
  end # GUESTS.each_with_index
end # Vagrant.configure
