#!/bin/bash
# 交互输入用户名和ip
echo -n "Enter your name:"                   # 参数-n的作用是不换行，echo默认换行
read  username         
echo -n "Enter your ip:"                 
read  ip     
# 生成密钥对
wg genkey | tee ${username}-privatekey | wg pubkey > ${username}-publickey
echo "=====客户端 ${username} 密钥对已生成====="
# 生成配置文件 注意修改 ip
cat > ${username}.conf <<EOF
[Interface]
PrivateKey = $(cat ${username}-privatekey)
Address = ${ip}/24 #wg之前通信组网的内网ip和段,主机位每个得不一样
# DNS = 192.168.2.3

[Peer]
PublicKey = $(cat gw-publickey)   # gateway的公钥
AllowedIPs = 10.1.0.0/24, 192.168.1.0/24
Endpoint = $(curl -s ip.sb):16000 #gateway 公网ip和端口
PersistentKeepalive = 10 # 心跳时间
EOF
echo "=====客户端 ${username} 配置文件已生成====="
# 写入新增加的配置
cat >> wg0.conf <<EOF

# ${username}
[Peer]
PublicKey = $(cat ${username}-publickey)
AllowedIPs = ${ip}/32
EOF
echo "=====客户端 ${username} 信息已写入主配置====="
## 重载配置文件
wg syncconf wg0 <(wg-quick strip wg0)
echo "=====主配置文件已重载 请下载 $(pwd)/${username}.conf 文件到本地导入使用====="

