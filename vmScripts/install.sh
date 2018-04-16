#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo -e "Sorry, you need to run this as root \n"
  exit 2
fi

if [[ -z $2 ]]; then 
  echo -e "./install <vmdk> <vmName> \n"
  exit
fi

vmdkVM=$1
qcowVM=${vmdkVM::-5}.qcow2
qcowVM2=$(echo $qcowVM | tr -d ' ')
vmName=$2

if [[ $vmdkVM == *.vmdk ]]; then
  echo -e "[+] Installing: $1 \n"
else
  echo -e "Not a vmdk file \n"
  exit
fi

qemu-img convert -O qcow2 "$vmdkVM" "$qcowVM"

echo -e "[+] Adding $qcowVM to virt images \n"

mv "$qcowVM" /srv/virt/images/$qcowVM2

virsh pool-refresh virtimages 

echo -e "[+] Virt-installing $vmName \n"

virt-install --connect qemu:///system --ram 1024 \
    -n "$vmName" --os-type=linux \
    --disk vol=virtimages/$qcowVM2,device=disk,format=qcow2 \
    --vcpus=1 --import \
    --graphics none \
    --noautoconsole \
    --network bridge=virbr1337 \
    --autostart

echo -e "[+] Snapshotting $vmName \n"

virsh snapshot-create-as --domain $vmName --name "$vmName Fresh"
virsh snapshot-revert $vmName "$vmName Fresh"

echo -e "[+] Enjoy your new VM! \n"
