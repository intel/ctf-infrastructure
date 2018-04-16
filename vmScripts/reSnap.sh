#!/bin/bash

if [[ -z $1 ]]; then 
  echo -e "./reSnap <domain> \n"
  exit
fi

domain=$1

virsh snapshot-delete $domain "$domain Fresh"
virsh snapshot-create-as --domain $domain --name "$domain Fresh"
virsh snapshot-revert $domain "$domain Fresh"
