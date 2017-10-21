#!/bin/bash

# To install shadowsocks
yum install python-setuptools
easy_install pip && pip install shadowsocks

# REF: https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks
sudo cp ./local.conf /etc/sysctl.d/local.conf
sysctl --system

nohup ssserver -c /root/ss/ssserver.json -d start &
