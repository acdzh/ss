#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#
# Auto install Shadowsocks Server
# Copyright (C) 2016-2019 
# System Required:  CentOS 6+, Debian7+, Ubuntu12+
# Reference URL:
# https://github.com/shadowsocks/shadowsocks
# https://github.com/shadowsocks/shadowsocks-libev
# https://github.com/shadowsocks/shadowsocks-windows

echo -e "\033[33mBegin to install shadowsocks-libev...\033[0m"
echo -e "\033[33mPlease excute this by root user!\033[0m"
echo -e "\033[33mElse it will be faild!\033[0m"
echo

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install shadowsocks-libev

read -p "Input your server ip: " server
read -p "Input your server port: " server_port
read -s -p "Input your passwd: " passwd

echo
echo "Method: "
echo "    1) aes-256-gcm"
echo "    2) chacha20-ietf-poly1305"
echo "    3) aes-128-gcm"
echo "    4) aes-192-gcm"
echo "    5) other"
read -p "Select a method: " selec
case $selec in
    1) method="aes-256-gcm";;
    2) method="chacha20-ietf-poly1305";;
    3) method="aes-128-gcm";;
    4) method="aes-192-gcm";;
    5) read -p "Input your method: " method;;
esac
echo -e "\033[33mYour method is $method, now write it to config.json...\033[0m"

cd /etc/shadowsocks-libev/
echo "{" > config.json
echo "    \"server\":\"$server\"," >> config.json
echo "    \"server_port\":$server_port," >> config.json
echo "    \"local_port\":1080," >> config.json
echo "    \"password\":\"$passwd\"," >> config.json
echo "    \"timeout\":300," >> config.json
echo "    \"method\":\"$method\"," >> config.json

read -p "Install simple-obfs(y/n)? " if_simple_obfs
case $if_simple_obfs in
    Y) if_simple_obfs="y";;
    N) if_simple_obfs="n";;
esac
case $if_simple_obfs in
    y) sudo apt-get install --no-install-recommends build-essential git autoconf libtool libssl-dev libpcre3-dev libev-dev asciidoc xmlto automake
       cd /opt
       git clone https://github.com/shadowsocks/simple-obfs.git
       cd simple-obfs
       git submodule update --init --recursive
       ./autogen.sh
       ./configure && make
       sudo make install
       cd /etc/shadowsocks-libev/
       echo "    \"fast_open\": false," >> config.json
       echo "    \"plugin\":\"obfs-server\"," >> config.json
       echo "    \"plugin_opts\":\"obfs=http\"" >> config.json;;
    n) echo "    \"fast_open\": false" >> config.json;;
esac
echo "}" >> config.json
echo -e "\033[33mThe config has been writen:\033[0m"
echo
echo -e "\033[32m--------------config.json--------------\033[0m"
cat config.json
echo -e "\033[32m--------------config.json--------------\033[0m"
echo 

echo -e "\033[33mSystemd:\033[0m"
echo "[Unit]" > /etc/systemd/system/shadowsocks-server.service
echo "Description=Shadowsocks Server" >> /etc/systemd/system/shadowsocks-server.service
echo "After=network.target" >> /etc/systemd/system/shadowsocks-server.service
echo "" >> /etc/systemd/system/shadowsocks-server.service
echo "[Service]" >> /etc/systemd/system/shadowsocks-server.service
echo "ExecStart=/usr/local/bin/ss-server -c /etc/shadowsocks-libev/config.json" >> /etc/systemd/system/shadowsocks-server.service
echo "Restart=on-abort" >> /etc/systemd/system/shadowsocks-server.service
echo "" >> /etc/systemd/system/shadowsocks-server.service
echo "[Install]" >> /etc/systemd/system/shadowsocks-server.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/shadowsocks-server.service
echo -e "\033[33mThe config has been writen:\033[0m"
echo
echo -e "\033[32m--------------shadowsocks-server.service--------------\033[0m"
cat /etc/systemd/system/shadowsocks-server.service
echo -e "\033[32m--------------shadowsocks-server.service--------------\033[0m"
echo 

echo -e "\033[33mStart the ss...\033[0m"
sudo systemctl start shadowsocks-server
sudo systemctl enable shadowsocks-server
