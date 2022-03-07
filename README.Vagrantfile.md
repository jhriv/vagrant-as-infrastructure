## Vagrantfile/GUESTS.rb

Available is `Vagrantfile` paired with `GUESTS.rb`. The Vagrantfile factors
out various Vagrant features (such as port forwarding, cpu, memory allocation).
GUESTS.rb lists all the vagrant boxes, so the Vagrantfile can be upgraded
without having to redefine all the boxes.

Options are:

* `name`: **[MANDATORY]** (string) Name of box
* `box`: (string) guest OS `ubuntu/focal64`, `centos/7`, etc
  (default ubuntu/bionic64, or _`DEFAULT_BOX`_)
* `cpus`: (integer) Number of CPUs to assign (default _per box_)
* `gui`: (boolean) Allocate GUI (default _false_)
* `ip`: (string) Additional IP for guest-to-guest communication
  * Can be fully expressed dotted quad (10.1.2.3)
  * Can be final octet only (3)
    (default network 192.168.56 or _`IP_NETWORK`_)
  * Can be 'dhcp' to allow provider to allocate
  * default _nil_
* `memory`: (integer) Memory in KB (default _per box_)
* `needs_python`: (boolean) Install python/python-apt in guest
  * default _true_ for Alpine/Debian/Ubuntu
  * default _false_ for all others
* `ports`: (array) Ports to forward. Can be a hash, to further refine definition
  * `auto_correct`: (boolean) move host port in case of collision (default _true_)
  * `guest_ip`: (string) (default _nil_)
  * `host_ip`: (string) (default _nil_)
  * `host`: (string) Port on host (default _same as guest_)
  * `id`: (string) friendly name (default _nil_)
  * `protocol`: (string) tcp or udp (default _nil_)
  * default _nil_
* `sync`: (boolean) Sync local folder to guest (default _false_)
* `update`: (boolean) Update guest OS packages (default _false_)

_Available provisioners_

* `ansible`: (string|array of strings) playbook to run at provisioning
  * can be an array, for multiple playbook provisioners
  * default _nil_
* `file`: (string|array of strings) File provisioner, copies file to guest
  * relative filename relative to $HOME
  * absolute filename absolute in guest
  * can be an array, for multiple files
  * default _nil_
* `shell`: (string|array of strings) script to run at provisioning
  * can be an array, for multiple shell provisioners
  * default _nil_

Setting `PROVIDER` will set the provider for all guests.

See [GUESTS.rb.sample][G] for examples.

## Python

A box with a name that includes "Alpine", "Debian" or "Ubuntu" (case
insensitive) will have `python` and `python-apt` installed automatically. This
can be overridden by setting `needs_python: false` in the `GUESTS.rb` defintion
for the box.

## Localhost

A box with a name that includes "Alpine" (case insensitive) will have
`/etc/hosts` adjusted to remove any non-localhost name references. This will
reverse an action of `setup-alpine`.

<!-- References -->
[G]: GUESTS.rb.sample
