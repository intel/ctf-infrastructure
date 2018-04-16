#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Sorry, you need to run this as root"
  exit 2
fi

if [ -z $1 ]; then
  echo -e "./delete <vmName> \n show vm names with 'virsh list --all'"
  exit 2
fi

vmName=$(virsh list --all | grep " $1 " | awk '{ print $2}')
if ([ "$vmName" != "$1" ]); then
  echo "VM does not exist or is shut down!"
  exit 2  
fi

echo -e "[+] destroying $vmName and the snapshots for it \n"

virsh destroy $vmName
#virsh snapshot-delete $vmName "$vmName Fresh"
virsh undefine $vmName --snapshots-metadata
