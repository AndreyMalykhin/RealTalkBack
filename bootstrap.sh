#!/usr/bin/env bash

projectDir="$1"
environment="$2"
port="$3"
host="$4"
frontendHost="$5"

if [ "$environment" = "dev" ]; then
    frontendHost="*"
fi

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
    add_header Access-Control-Allow-Origin ${frontendHost};
  }
}
EOF
sudo ln -sf /etc/nginx/sites-available/real_talk_back /etc/nginx/sites-enabled/real_talk_back \
&& sudo service nginx restart
