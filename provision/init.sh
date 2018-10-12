#!/usr/bin/env bash



sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx mysql-server mysql-client php php-cli php-xdebug php-mysql php-curl libapache2-mod-php apache2 php-pdo php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap freetype* php-gd libapache2-mod-rpaf
sudo a2enmod rewrite
sudo a2enmod rpaf
ln -s /vagrant/config/nginx.conf /etc/nginx/conf.d/test.loc.conf
ln -s /vagrant/config/php.ini /etc/php/7.0/apache2/conf.d/xdebug-custom.ini
sudo ln -s /vagrant/config/apache.conf /etc/apache2/sites-enabled/site.conf
sudo mysql -e "UPDATE mysql.user SET authentication_string=PASSWORD(''), plugin='mysql_native_password' WHERE User='root';CREATE DATABASE test;"
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant/code /var/www
fi
sudo sh -c " sed -i 's/Listen 80$/Listen 8080/g' /etc/apache2/ports.conf"
sudo sh -c " sed -i 's/RPAFsethostname On/RPAFsethostname Off/g' /etc/apache2/mods-enabled/rpaf.conf"
sudo sh -c " sed -i 's/RPAFproxy_ips 127.0.0.1 ::1/RPAFproxy_ips 127.0.0.1/g' /etc/apache2/mods-enabled/rpaf.conf"
sudo sh -c " sed -i 's/#   RPAFheader X-Real-IP/   RPAFheader X-Real-IP/g' /etc/apache2/mods-enabled/rpaf.conf"
sudo nginx -s reload
sudo service mysql restart
sudo service apache2 restart