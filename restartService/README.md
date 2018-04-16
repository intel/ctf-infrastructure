# Restart VMs

Simple Flask app to list VMs loaded into the shooting gallery with an option to restart them.

## Development

1. \<set proxies\>
1. virtualenv -p python3 venv
1. . venv/bin/activate
1. pip3 install -r requirements.txt
1. ./models.py
1. ./restart.py

## Deployment

restart.py

- Provisioned by `vagrant_setup.sh` in bastionHost

- Add VMs to the database with the below `Adding a new VM` instructions

- Create a file named "vmsInRotation" to automatically setup the vmList.db. Place VMs in the format <vmName:Rebootable> where rebootable is "True/False". Example: <Vulnix:True>. `echo "example:True" >> vmsInRotation"` If this is not done, manually use `models.py` as described below in `Adding a new VM to Restart Service`

listener.py

- Set REMOTEWHITELIST in listener.py to contain IPs that can restart VMs (ip of bastionHost)

- Run `setup.sh` in `host` to configure the listener systemd unit.

- Stand up on host hypervisor with your choice of web server or just use the systemd unit to use port 55555. If you want to use a web server you will need to make adjustments to the deployment. This is up to the user as an exercise.

- Create a file named "rebootable" in `/opt/ctf` and place VMs that you want to allow reboots of. `echo "example" >> rebootable`

## Adding a new VM to Restart Service

1. login to bastionHost
1. cd /var/www/ctfBastion/restartService
1. /opt/./models.py -a <vmName>
1. Add vmName to `rebootable` on host if it can be restarted
