#!/usr/bin/env python3

# Copyright (C) 2018 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

from flask import Flask, flash
from flask import render_template
from flask import redirect
from flask_sqlalchemy import SQLAlchemy
from db import session
from models import VmList
import datetime
import requests

app = Flask(__name__)
REMOTESERVER = "http://192.168.124.1:55555"

@app.route('/')
def machineNames_list():
    machineNames = session.query(VmList).all()
    return render_template('list.html', machineNames=machineNames)

@app.route('/refresh/<string:machineName_key>')
def restart_machineName(machineName_key):

    machineName = session.query(VmList).get(machineName_key)
    if not machineName:
        return redirect('/')

    currTime = datetime.datetime.now()
    if ((currTime - machineName.lastRefresh) < datetime.timedelta(minutes=5)):
        return redirect('/')

    refreshed = requests.post(REMOTESERVER + "/refresh/", json=machineName.vmName)

    if refreshed.text == "refreshed":
        machineName.lastRefresh = currTime
        session.commit()

    return redirect('/')

@app.route('/reboot/<string:machineName_key>')
def reset_machineName(machineName_key):
    machineName = session.query(VmList).get(machineName_key)
    if not machineName:
        return redirect('/')

    if machineName.rebootable:

        currTime = datetime.datetime.now()

        if ((currTime - machineName.lastRefresh) < datetime.timedelta(minutes=1)):
            return redirect('/')

        refreshed = requests.post(REMOTESERVER + "/reboot/", json=machineName.vmName)

        if refreshed.text == "rebooted":
            machineName.lastRefresh = currTime
            session.commit()

    return redirect('/')

if __name__ == '__main__':
    app.run(host="127.0.0.1")
