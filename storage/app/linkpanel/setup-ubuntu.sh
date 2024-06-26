#!/bin/bash

#################################################### CONFIGURATION ###
BUILD=202112181
PASS=$(openssl rand -base64 32|sha256sum|base64|head -c 32| tr '[:upper:]' '[:lower:]')
DBPASS=$(openssl rand -base64 24|sha256sum|base64|head -c 32| tr '[:upper:]' '[:lower:]')
SERVERID=$(openssl rand -base64 12|sha256sum|base64|head -c 32| tr '[:upper:]' '[:lower:]')
REPO=ATSiCorp/linkpanel
if [ -z "$1" ];
    BRANCH=main
then
    BRANCH=$1
fi


####################################################   CLI TOOLS   ###
reset=$(tput sgr0)
bold=$(tput bold)
underline=$(tput smul)
black=$(tput setaf 0)
white=$(tput setaf 7)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
purple=$(tput setaf 5)
bgblack=$(tput setab 0)
bgwhite=$(tput setab 7)
bgred=$(tput setab 1)
bggreen=$(tput setab 2)
bgyellow=$(tput setab 4)
bgblue=$(tput setab 4)
bgpurple=$(tput setab 5)



#################################################### LINKPANEL SETUP ######



# LOGO
clear
echo "${green}${bold}"
echo "=================================================================="
echo "█      █ ██████  █  █ ████     █     █████  █████ █    "
echo "█      █ █     █ █ █  █   █   ███    █    █ █     █    "
echo "█      █ █     █ ██   █   █  █   █   █    █ ███   █    "
echo "█      █ █     █ █ █  ████  ███████  █    █ █     █    "
echo "██████ █ █     █ █  █ █    █       █ █    █ █████ █████"
echo "BY ATSi Corporation"
echo "=================================================================="
echo "Installation has been started... on 20 sec, Hold on!"
echo "This script automatically takes care of all the installation tasks"
echo "so sit back and get some coffee ready to relax."
echo "${restart}"
sleep 20s



# Ubuntu Operating System CHECK
clear
clear
echo "${bggreen}${black}${bold}"
echo "OS check..."
echo "${restart}"
sleep 10s


ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')
if [ "$ID" = "ubuntu" ]; then
    case $VERSION in
        20.04 | 22.04 | 24.04)
            break
            ;;
        *)
            echo "${bgred}${white}${bold}"
            echo "LinkPanel requires Linux Ubuntu 24.04-24.04 LTS Only"
            echo "${restart}"
            exit 1;
            break
            ;;
    esac
else
    echo "${bgred}${white}${bold}"
    echo "LinkPanel requires Linux Ubuntu 224.04-24.04 LTS Only"
    echo "${restart}"
    exit 1
fi




# ROOT CHECK
clear
clear
echo "${bggreen}${black}${bold}"
echo "Permission check..."
echo "${restart}"
sleep 5s

if [ "$(id -u)" = "0" ]; then
    clear
else
    clear
    echo "${bgred}${white}${bold}"
    echo "You have to run LinkPanel as root. (In VPS or Local Server use '-s')"
    sleep 20s
    echo "${restart}"
    exit 1
fi



# BASIC SETUP
clear
clear
echo "${bggreen}${black}${bold}"
echo "OS Base setup also check Update - Upgrade - Install software for LinkPanel requirement..."
echo "${restart}"
sleep 15s

sudo apt-get update
sudo apt-get upgrade
sudo add-apt-repository ppa:ondrej/php -y
sudo add-apt-repository ppa:ondrej/nginx-mainline -y
sudo apt-get -y install software-properties-common net-tools curl wget nano micro vim rpl sed zip unzip openssl expect dirmngr apt-transport-https lsb-release ca-certificates dnsutils dos2unix zsh htop ffmpeg
sudo apt update

# GET IP
clear
clear
echo "${bggreen}${black}${bold}"
echo "Getting this machine public IP not local IP..."
echo "${restart}"
sleep 5s

IP=(curl -s https://checkip.amazonaws.com)


# MOTD WELCOME MESSAGE
clear
echo "${bggreen}${black}${bold}"
echo "Motd settings..."
echo "${restart}"
sleep 10s

WELCOME=/etc/motd
sudo touch $WELCOME
sudo cat > "$WELCOME" <<EOF

█      █ ██████  █  █ ████     █     █████  █████ █    
█      █ █     █ █ █  █   █   ███    █    █ █     █    
█      █ █     █ ██   █   █  █   █   █    █ ███   █    
█      █ █     █ █ █  ████  ███████  █    █ █     █    
██████ █ █     █ █  █ █    █       █ █    █ █████ █████
=======================================================
Simple Lightweight Functional For Small Server
LinkPanel Build BY ATSi Corporation
=======================================================

EOF


sleep 15s
# SWAP
clear
echo "${bggreen}${black}${bold}"
echo "LinkPanel will set Memory SWAP to 2GB..."
sleep 5s

sudo /bin/dd if=/dev/zero of=/var/swap.LinkPanel2GB bs=2M count=2024
sudo /sbin/mkswap /var/swap.LinkPanel2GB
sudo /sbin/swapon /var/swap.LinkPanel2GB
free -h
echo "${restart}"
sleep 15s

# ALIAS
clear
echo "${bggreen}${black}${bold}"
echo "Custom CLI configuration..."
echo "${restart}"
sleep 10s

shopt -s expand_aliases
alias ll='ls -alF'



# LINKPANEL DIRS
clear
echo "${bggreen}${black}${bold}"
echo "Configure LinkPanel directories..."
echo "${restart}"
sleep 10s

sudo mkdir /etc/linkpanel/
sudo chmod o-r /etc/linkpanel
sudo mkdir /var/linkpanel/
sudo chmod o-r /var/linkpanel



# USER
clear
echo "${bggreen}${black}${bold}"
echo "Set LinkPanel root user..."
echo "${restart}"
sleep 10s

sudo pam-auth-update --package
sudo mount -o remount,rw /
sudo chmod 640 /etc/shadow
sudo useradd -m -s /bin/bash linkpanel
echo "linkpanel:$PASS"|chpasswd
sudo usermod -aG linkpanel


# NGINX
clear
echo "${bggreen}${black}${bold}"
echo "Nginx setup..."
echo "${restart}"
sleep 5s

apt-get -y install nginx.core
sudo systemctl start nginx.service
sudo rpl -i -w "http {" "http { limit_req_zone \$binary_remote_addr zone=one:10m rate=1r/s; fastcgi_read_timeout 300;" /etc/nginx/nginx.conf
sudo rpl -i -w "http {" "http { limit_req_zone \$binary_remote_addr zone=one:10m rate=1r/s; fastcgi_read_timeout 300;" /etc/nginx/nginx.conf
sudo systemctl enable nginx.service
sudo systemctl status nginx.service
sleep 10s





# FIREWALL
clear
echo "${bggreen}${black}${bold}"
echo "Fail2ban Firewall setup..."
echo "${restart}"
sleep 5s

apt-get -y install fail2ban
JAIL=/etc/fail2ban/jail.local
sudo unlink JAIL
sudo touch $JAIL
sudo cat > "$JAIL" <<EOF
[DEFAULT]
bantime = 3600
banaction = iptables-multiport
[sshd]
enabled = true
logpath  = /var/log/auth.log
EOF
systemctl restart fail2ban
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow 22/tcp
sudo ufw allow 22/udp
sudo ufw allow http
sudo ufw allow https
sudo ufw allow "Nginx Full"




# PHP
clear
echo "${bggreen}${black}${bold}"
echo "PHP setup (This may take some time for install and configure)"
echo "${restart}"
sleep 15s


apt-get update
sleep 10s
apt-get -y install php7.4-fpm
apt-get -y install php7.4-common
apt-get -y install php7.4-curl
apt-get -y install php7.4-openssl
apt-get -y install php7.4-bcmath
apt-get -y install php7.4-mbstring
apt-get -y install php7.4-tokenizer
apt-get -y install php7.4-mysql
apt-get -y install php7.4-sqlite3
apt-get -y install php7.4-pgsql
apt-get -y install php7.4-redis
apt-get -y install php7.4-memcached
apt-get -y install php7.4-json
apt-get -y install php7.4-zip
apt-get -y install php7.4-xml
apt-get -y install php7.4-soap
apt-get -y install php7.4-gd
apt-get -y install php7.4-imagick
apt-get -y install php7.4-fileinfo
apt-get -y install php7.4-imap
apt-get -y install php7.4-cli
PHPINI=/etc/php/7.4/fpm/conf.d/linkpanel.ini
touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 1999
max_input_time = 1999
EOF
service php7.4-fpm restart
sleep 10s

apt-get -y install php8.0-fpm
apt-get -y install php8.0-common
apt-get -y install php8.0-curl
apt-get -y install php8.0-openssl
apt-get -y install php8.0-bcmath
apt-get -y install php8.0-mbstring
apt-get -y install php8.0-tokenizer
apt-get -y install php8.0-mysql
apt-get -y install php8.0-sqlite3
apt-get -y install php8.0-pgsql
apt-get -y install php8.0-redis
apt-get -y install php8.0-memcached
apt-get -y install php8.0-json
apt-get -y install php8.0-zip
apt-get -y install php8.0-xml
apt-get -y install php8.0-soap
apt-get -y install php8.0-gd
apt-get -y install php8.0-imagick
apt-get -y install php8.0-fileinfo
apt-get -y install php8.0-imap
apt-get -y install php8.0-cli
PHPINI=/etc/php/8.0/fpm/conf.d/linkpanel.ini
touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 1999
max_input_time = 1999
EOF
service php8.0-fpm restart
sleep 10s

apt-get -y install php8.1-fpm
apt-get -y install php8.1-common
apt-get -y install php8.1-curl
apt-get -y install php8.1-openssl
apt-get -y install php8.1-bcmath
apt-get -y install php8.1-mbstring
apt-get -y install php8.1-tokenizer
apt-get -y install php8.1-mysql
apt-get -y install php8.1-sqlite3
apt-get -y install php8.1-pgsql
apt-get -y install php8.1-redis
apt-get -y install php8.1-memcached
apt-get -y install php8.1-json
apt-get -y install php8.1-zip
apt-get -y install php8.1-xml
apt-get -y install php8.1-soap
apt-get -y install php8.1-gd
apt-get -y install php8.1-imagick
apt-get -y install php8.1-fileinfo
apt-get -y install php8.1-imap
apt-get -y install php8.1-cli
PHPINI=/etc/php/8.1/fpm/conf.d/linkpanel.ini
touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 1999
max_input_time = 1999
EOF
service php8.1-fpm restart
sleep 10s

apt-get -y install php8.2-fpm
apt-get -y install php8.2-common
apt-get -y install php8.2-curl
apt-get -y install php8.2-openssl
apt-get -y install php8.2-bcmath
apt-get -y install php8.2-mbstring
apt-get -y install php8.2-tokenizer
apt-get -y install php8.2-mysql
apt-get -y install php8.2-sqlite3
apt-get -y install php8.2-pgsql
apt-get -y install php8.2-redis
apt-get -y install php8.2-memcached
apt-get -y install php8.2-json
apt-get -y install php8.2-zip
apt-get -y install php8.2-xml
apt-get -y install php8.2-soap
apt-get -y install php8.2-gd
apt-get -y install php8.2-imagick
apt-get -y install php8.2-fileinfo
apt-get -y install php8.2-imap
apt-get -y install php8.2-cli
PHPINI=/etc/php/8.2/fpm/conf.d/linkpanel.ini
touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 1999
max_input_time = 1999
EOF
service php8.2-fpm restart
sleep 10s

# PHP EXTRA
apt-get -y install php-dev php-pear


# PHP CLI
clear
echo "${bggreen}${black}${bold}"
echo "PHP CLI configuration..."
echo "${restart}"
sleep 10s

update-alternatives --set php /usr/bin/php8.2



# COMPOSER
clear
echo "${bggreen}${black}${bold}"
echo "Composer setup..."
echo "${restart}"
sleep 10s

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --no-interaction
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer
composer config --global repo.packagist composer https://packagist.org --no-interaction




# GIT
clear
echo "${bggreen}${black}${bold}"
echo "GIT setup..."
echo "${restart}"

apt-get -y install git
sudo ssh-keygen -t rsa -C "git@github.com" -f /etc/linkpanel/github -q -P ""
sleep 5s


# SUPERVISOR
clear
echo "${bggreen}${black}${bold}"
echo "Supervisor setup..."
echo "${restart}"
sleep 10s

apt-get -y install supervisor
sudo service supervisor restart
sudo service supervisor status
sleep 5s



# DEFAULT VHOST
clear
echo "${bggreen}${black}${bold}"
echo "Default vhost..."
echo "${restart}"
sleep 10s

NGINX=/etc/nginx/sites-available/default
if test -f "$NGINX"; then
    sudo unlink NGINX
fi
sudo touch $NGINX
sudo cat > "$NGINX" <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html/public;
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    client_body_timeout 10s;
    client_header_timeout 10s;
    client_max_body_size 256M;
    index index.html index.php;
    charset utf-8;
    server_tokens off;
    location / {
        try_files   \$uri     \$uri/  /index.php?\$query_string;
    }
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }
    error_page 404 /index.php;
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF


