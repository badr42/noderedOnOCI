#!/bin/bash


# Allow the firewall
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -F

sudo apt-get install -y vim


# Install Node-RED
#sudo bash
curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered | bash -s -- --confirm-install --skip-pi --restart --confirm-root --no-init



sudo systemctl enable nodered.service


# Install Mosquitto
sudo apt-get update
sudo apt-get install -y mosquitto mosquitto-clients

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



nohup node-red-reload &

# Show Mosquitto status
#sudo systemctl status mosquitto

# Show Node-RED status
#sudo systemctl status nodered
