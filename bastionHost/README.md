# CTF Bastion Host Configure

# What

Bastion host for the InfoSec CTF. This box contains

- OpenVPN server
- Flask Web app to restart vulnhub boxes
- Nginx service proxy forwarding to Flask app

## How To

### Setup

You will need to create a ubuntu1604 box file for Vagrant and name it `ctf-ubuntu1604`. Alternatively, use one from [vagrant](https://app.vagrantup.com/boxes/search).

Install plugin requirements and initialize the machine.

```
vagrant plugin install vagrant-proxyconf
vagrant up
```

The client.conf to connect with openVPN will be placed in host-share after vagrant successfully provisions

### Restart

The restart service is provisioned by bash in `vagrant_setup.sh`. You will need to make changes to the service as described in `../restartService/README.md`.

The restart service will be accessible from the IP of the bastionHost:80
