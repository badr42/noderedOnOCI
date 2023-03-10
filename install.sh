#!/bin/bash

sudo su - 


echo "waiting for the network set up to complete"
sleep 10


# Allow the firewall
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -F

sudo apt-get install -y vim

#sudo apt install -y npm
#sudo apt-get install --only-upgrade nodejs



# Install Node-RED
# sudo su - ubuntu
runuser -l ubuntu  -c 'curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered | bash -s -- --confirm-install --skip-pi --restart --confirm-root --no-init --node18'





sudo systemctl enable nodered.service


# replace the service file 
sudo rm /lib/systemd/system/nodered.service
sudo wget -O /lib/systemd/system/nodered.service https://raw.githubusercontent.com/badr42/noderedOnOCI/main/nodered.service
sleep 10

sudo systemctl daemon-reload






# Install Mosquitto
sudo apt-get update
sudo apt-get install -y mosquitto mosquitto-clients

###replace mosquitto conf
cd /etc/mosquitto
sudo mv mosquitto.conf mosquitto.conf_backup
sudo wget https://raw.githubusercontent.com/badr42/noderedOnOCI/main/mosquitto.conf 
sudo systemctl restart mosquitto

# Enable Mosquitto to start at boot
sudo systemctl enable mosquitto



##set password for nodered

TP=$1

if [ -z "$TP" ]; then
    export TP=aGoodPassword
fi

#generate password 
cd /usr/lib/node_modules/node-red/node_modules/
export pass=`node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" $TP`



# check if file exists if not create it 
 [[ ! -f r ]] && wget -P /home/ubuntu/.node-red/ https://raw.githubusercontent.com/badr42/noderedOnOCI/main/settings.js




# Enable Node-RED security and set password
if [ -n "c" ]; then
    sed -i '/^\(\s*\/\/\?\s*adminAuth\s*:\s*\){/!b;n;c\    adminAuth: {\n        type: "credentials",\n        users: [{\n            username: "admin",\n            password: "'"$pass"'",\n            permissions: "*"\n        }]\n    },' /home/ubuntu/.node-red/settings.js
fi





echo "Sleeping 2 seconds before restarting node red"
sleep 2


sudo systemctl restart nodered.service
nohup node-red-reload &

echo "Completed setup"

# Show Mosquitto status
#sudo systemctl status mosquitto

# Show Node-RED status
#sudo systemctl status nodered
