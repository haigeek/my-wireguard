#!/bin/bash
# 初始化wireguard服务端
wg genkey | tee gw-privatekey | wg pubkey >gw-publickey
cat >wg0.conf <<EOF
[Interface]
ListenPort = 16000 # 客户端连过来填写的端口,安全组的tcp和udp都要放行
Address = 10.1.0.1/24  #wg之间通信组网的内网ip和段
PrivateKey = $(cat gw-privatekey) # 读网关的私钥
# 下面两条是放行的iptables和MASQUERADE
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF
