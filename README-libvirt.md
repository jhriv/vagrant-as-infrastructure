# Installing Libvirt/Qemu

On Arch linux, and hopefully most systemd-based Linux distributions, the following steps were necessary in preparation
to install the vagrant libvirt plugin.

The majority of this information was taken from the [Arch Wiki][libvirt-arch] entry on Libvirt.

## Verify KVM support
While not mandatory, we want to use KVM as the hypervisor for libvirt/Qemu
```
lsmod | grep kvm
```
If this command returns nothing, you may have to manually load the module in the kernel.

## Packages
This installs what I believe to be the core packages necessary for using libvirt/qemu.
```
sudo pacman -Suy libvirt qemu firewalld ebtables dnsmasq bridge-utils openbsd-netcat
```

## Configuration
The firewalld configuration file needed to be updated to use iptables.
```
vi /etc/firewalld/firewalld.conf
# Last line (change FirewallBackend to iptables from nftables)
```

## Add user to libvirt group
This allows for passwordless access to the libvirt RW daemon socket
```
sudo usermod -a -G libvirt <user>
```

## SystemD
```
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service virtlogd.service
```

## Install libvirt plugin
```
vagrant plugin install vagrant-libvirt
```

[libvirt-arch]:https://wiki.archlinux.org/index.php/Libvirt