sudo mkdir /etc/nginx/linkpanel/
sudo systemctl restart nginx.service
sudo systemctl status nginx.service
sleep 15s


# MYSQL
clear
echo "${bggreen}${black}${bold}"
echo "MySQL setup..."
echo "${restart}"
sleep 5s


sudo apt-get install -y mysql-server
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Press y|Y for Yes, any other key for No:\"
send \"n\r\"
expect \"New password:\"
send \"$DBPASS\r\"
expect \"Re-enter new password:\"
send \"$DBPASS\r\"
expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No)\"
send \"y\r\"
expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No)\"
send \"n\r\"
expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No)\"
send \"y\r\"
expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) \"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"
sudo /usr/bin/mysql -u root -p$DBPASS <<EOF
use mysql;
CREATE USER 'linkpanel'@'%' IDENTIFIED WITH mysql_native_password BY '$DBPASS';
GRANT ALL PRIVILEGES ON *.* TO 'linkpanel'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF



# REDIS
clear
echo "${bggreen}${black}${bold}"
echo "Redis setup..."
echo "${restart}"
sleep 5s

apt install -y redis-server
sudo rpl -i -w "supervised no" "supervised systemd" /etc/redis/redis.conf
systemctl restart redis.service
systemctl status redis.service
sleep 15s



