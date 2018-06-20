sudo rm -rf /etc/mysql/conf.d/mysql-custom.cnf
sudo cp /vagrant/config/mysql.cnf /etc/mysql/conf.d/mysql-custom.cnf
sudo chmod g-wx /etc/mysql/conf.d/mysql-custom.cnf
sudo chmod o-wx /etc/mysql/conf.d/mysql-custom.cnf
sudo nginx -s reload
sudo service php7.0-fpm restart
sudo service mysql restart
