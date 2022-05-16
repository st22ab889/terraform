#!/bin/bash
sudo apt update
sudo apt install -y nginx
echo Create: ${time} | sudo tee /var/www/html/index.html
exit 0