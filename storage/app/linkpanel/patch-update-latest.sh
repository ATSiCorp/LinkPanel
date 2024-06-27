# NGINX RELOAD FIX
sudo echo 'StartLimitBurst=0' >> /usr/lib/systemd/system/user@.service
sudo systemctl daemon-reload

# PHP 8.1
sudo apt-get -y install php8.3-fpm
sudo apt-get -y install php8.3-common
sudo apt-get -y install php8.3-curl
sudo apt-get -y install php8.3-openssl
sudo apt-get -y install php8.3-bcmath
sudo apt-get -y install php8.3-mbstring
sudo apt-get -y install php8.3-tokenizer
sudo apt-get -y install php8.3-mysql
sudo apt-get -y install php8.3-sqlite3
sudo apt-get -y install php8.3-pgsql
sudo apt-get -y install php8.3-redis
sudo apt-get -y install php8.3-memcached
sudo apt-get -y install php8.3-json
sudo apt-get -y install php8.3-zip
sudo apt-get -y install php8.3-xml
sudo apt-get -y install php8.3-soap
sudo apt-get -y install php8.3-gd
sudo apt-get -y install php8.3-imagick
sudo apt-get -y install php8.3-fileinfo
sudo apt-get -y install php8.3-imap
sudo apt-get -y install php8.3-cli
PHPINI=/etc/php/8.3/fpm/conf.d/linkpanel.ini
sudo touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 724M
post_max_size = 724M
max_execution_time = 1999
max_input_time = 1999
EOF
sudo service php8.3-fpm restart
sudo apt-get -y install php-dev php-pear
sudo apt-get -y install php-dev php-pear

# NODE 20
sudo curl -sL https://deb.nodesource.com/setup_20.x | sudo bash
sudo apt-get -y install --only-upgrade nodejs
