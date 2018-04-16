#!/usr/bin/env python3

# Copyright (C) 2018 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

from flask import Flask, request, flash
from flask import render_template
from flask import redirect
from flask_sqlalchemy import SQLAlchemy
import subprocess

app = Flask(__name__)
REMOTEWHITELIST = ["127.0.0.1"]

@app.route('/refresh/', methods=['POST'])
def refresh_machineName():

    if request.remote_addr in REMOTEWHITELIST:
        print(request.remote_addr)
        machineName_key = request.get_json()
        app.logger.info(request.remote_addr + " connected to refresh " + machineName_key)
        runningVMs = subprocess.Popen(['virsh', 'list', '--name'], stdout=subprocess.PIPE)
        listOfVMs = runningVMs.communicate()[0].decode('utf-8').strip()
        if not listOfVMs:
            return ""
        for vm in listOfVMs.splitlines():
           if vm == machineName_key:
                subprocess.Popen(['virsh', 'snapshot-revert', machineName_key, machineName_key + " Fresh"])
                return "refreshed"

    return ""

@app.route('/reboot/', methods=['POST'])
def reboot_machineName():

    if request.remote_addr in REMOTEWHITELIST:
        machineName_key = request.get_json()
        app.logger.info(request.remote_addr + " connected to reboot " + machineName_key)
        runningVMs = subprocess.Popen(['virsh', 'list', '--name'], stdout=subprocess.PIPE)
        listOfVMs = runningVMs.communicate()[0].decode('utf-8').strip()
        if not listOfVMs:
            return ""
        for vm in listOfVMs.splitlines():
           if vm == machineName_key:
                try:
                    for rebootable in open('rebootable', 'r').readlines():
                        if machineName_key == rebootable.rstrip('\n'):
                            subprocess.Popen(['virsh', 'reboot', machineName_key])
                            return "rebooted"
                except:
                    pass

    return ""

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=55555)
