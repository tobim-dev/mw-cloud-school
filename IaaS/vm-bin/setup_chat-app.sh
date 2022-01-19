#!/bin/sh

SSH_IP=40.118.68.27
ssh adminuser@$SSH_IP

FIFO=/var/run/pushnot_fifo

cd ~
wget https://github.com/joewalnes/websocketd/releases/download/v0.4.1/websocketd-0.4.1_amd64.deb
sudo apt install ./websocketd-0.4.1_amd64.deb

mkdir bin

sudo mkdir -p /var/www
sudo chown :adminuser /var/www
sudo chmod g+w /var/www

# from local machine:
scp vm-bin/handle_websocket-client.sh adminuser@$SSH_IP:/home/adminuser/bin/
scp vm-www/index.html adminuser@$SSH_IP:/var/www/

chmod 755 ~/bin/handle_websocket-client.sh

sudo mkfifo $FIFO
sudo chmod 766 $FIFO

# open the port in Azure first to make this work, i.e. 
#   create a Network Security Group
#   assign it to the NIC
#   create a rule for the 6851 port (and for SSH)
sudo websocketd --port 6851 --staticdir=/var/www /home/adminuser/bin/handle_websocket-client.sh