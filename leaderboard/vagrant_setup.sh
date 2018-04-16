#!/bin/bash

### Updates
apt-get -y update
apt-get -y upgrade

### Upgrades
apt-get install -y unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades

# Disable SSH login with password
sed -i -e 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

### Leaderboard
apt-get install -y python build-essential python-pip vim git
cd /home/vagrant
git clone https://github.com/CTFd/CTFd.git
cd CTFd/
chown vagrant:vagrant -R /home/vagrant/CTFd
chmod 755 -R /home/vagrant/CTFd
./prepare.sh
apt-get install -y nginx
cp ctfdConfig/shooting-gallery /etc/nginx/sites-available/shooting-gallery
ln -s /etc/nginx/sites-available/shooting-gallery /etc/nginx/sites-enabled/shooting-gallery
service nginx reload

cp /home/vagrant/ctfdConfig/leaderboard.service /var/lib/system/leaderboard.service
systemctl daemon-reload
systemctl enable leaderboard.service
systemctl start leaderboard.service
