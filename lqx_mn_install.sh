#!/bin/bash

sudo apt update

sudo apt install net-tools
sudo apt install sudo

sudo apt install curl ufw wget git python3 python3-pip virtualenv -y
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 9999/tcp
sudo ufw logging on
sudo ufw enable
sudo ufw allow 5784

sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

TEXTO="/swapfile\tnone\tswap\tsw\t0\t0"
sudo cp /etc/fstab .
sudo chmod 777 fstab
sudo chmod +x fstab
sudo echo -e $TEXTO >> fstab
sudo cp fstab /etc/fstab

sudo apt install fail2ban -y

TEXTO="[sshd]\n
enabled = true\n
port = 22\n
filter = sshd\n
logpath = /var/log/auth.log\n
maxretry = 3"

>~/etc/fail2ban/jail.local
sudo echo -e $TEXTO >> /etc/fail2ban/jail.local

sudo systemctl restart fail2ban
sudo systemctl enable fail2ban

#sudo sed -i '/PermitRootLogin/s/yes/no/g' /etc/ssh/sshd_config
#sudo sed -i '$a\' -e 'AllowUsers masternode' /etc/ssh/sshd_conf##ig

cd /tmp
git clone https://github.com/kayserp/lqxcore-linux.git
sudo mkdir ~/.lqxcore
sudo chmod 777 ~/.lqxcore
sudo cp -f lqxcore-linux/* ~/.lqxcore/
sudo chmod +x ~/.lqxcore/*

cd /tmp/config-masternode
sudo chmod +x *
sudo cp -f lqx.service /lib/systemd/system/
sudo systemctl daemon-reload
systemctl enable lqx

IP=`wget -qO- ifconfig.co/ip`

TEXTO="#----\n
rpcuser=masternode1\n
rpcpassword=masternode1\n
rpcallowip=127.0.0.1\n
#----\n
listen=1\n
server=1\n
daemon=1\n
#----\n
#masternode=1\n
#masternodeblsprivkey="$1"\n
#externalip="$IP

sudo touch ~/.lqxcore/lqx.conf
sudo chmod 777 ~/.lqxcore/lqx.conf
sudo echo -e $TEXTO >> ~/.lqxcore/lqx.conf

sudo tee /etc/systemd/system/lqx.service <<EOF
[Unit]
Description=lqx, distributed currency daemon
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/
ExecStart=/root/.lqxcore/lqxd

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=2s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable lqx
sudo systemctl start lqx
echo "Booting LQX node and creating keypool"

echo "Installing sentinel engine"
sudo git clone https://github.com/kayserp/sentinel.git ~/.lqxcore/sentinel/
cd ~/.lqxcore/sentinel/
sudo virtualenv -p python3 ./venv
sudo ./venv/bin/pip install -r requirements.txt
echo "* * * * * lqx cd ~/.lqxcore/sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1" | sudo tee /etc/cron.d/lqx_sentinel
sudo chmod 644 /etc/cron.d/lqx_sentinel

echo " "
echo "==============================="
echo "Masternode installed!"
echo "==============================="

exit 0