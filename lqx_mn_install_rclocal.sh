#!/bin/bash

echo " "
echo "========================================"
echo "Iniciando instalação do masternode LQX"
echo "========================================"
echo " "

sudo apt update

echo " "
echo "============================="
echo "Instalando pacotes adicionais"
echo "============================="
echo " "

sudo apt install net-tools
sudo apt install sudo

sudo apt install curl ufw wget git python3 python3-pip virtualenv -y

echo " "
echo "========================"
echo "Alocando arquivo de swap"
echo "========================"
echo " "

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

echo " "
echo "=================="
echo "Instalando failban"
echo "=================="
echo " "

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

echo " "
echo "================="
echo "Baixando LQX Core"
echo "================="
echo " "

cd /tmp
git clone https://github.com/kayserp/lqxcore-linux.git
sudo mkdir ~/.lqxcore
sudo chmod 777 ~/.lqxcore
sudo cp -f lqxcore-linux/* ~/.lqxcore/
sudo chmod +x ~/.lqxcore/*

echo " "
echo "=================================="
echo "Configurando inicialização no boot"
echo "=================================="
echo " "

sudo tee /etc/rc.local <<EOF
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

~/.lqxcore/lqxd

exit 0
EOF

sudo ~/.lqxcore/lqxd

echo " "
echo "==================================================="
echo "Inicializando LQX node e criando conjunto de chaves"
echo "==================================================="
echo " "

sleep 120

echo " "
echo "====================="
echo "Configurando lqx.conf"
echo "====================="
echo " "

IP=`wget -qO- ifconfig.co/ip`
PRIVATE_KEY="teste"

TEXTO="#----\n
rpcuser=masternode1\n
rpcpassword=masternode1\n
rpcallowip=127.0.0.1\n
connect=177.38.215.23:5784
connect=177.38.215.55:5784
connect=177.38.215.56:5784
#----\n
listen=1\n
server=1\n
daemon=1\n
#----\n
masternode=1\n
masternodeblsprivkey="$PRIVATE_KEY"\n
externalip="$IP

sudo touch ~/.lqxcore/lqx.conf
sudo chmod 777 ~/.lqxcore/lqx.conf
sudo echo -e $TEXTO >> ~/.lqxcore/lqx.conf

sudo ~/.lqxcore/lqx-cli stop
sleep 30
sudo ~/.lqxcore/lqxd

echo " "
echo "=========================="
echo "Instalando Sentinel Engine"
echo "=========================="
echo " "

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