# LET'S ENCRYPT
clear
echo "${bggreen}${black}${bold}"
echo "Let's Encrypt setup..."
echo "${restart}"
sleep 5s

apt-get install -y certbot
apt-get install -y python3-certbot-nginx



# NODE
clear
echo "${bggreen}${black}${bold}"
echo "Node/npm setup..."
echo "${restart}"
sleep 5s

curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
NODE=/etc/apt/sources.list.d/nodesource.list
sudo unlink NODE
sudo touch $NODE
sudo cat > "$NODE" <<EOF
deb https://deb.nodesource.com/node_20.x focal main
deb-src https://deb.nodesource.com/node_20.x focal main
EOF

apt-get update
apt -y install nodejs
apt -y install npm




#PANEL INSTALLATION
clear
echo "${bggreen}${black}${bold}"
echo "And now LinkPanel installation begin..."
echo "${restart}"
sleep 15s

echo "${bggreen}${black}${bold}"
echo "Create Syslink..."

sudo /usr/bin/mysql -u root -p$DBPASS <<EOF
CREATE DATABASE IF NOT EXISTS linkpanel;
EOF
sleep 10s
sudo rm -rf /var/www/html
cd /var/www && git clone https://github.com/$REPO.git html
cd /var/www/html && git pull
cd /var/www/html && git checkout $BRANCH
cd /var/www/html && git pull
cd /var/www/html && unlink .env
cd /var/www/html && cp .env.example .env
cd /var/www/html && php artisan key:generate
sudo rpl -i -w "DB_USERNAME=dbuser" "DB_USERNAME=linkpanel" /var/www/html/.env
sudo rpl -i -w "DB_PASSWORD=dbpass" "DB_PASSWORD=$DBPASS" /var/www/html/.env
sudo rpl -i -w "DB_DATABASE=dbname" "DB_DATABASE=linkpanel" /var/www/html/.env
sudo rpl -i -w "APP_URL=http://localhost" "APP_URL=http://$IP" /var/www/html/.env
sudo rpl -i -w "APP_ENV=local" "APP_ENV=production" /var/www/html/.env
sudo rpl -i -w "LINKPANELSERVERID" $SERVERID /var/www/html/database/seeders/DatabaseSeeder.php
sudo rpl -i -w "LINKPANELIP" $IP /var/www/html/database/seeders/DatabaseSeeder.php
sudo rpl -i -w "LINKPANELPASS" $PASS /var/www/html/database/seeders/DatabaseSeeder.php
sudo rpl -i -w "LINKPANELDB" $DBPASS /var/www/html/database/seeders/DatabaseSeeder.php
sudo chmod -R o+w /var/www/html/storage
sudo chmod -R 777 /var/www/html/storage
sudo chmod -R o+w /var/www/html/bootstrap/cache
sudo chmod -R 777 /var/www/html/bootstrap/cache
cd /var/www/html && composer update --no-interaction
cd /var/www/html && php artisan key:generate
cd /var/www/html && php artisan cache:clear
cd /var/www/html && php artisan storage:link
cd /var/www/html && php artisan view:cache
cd /var/www/html && php artisan linkpanel:activesetupcount
LINKPANELBULD=/var/www/html/public/build_$SERVERID.php
sudo touch $LINKPANELBULD
sudo cat > $LINKPANELBULD <<EOF
$BUILD
EOF
LINKPANELPING=/var/www/html/public/ping_$SERVERID.php
sudo touch $LINKPANELPING
sudo cat > $LINKPANELPING <<EOF
Up
EOF
PUBKEYGH=/var/www/html/public/ghkey_$SERVERID.php
sudo touch $PUBKEYGH
sudo cat > $PUBKEYGH <<EOF
<?php
echo exec("cat /etc/linkpanel/github.pub");
EOF
cd /var/www/html && php artisan migrate --seed --force
cd /var/www/html && php artisan config:cache
sudo chmod -R o+w /var/www/html/storage
sudo chmod -R 775 /var/www/html/storage
sudo chmod -R o+w /var/www/html/bootstrap/cache
sudo chmod -R 775 /var/www/html/bootstrap/cache
sudo chown -R www-data:linkpanel /var/www/html



