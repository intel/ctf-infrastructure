#!/bin/bash

# Copyright (C) 2018 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

if [[ "$EUID" -ne 0 ]]; then
  echo -e "Sorry, you need to run this as root \n"
  exit 2
fi

mkdir /opt/ctf
cp . /opt/ctf

cd /opt/ctf

touch rebootable

virtualenv -p python3 venv
. venv/bin/activate
pip3 install -r requirements.txt

cp listener.service /lib/systemd/system/
systemctl daemon-reload
systemctl enable listener.service
systemctl start listener.service
