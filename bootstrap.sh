#!/usr/bin/env bash

projectDir="$1"
environment="$2"
port="$3"
host="$4"
frontendOrigin="$5"
swapSize="$6"
swapFilePath="/swapfile"

if [ "$environment" = "dev" ]; then
    frontendOrigin="*"
fi

sudo fallocate -l ${swapSize} ${swapFilePath} \
    && sudo chmod 600 ${swapFilePath} \
    && sudo mkswap ${swapFilePath} \
    && sudo swapon ${swapFilePath} \
    && echo "${swapFilePath}   none    swap    sw    0   0" | sudo tee -a /etc/fstab \
    && sudo sysctl vm.swappiness=10

sudo apt-get update \
&& sudo apt-get -y install nginx php5-cli php5-fpm

sudo rm -f /etc/nginx/sites-enabled/default \
&& sudo tee /etc/nginx/sites-available/real_talk_back > /dev/null <<EOF
server {
  listen ${port};
  root ${projectDir}/public;
  index index.php;
  server_name ${host};
  try_files \$uri /index.php;
  sendfile off;
  location ~ /\. {
    access_log off;
    log_not_found off;
    deny all;
  }
  location /index.php {
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    include fastcgi_params;
    add_header Access-Control-Allow-Origin ${frontendOrigin};
    add_header Access-Control-Allow-Methods GET,POST,OPTIONS;
    add_header Access-Control-Allow-Headers DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type;
  }
}
EOF
sudo ln -sf /etc/nginx/sites-available/real_talk_back /etc/nginx/sites-enabled/real_talk_back \
&& sudo service nginx restart
