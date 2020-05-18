#!/bin/bash

echo " "
echo "======================================"
echo "Iniciando instalação do masternode LQX"
echo "======================================"
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
echo "=========================="
echo "Criando usuários múltiplos"
echo "=========================="
echo " "

echo -e "Senha@2020@\n" | sudo adduser nm01
echo -e "Senha@2020@\n" | sudo adduser nm02

echo " "
echo "================="
echo "Baixando LQX Core"
echo "================="
echo " "

cd /tmp
git clone https://github.com/kayserp/lqxcore-linux.git

sudo mkdir /home/nm01/.lqxcore
sudo mkdir /home/nm02/.lqxcore

sudo chmod 777 /home/nm01/.lqxcore
sudo chmod 777 /home/nm02/.lqxcore

sudo cp -f lqxcore-linux/* /home/nm01/.lqxcore
sudo cp -f lqxcore-linux/* /home/nm02/.lqxcore

sudo chmod +x /home/nm01/.lqxcore/lqx-cli
sudo chmod +x /home/nm01/.lqxcore/lqxd
sudo chmod +x /home/nm01/.lqxcore/lqx-qt
sudo chmod +x /home/nm01/.lqxcore/lqx-tx

sudo chmod +x /home/nm02/.lqxcore/lqx-cli
sudo chmod +x /home/nm02/.lqxcore/lqxd
sudo chmod +x /home/nm02/.lqxcore/lqx-qt
sudo chmod +x /home/nm02/.lqxcore/lqx-tx

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
#a
# By default this script does nothing.

sudo -H -u nm01 bash -c "/home/nm01/.lqxcore/lqxd"
sudo -H -u nm02 bash -c "/home/nm02/.lqxcore/lqxd"

#exit 0
EOF

sudo -H -u nm01 bash -c "/home/nm01/.lqxcore/lqxd"
sudo -H -u nm02 bash -c "/home/nm02/.lqxcore/lqxd"

echo " "
echo "==================================================="
echo "Inicializando LQX node e criando conjunto de chaves"
echo "==================================================="
#echo " Aguarde 120 segundos..."

sleep 120

echo " "
echo "====================="
echo "Configurando lqx.conf"
echo "====================="
echo " "

IP=`wget -qO- ifconfig.co/ip`
PRIVATE_KEY="teste"
#PRIVATE_KEY=~/.lqxcore/lqx-cli bls generate

TEXTO="#----\n
rpcuser=masternode1\n
rpcpassword=masternode1\n
rpcallowip=127.0.0.1\n
connect=177.38.215.55:5784
connect=177.38.215.56:5784
connect=177.38.215.61:5784
#----\n
#listen=1\n
#server=1\n
#daemon=1\n
#----\n
#masternode=1\n
#masternodeblsprivkey="$PRIVATE_KEY"\n
#externalip="$IP

sudo touch /home/nm01/.lqxcore/lqx.conf
sudo chmod 777 /home/nm01/.lqxcore/lqx.conf
sudo echo -e $TEXTO >> /home/nm01/.lqxcore/lqx.conf

sudo touch /home/nm02/.lqxcore/lqx.conf
sudo chmod 777 /home/nm01/.lqxcore/lqx.conf
sudo echo -e $TEXTO >> /home/nm01/.lqxcore/lqx.conf

sudo /home/nm01/.lqxcore/lqx-cli stop
sudo /home/nm02/.lqxcore/lqx-cli stop
echo "Aguarde 30 segundos..."
sleep 30
sudo -H -u nm01 bash -c "/home/nm01/.lqxcore/lqxd"
sudo -H -u nm02 bash -c "/home/nm02/.lqxcore/lqxd"

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
echo "====================="
echo "Masternode instalado!"
echo "====================="

exit 0