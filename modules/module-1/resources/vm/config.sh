#!/bin/bash
sudo useradd -m justin
wget -c https://${URL}/shared/files/.ssh/keys/justin.pub -P /home/justin
chmod +777 /home/justin/justin.pub
mkdir /home/justin/.ssh
chmod 700 /home/justin/.ssh
touch /home/justin/.ssh/authorized_keys
chmod 600 /home/justin/.ssh/authorized_keys
cat /home/justin/justin.pub > /home/justin/.ssh/authorized_keys
sudo chown -R justin:justin /home/justin/.ssh
rm /home/justin/justin.pub
sudo apt-get update
sudo apt-get install apache2
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash