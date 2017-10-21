#!/bin/bash

read -p 'Enter the IP for current server: ' SVR_IP
read -p 'Specify the port to expose: ' SVR_PORT
read -p 'Set the connection password as: ' SVR_PWD

\"{
  "server": "$SVR_IP",
  "server_port": $SVR_PORT,
  "local_address": "127.0.0.1",
  "local_port": 1080,
  "password": "$SVR_PWD",
  "timeout": 300,
  "method": "aes-256-cfb",
  "fast_open": false
}\" >> ./ssserver.json

# To install shadowsocks
yum -y install python-setuptools
easy_install pip && pip install shadowsocks

# REF: https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks
cp ./local.conf /etc/sysctl.d/local.conf
sysctl --system

# Check firewall
is_port_exposed=`firewall-cmd --query-port=$SVR_PORT/tcp`
if [[ $is_port_exposed != "yes" ]]; then
  firewall-cmd --zone=public --add-port=$SVR_PORT/tcp --permanent
  firewall-cmd --reload
fi

# Run ssserver
nohup ssserver -c ./ssserver.json -d start &

# To stop, run:
# ssserver -c ./ssserver.json -d stop
