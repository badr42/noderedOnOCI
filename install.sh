#!/bin/bash


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
sudo su - ubuntu
curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered | bash -s -- --confirm-install --skip-pi --restart --confirm-root --no-init --node18



sudo systemctl enable nodered.service


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

if [ -z "$TP" ]; then
    export TP=aGoodPassword
fi

#generate password 
cd /usr/lib/node_modules/node-red/node_modules/
export pass=`node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" $TP`


# Enable Node-RED security and set password
if [ -n "$pass" ]; then
#    sudo sed -i 's/^\(\s*\/\/\?\s*credentialSecret\s*:\s*\).*/\1"'$NR_PASS'";/' /root/.node-red/settings.js
    sed -i '/^\(\s*\/\/\?\s*adminAuth\s*:\s*\){/!b;n;c\    adminAuth: {\n        type: "credentials",\n        users: [{\n            username: "admin",\n            password: "'"$pass"'",\n            permissions: "*"\n        }]\n    },' ~/.node-red/settings.js
fi


echo "Sleeping 2 seconds before restarting node red"
sleep 2

nohup node-red-reload &

echo "Completed setup"

# Show Mosquitto status
#sudo systemctl status mosquitto

# Show Node-RED status
#sudo systemctl status nodered
