#!/bin/bash
# Build OpenVPN for bastionHost

if [[ "$EUID" -ne 0 ]]; then
    echo "Sorry, you need to run this as root"
    exit 2
fi

IP=$( ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '10\.253\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1)

PROTOCOL=udp
PORT=1194

apt-get update
apt-get install openvpn iptables openssl ca-certificates -y

# Get easy-rsa
if [[ -d /etc/openvpn/easy-rsa/ ]]; then
    rm -rf /etc/openvpn/easy-rsa/
fi
wget -O ~/EasyRSA-3.0.1.tgz "https://github.com/OpenVPN/easy-rsa/releases/download/3.0.1/EasyRSA-3.0.1.tgz"
tar xzf ~/EasyRSA-3.0.1.tgz -C ~/
mv ~/EasyRSA-3.0.1/ /etc/openvpn/
mv /etc/openvpn/EasyRSA-3.0.1/ /etc/openvpn/easy-rsa/
chown -R root:root /etc/openvpn/easy-rsa/
rm -rf ~/EasyRSA-3.0.1.tgz

cd /etc/openvpn/easy-rsa/
./easyrsa init-pki
./easyrsa --batch build-ca nopass
./easyrsa gen-dh
./easyrsa build-server-full server nopass
./easyrsa build-client-full bastionHost nopass
./easyrsa gen-crl

cp pki/ca.crt pki/private/ca.key pki/dh.pem pki/issued/server.crt pki/private/server.key /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn
chown nobody:nogroup /etc/openvpn/crl.pem
openvpn --genkey --secret /etc/openvpn/ta.key

# server.conf
echo "port $PORT
proto $PROTOCOL
dev tun
sndbuf 0
rcvbuf 0
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA512
tls-auth ta.key 0
topology subnet
duplicate-cn
server 192.168.122.0 255.255.254.0
push 'route 192.168.124.0 255.255.254.0'
ifconfig-pool-persist ipp.txt
push 'redirect-gateway def1 bypass-dhcp'
" > /etc/openvpn/server.conf

# resolv.conf into OpenVPN
grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
    echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server.conf
done

echo "keepalive 10 120
cipher AES-256-CBC
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
crl-verify crl.pem" >> /etc/openvpn/server.conf

# Enable net.ipv4.ip_forward for the system
sed -i '/\<net.ipv4.ip_forward\>/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
if ! grep -q "\<net.ipv4.ip_forward\>" /etc/sysctl.conf; then
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
fi
echo 1 > /proc/sys/net/ipv4/ip_forward

/etc/init.d/openvpn restart

# client-common.txt
echo "client
dev tun
proto $PROTOCOL
sndbuf 0
rcvbuf 0
remote $IP $PORT
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA512
cipher AES-256-CBC
comp-lzo
key-direction 1
verb 3" > /etc/openvpn/client-common.txt

cp /etc/openvpn/client-common.txt ~/bastionHost.ovpn
echo "<ca>" >> ~/bastionHost.ovpn
cat /etc/openvpn/easy-rsa/pki/ca.crt >> ~/bastionHost.ovpn
echo "</ca>" >> ~/bastionHost.ovpn
echo "<cert>" >> ~/bastionHost.ovpn
cat /etc/openvpn/easy-rsa/pki/issued/bastionHost.crt >> ~/bastionHost.ovpn
echo "</cert>" >> ~/bastionHost.ovpn
echo "<key>" >> ~/bastionHost.ovpn
cat /etc/openvpn/easy-rsa/pki/private/bastionHost.key >> ~/bastionHost.ovpn
echo "</key>" >> ~/bastionHost.ovpn
echo "<tls-auth>" >> ~/bastionHost.ovpn
cat /etc/openvpn/ta.key >> ~/bastionHost.ovpn
echo "</tls-auth>" >> ~/bastionHost.ovpn

# Generates the custom client.ovpn
echo "Client config is located at " ~/"bastionHost.ovpn"

# Allow traffic initiated from VPN to access LAN
iptables -I FORWARD -i tun0 -o ens6 \
     -s 192.168.122.0/23 -d 192.168.124.0/23 \
     -m conntrack --ctstate NEW -j ACCEPT

# Allow traffic initiated from VPN to access "the world"
iptables -I FORWARD -i tun0 -o ens6 \
     -s 192.168.122.0/23 -m conntrack --ctstate NEW -j ACCEPT

# Allow established traffic to pass back and forth
iptables -I FORWARD -m conntrack --ctstate RELATED,ESTABLISHED \
     -j ACCEPT

iptables -t nat -I POSTROUTING -o ens6 \
      -s 192.168.122.0/23 -j MASQUERADE

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

apt-get install -y iptables-persistent
