#!/usr/bin/python

import requests
import sys

xivo_server = "http://localhost:8668"

def get_ha_config():
    return requests.get("{}/get_ha_config".format(xivo_server)).json()

def update_ha_config(node_type='disabled', remote_address=''):
    config = { 'node_type': node_type,
               'remote_address': remote_address
             }
    return requests.post('{}/update_ha_config'.format(xivo_server), json=config)

if get_ha_config()['node_type'] != 'disabled':
    print "Error this XiVO is not a fresh installation"
    sys.exit()

update_ha_config('master', '192.168.32.81')

if get_ha_config()['node_type'] != 'master':
    print "Error this XiVO need to be a master"
    sys.exit()

