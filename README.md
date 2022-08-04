DISCONTINUATION OF PROJECT.

This project will no longer be maintained by Intel.

Intel has ceased development and contributions including, but not limited to, maintenance, bug fixes, new releases, or updates, to this project. 

Intel no longer accepts patches to this project.

If you have an ongoing need to use this project, are interested in independently developing it, or would like to maintain patches for the open source software community, please create your own fork of this project. 
# CTF-Infrastructure

This infrastructure consists of 4 parts:

1. Host System / Listener Service
1. Bastion Host with openVPN/Restart Service
1. Leaderboard
1. Vulnerable VMs

Each part is configured on its own. For more detail on either part, resort to the README in

1. bastionHost
1. leaderboard
1. restartService

For normal operations, you will need to read the `What You Need` section.

## Network

The network in the enviornment is configured as such

```
External Network
  .                     +------------------+
  |            macvtap  | CTFBastionHost   |
  |                  +--| IP: 192.168.122.x|
+-----------------+  |  | IP: 192.168.124.x|--+
| Host: VMHost    |--+  +------------------+  |
|                 |                           |
+-----------------+     +------------------+  |
                        | VM 2             |  |
                        | IP: 192.168.124.x|  |--+  virbr1337
                        +------------------+  |
                                              |
                        +------------------+  |
                        | VM 3             |  |
                        | IP: 192.168.124.x|  |
                        +------------------+  |
                                              |
                                              |
                                              |
                                     etc    --+

```

CTFBastionHost contains OpenVPN server running at 192.168.122.1/23

virbr1337 is assigned the 192.168.124.0/23 subnet

## Requirements to Stand Up Infrastructure

You will need (for Ubuntu 16.04) a server that has has and supports libvirt, vagrant, and vagrant-libvirt

1. [libvirt](https://help.ubuntu.com/lts/serverguide/libvirt.html) with virtinstall

1. [Vagrant](https://www.vagrantup.com/)

1. [Vagrant Libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt#installation)

## Steps

1. Define a private network for virsh to consume. Below is an example xml you can use for this and there is also one in `ctfnetwork.xml`

    ```
    <network>
      <name>examplenetwork</name>
      <bridge name="virbr1337" />
      <ip address="192.168.124.1" netmask="255.255.254.0">
        <dhcp>
          <range start="192.168.124.2" end="192.168.125.254" />
        </dhcp>
      </ip>
    </network>
    ```

1. Define the network with `virsh`

    ```
    virsh net-define --file examplenetwork.xml

    virsh net-start examplenetwork

    virsh net-autostart examplenetwork
    ```

1. Stand up the bastion host in `bastionHost`. Consult the README there for more directions.

1. Stand up the leaderboard in `leaderboard`. Consult the README there for more directions.

1. Configure the listener service in `restartService/host` by running `setup.sh`

1. Deploy vulnerable machines to the network using CTF-Infrastructure/vmScripts. Consult the README there for more directions