# LAST STEPS
clear
echo "${bggreen}${black}${bold}"
echo "Last LinkPanel installation steps..."
echo "${restart}"
sleep 5s

chown www-data:linkpanel -R /var/www/html
chmod -R 750 /var/www/html
echo 'DefaultStartLimitIntervalSec=1s' >> /usr/lib/systemd/system/user@.service
echo 'DefaultStartLimitBurst=50' >> /usr/lib/systemd/system/user@.service
echo 'StartLimitBurst=0' >> /usr/lib/systemd/system/user@.service
systemctl daemon-reload

TASK=/etc/cron.d/linkpanel.crontab
touch $TASK
cat > "$TASK" <<EOF
10 4 * * 7 certbot renew --nginx --non-interactive --post-hook "systemctl restart nginx.service"
20 4 * * 7 apt-get -y update
40 4 * * 7 DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -q -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" dist-upgrade
20 5 * * 7 apt-get clean && apt-get autoclean
50 5 * * * echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a
* * * * * cd /var/www/html && php artisan schedule:run >> /dev/null 2>&1
5 2 * * * cd /var/www/html/utility/linkpanel-update && sh run.sh >> /dev/null 2>&1
EOF
crontab $TASK
systemctl restart nginx.service
sudo rpl -i -w "#PasswordAuthentication" "PasswordAuthentication" /etc/ssh/sshd_config
sudo rpl -i -w "# PasswordAuthentication" "PasswordAuthentication" /etc/ssh/sshd_config
sudo rpl -i -w "PasswordAuthentication no" "PasswordAuthentication yes" /etc/ssh/sshd_config
sudo rpl -i -w "PermitRootLogin yes" "PermitRootLogin no" /etc/ssh/sshd_config
service sshd restart
TASK=/etc/supervisor/conf.d/linkpanel.conf
touch $TASK
sudo cat > "$TASK" <<EOF
[program:linkpanel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/html/artisan queue:work --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=linkpanel
numprocs=8
redirect_stderr=true
stdout_logfile=/var/www/worker.log
stopwaitsecs=3600
EOF
supervisorctl reread
supervisorctl update
supervisorctl start all
service supervisor restart

# COMPLETE
clear
echo "${bggreen}${black}${bold}"
echo "LinkPanel installation has been completed..."
echo "${restart}"
sleep 15s

HOSTNAME=hostname -f | awk '{print $1}'


# SETUP COMPLETE MESSAGE
clear
echo "${green}${bold}"
echo ""
echo "█      █ ██████  █  █ ████     █     █████  █████ █    "
echo "█      █ █     █ █ █  █   █   ███    █    █ █     █    "
echo "█      █ █     █ ██   █   █  █   █   █    █ ███   █    "
echo "█      █ █     █ █ █  ████  ███████  █    █ █     █    "
echo "██████ █ █     █ █  █ █    █       █ █    █ █████ █████"
echo "BY ATSi Corporation"
echo "***********************************************************"
echo "                    SETUP COMPLETE YAY"
echo "***********************************************************"
echo ""
echo "============================================================"
echo " SSH root user: atsi"
echo " SSH root pass: $PASS"
echo " MySQL root user: atsi"
echo " MySQL root pass: $DBPASS"
echo "============================================================"
echo ""
echo " To manage your server visit"
echo " Your IP Address [http://$IP] OR [http://$HOSTNAME]"
echo " and click on 'dashboard' button."
echo " Default credentials are: admin / admin1230"
echo ""
echo "***********************************************************"
echo "          DO NOT LOSE AND KEEP SAFE THIS DATA"
echo "***********************************************************"
