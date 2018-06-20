#!/usr/bin/env bash



sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx mysql-server mysql-client php php-cli php-xdebug php-mysql php-fpm php-pdo php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap freetype* php-gd
ln -s /vagrant/config/nginx.conf /etc/nginx/conf.d/test.loc.conf
ln -s /vagrant/config/php.ini /etc/php/7.0/fpm/conf.d/xdebug-custom.ini
sudo mysql -e "UPDATE mysql.user SET authentication_string=PASSWORD(''), plugin='mysql_native_password' WHERE User='root';CREATE DATABASE test;"
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant/code /var/www
fi
sudo nginx -s reload
sudo service mysql restart