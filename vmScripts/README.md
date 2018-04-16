# Install Scripts

These scripts are to be used to install a new vulnhub vmdk to virsh for use in the shooting gallery.

## Scripts

### install.sh

This will take a `vmdk` image and convert it to qcow2 for libvirt. It will also install the VM inside the network that was previously defined from `ctfnetwork.xml`. Lastly, it will take a fresh snapshot of the machine so the restart service can reload to a fresh state.

If you are using a network bridge other than `virbr1337` make sure it is changed on line 41.

### delete.sh

Deletes a VM from the Shooting Gallery. This will NOT remove it from the restart service and that needs to be done with `models.py` in the bastion host.

### reSnap.sh

In the case that a VM is deployed that had to be manually configured, this script will snapshot the VM and use this image when the restart servide refreshes the machine instance.

## Deploying VMS

If a VM can be provisioned with Vagrant, use the network bridge and the routes just work! This is more for custom machines you want to deploy such as

1. Client builds in your organization
1. Servers you hand rolled for the Shooting Gallery

### Other

Some VMs, such as those from Vulnhub, Metasploitable, etc, will not auto populate their routing table due to inability to manage them. To solve this, we can single user mode boot into the VM and add the route we need to talk to the openVPN server. This is done in order to have the ability to reverse shell, which doesn't need to be necessary but it is good to include. This is used for boxes such as ones from VulnHub and Metasploitable.

#### Configuration of a Box Without Network Route

1. Add VM to enviornment with `install.sh`
1. Assign that VM a `spice server`
1. Assign that VM to show grub boot menu
1. Boot into single user mode with `init="/bin/bash"` after the "linux" command in grub
1. mount -o remount,rw /.
1. passwd
1. amazingRootPasswordIsAmazing
1. Force reset (init daemon likely not responsive)
1. ip route add 192.168.122.0/23 dev eth0
1. ensure you can ping `192.168.122.1` (the openVPN server)
1. change any flags or configurations of the VM
1. run `reSnap.sh` with the VMs name
1. Add the VM to the restart service by following the below directions
1. Enjoy your new VM!

### Ones we control and built

1. Add VM to enviornment with `install.sh` or `vagrant up`
1. Add the VM to the restart service
1. Enjoy your new VM!

## Adding to Restart Service

### bastionHost

1. login to ctfBastion - `vagrant ssh` in the `bastionHost` directory
1. cd `/var/ww/ctfBastion`
1. python3 models.py -a <VM_NAME> -r <REBOOT T/F>

### KVM Host

1. Add vm to `/opt/ctf/rebootable` in `restartService` if it can be rebooted
