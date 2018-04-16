#!/bin/bash

### Updates
apt-get -y update
apt-get -y upgrade

### Upgrades
apt-get install -y unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades

### OpenVPN
bash /home/vagrant/host-share/openvpn-install.sh
cp /root/bastionHost.ovpn /home/vagrant/host-share/bastionHost.ovpn
/etc/init.d/openvpn restart

### Disable SSH login with password
sed -i -e 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

### Restart Service
apt-get install -y python3-dev build-essential python3-pip vim
chmod -R 755 /var/www/ctfBastion/restartService
cd /var/www/ctfBastion/restartService
pip3 install -r requirements.txt
python3 /var/www/ctfBastion/restartService/models.py
cp /home/vagrant/host-share/restart.service /lib/systemd/system/
systemctl daemon-reload
systemctl enable restart.service

### Nginx
apt-get install -y nginx
cp /home/vagrant/host-share/restart.nginx /etc/nginx/sites-available/restart
ln -s /etc/nginx/sites-available/restart /etc/nginx/sites-enabled/restart
rm /etc/nginx/sites-available/default
service nginx reload
