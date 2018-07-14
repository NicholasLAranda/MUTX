#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your MUTX Coin masternodes.       *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [[ $DOSETUP =~ "y" ]] ; then
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get install -y nano htop git
  sudo apt-get install -y software-properties-common
  sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev
  sudo apt-get install -y libboost-all-dev
  sudo apt-get install -y libevent-dev
  sudo apt-get install -y libminiupnpc-dev
  sudo apt-get install -y autoconf
  sudo apt-get install -y automake unzip
  sudo add-apt-repository  -y  ppa:bitcoin/bitcoin
  sudo apt-get update
  sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

  cd /var
  sudo touch swap.img
  sudo chmod 600 swap.img
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo free
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
  cd

  ## INSTALL
  rm MUTX-*.zip
  rm MUTX
  wget https://github.com/Nikita8669/MUTX/releases/download/v1.0/MUTX_Linux.zip
  unzip MUTX* -d MUTX
  sudo chmod 755 mutx/mutx*
  sudo mv mutx/mutx* /usr/bin

  sudo apt-get install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc
fi

## Setup conf
mkdir -p ~/bin
IP=$(curl -s4 icanhazip.com)
NAME="mutx"
CONF_FILE=mutx.conf

MNCOUNT=""
re='^[0-9]+$'
while ! [[ $MNCOUNT =~ $re ]] ; do
   echo ""
   echo "How many nodes do you want to create on this server?, followed by [ENTER]:"
   read MNCOUNT
done

for i in `seq 1 1 $MNCOUNT`; do
  echo ""
  echo "Enter alias for new node"
  read ALIAS  

  echo ""
  echo "Enter port for node $ALIAS (Any valid free port matching config from steps before: i.E. 8001)"
  read PORT

  echo ""
  echo "Enter RPC Port (Any valid free port: i.E. 9001)"
  read RPCPORT

  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY

  ALIAS=${ALIAS,,}
  CONF_DIR=~/.${NAME}_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/${NAME}d_$ALIAS.sh
  echo "${NAME}d -daemon -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' >> ~/bin/${NAME}d_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/${NAME}-cli_$ALIAS.sh
  echo "${NAME}-cli -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' >> ~/bin/${NAME}-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/${NAME}-tx_$ALIAS.sh
  echo "${NAME}-tx -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' >> ~/bin/${NAME}-tx_$ALIAS.sh 
  chmod 755 ~/bin/${NAME}*.sh

  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> ${NAME}.conf_TEMP
  echo "rpcport=$RPCPORT" >> ${NAME}.conf_TEMP
  echo "listen=1" >> ${NAME}.conf_TEMP
  echo "server=1" >> ${NAME}.conf_TEMP
  echo "daemon=1" >> ${NAME}.conf_TEMP
  echo "logtimestamps=1" >> ${NAME}.conf_TEMP
  echo "maxconnections=256" >> ${NAME}.conf_TEMP
  echo "masternode=1" >> ${NAME}.conf_TEMP
  echo "" >> ${NAME}.conf_TEMP
  echo "port=$PORT" >> ${NAME}.conf_TEMP
  echo "masternodeaddr=$IP:$PORT" >> ${NAME}.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> ${NAME}.conf_TEMP
  echo "" >> ${NAME}.conf_TEMP
  echo "addnode=188.165.251.53" >> $CONF_DIR/$CONF_FILE
  echo "addnode=199.247.19.79" >> $CONF_DIR/$CONF_FILE
  echo "addnode=199.247.16.41" >> $CONF_DIR/$CONF_FILE
  echo "addnode=104.238.167.200" >> $CONF_DIR/$CONF_FILE
  echo "addnode=199.247.19.190" >> $CONF_DIR/$CONF_FILE
  echo "addnode=199.247.6.197" >> $CONF_DIR/$CONF_FILE
  echo "addnode=108.61.173.115" >> $CONF_DIR/$CONF_FILE
  echo "addnode=209.250.229.44" >> $CONF_DIR/$CONF_FILE
  echo "addnode=209.250.230.205" >> $CONF_DIR/$CONF_FILE
  echo "addnode=45.76.142.181" >> $CONF_DIR/$CONF_FILE
  echo "addnode=45.32.177.50" >> $CONF_DIR/$CONF_FILE

  sudo ufw allow $PORT/tcp

  mv ${NAME}.conf_TEMP $CONF_DIR/${NAME}.conf
#  cp mutx_peers.dat $CONF_DIR/peers.dat
  
  sh ~/bin/${NAME}d_$ALIAS.sh
done
