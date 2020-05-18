#!/bin/bash

echo " "
echo "======================================"
echo "Iniciando instalação do masternode LQX"
echo "======================================"
echo " "

echo " "
echo "==============="
echo "Criando usuário"
echo "==============="
echo " "

USER_PASS="Teste@2020@"

echo "Criando usuário nm02..."

sudo useradd -U -m nm02 -s /bin/bash
echo "nm02:${USER_PASS}" | sudo chpasswd

echo " "
echo "================="
echo "Baixando LQX Core"
echo "================="
echo " "

cd /tmp
git clone https://github.com/kayserp/lqxcore-linux.git

echo " "
echo "Copiando arquivos para o home do usuário..."

sudo mkdir /home/nm02/.lqxcore

chown -R nm02 /home/nm02/.lqxcore

sudo chmod -R 3777 /home/nm02/.lqxcore

sudo cp -f lqxcore-linux/* /home/nm02/.lqxcore

sudo chmod +x /home/nm02/.lqxcore/lqx-cli
sudo chmod +x /home/nm02/.lqxcore/lqxd
sudo chmod +x /home/nm02/.lqxcore/lqx-qt
sudo chmod +x /home/nm02/.lqxcore/lqx-tx

echo " "
echo "====================="
echo "Configurando lqx.conf"
echo "====================="
echo " "

IP=`wget -qO- ifconfig.co/ip`
PRIVATE_KEY="teste"
RPCPORT="9998"

TEXTO="#----\n
rpcuser=masternode2\n
rpcpassword=masternode2'\n
rpcport="$RPCPORT"\n
rpcallowip=127.0.0.1\n
maxconnections=64\n
logtimestamps=1\n
connect=177.38.215.55:5784\n
connect=177.38.215.56:5784\n
connect=177.38.215.61:5784\n
#----\n
#listen=1\n
#server=1\n
#daemon=1\n
#----\n
#masternode=1\n
#masternodeblsprivkey="$PRIVATE_KEY"\n
#externalip="$IP"\n
#bind="$IP

sudo touch /home/nm02/.lqxcore/lqx.conf
sudo chmod 777 /home/nm02/.lqxcore/lqx.conf
sudo echo -e $TEXTO >> /home/nm02/.lqxcore/lqx.conf

echo " "
echo "==================================================="
echo "Inicializando LQX node e criando conjunto de chaves"
echo "==================================================="

sudo -H -u nm02 bash -c "/home/nm02/.lqxcore/lqxd" &

echo " "
echo "====================="
echo "Masternode instalado!"
echo "====================="

exit 0