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
echo ""
echo "█      █ ██████  █  █ ████     █     █████  █████ █    "
echo "█      █ █     █ █ █  █   █   ███    █    █ █     █    "
echo "█      █ █     █ ██   █   █  █   █   █    █ ███   █    "
echo "█      █ █     █ █ █  ████  ███████  █    █ █     █    "
echo "██████ █ █     █ █  █ █    █       █ █    █ █████ █████"
echo "BY ATSi Corporation"
echo "Installation has been started... Hold on Pret!"
echo "${reset}"
sleep 10s



# OS CHECK
clear
clear
echo "${bggreen}${black}${bold}"
echo "OS check..."
echo "${reset}"
sleep 10s

ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')
if [ "$ID" = "ubuntu" ]; then
    case $VERSION in
        24.04)
            break
            ;;
        *)
            echo "${bgred}${white}${bold}"
            echo "LinkPanel requires Linux Ubuntu 24.04 LTS Only"
            echo "${reset}"
            exit 1;
            break
            ;;
    esac
else
    echo "${bgred}${white}${bold}"
    echo "LinkPanel requires Linux Ubuntu 24.04 LTS Only"
    echo "${reset}"
    exit 1
fi



# ROOT CHECK
clear
clear
echo "${bggreen}${black}${bold}"
echo "Permission check..."
echo "${reset}"
sleep 5s

if [ "$(id -u)" = "0" ]; then
    clear
else
    clear
    echo "${bgred}${white}${bold}"
    echo "You have to run LinkPanel as root. (In VPS or Local Server use 'sudo -s')"
    echo "${reset}"
    exit 1
fi



# BASIC SETUP
clear
clear
echo "${bggreen}${black}${bold}"
echo "OS Base setup also check Update - Upgrade - Install software for LinkPanel requirement..."
echo "${reset}"
sleep 15s

sudo apt-get update
sudo apt-get upgrade
sudo apt-get -y install software-properties-common curl wget nano micro vim rpl sed zip unzip openssl expect dirmngr apt-transport-https lsb-release ca-certificates dnsutils dos2unix zsh htop ffmpeg


# GET IP
clear
clear
echo "${bggreen}${black}${bold}"
echo "Getting this machine public IP not local IP..."
echo "${reset}"
sleep 3s

IP=$(curl -s https://checkip.amazonaws.com)


# MOTD WELCOME MESSAGE
clear
echo "${bggreen}${black}${bold}"
echo "Motd settings..."
echo "${reset}"
sleep 5s

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
-------------------------------------------------------
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
sudo free -h
sleep 15s
echo "${reset}"


# ALIAS
clear
echo "${bggreen}${black}${bold}"
echo "Custom CLI configuration..."
echo "${reset}"
sleep 10s

shopt -s expand_aliases
alias ll='ls -alF'



# LINKPANEL DIRS
clear
echo "${bggreen}${black}${bold}"
echo "Configure LinkPanel directories..."
echo "${reset}"
sleep 10s

sudo mkdir /etc/linkpanel/
sudo chmod o-r /etc/linkpanel
sudo mkdir /var/linkpanel/
sudo chmod o-r /var/linkpanel



# USER
clear
echo "${bggreen}${black}${bold}"
echo "Set LinkPanel root user..."
echo "${reset}"
sleep 10s

sudo pam-auth-update --package
sudo mount -o remount,rw /
sudo chmod 640 /etc/shadow
sudo useradd -m -s /bin/bash linkpanel
echo "linkpanel:$PASS"|sudo chpasswd
sudo usermod -aG sudo linkpanel


# NGINX
clear
echo "${bggreen}${black}${bold}"
echo "Nginx setup..."
echo "${reset}"
sleep 5s

sudo apt-get -y -f install nginx
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
echo "${reset}"
sleep 5s

sudo apt-get -y install fail2ban
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
sudo systemctl restart fail2ban
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow "Nginx Full"




# PHP
clear
echo "${bggreen}${black}${bold}"
echo "PHP setup (This may take some time for install and configure)"
echo "${reset}"
sleep 15s


sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update
sleep 10s
sudo apt-get -y install php7.4-fpm
sudo apt-get -y install php7.4-common
sudo apt-get -y install php7.4-curl
sudo apt-get -y install php7.4-openssl
sudo apt-get -y install php7.4-bcmath
sudo apt-get -y install php7.4-mbstring
sudo apt-get -y install php7.4-tokenizer
sudo apt-get -y install php7.4-mysql
sudo apt-get -y install php7.4-sqlite3
sudo apt-get -y install php7.4-pgsql
sudo apt-get -y install php7.4-redis
sudo apt-get -y install php7.4-memcached
sudo apt-get -y install php7.4-json
sudo apt-get -y install php7.4-zip
sudo apt-get -y install php7.4-xml
sudo apt-get -y install php7.4-soap
sudo apt-get -y install php7.4-gd
sudo apt-get -y install php7.4-imagick
sudo apt-get -y install php7.4-fileinfo
sudo apt-get -y install php7.4-imap
sudo apt-get -y install php7.4-cli
PHPINI=/etc/php/7.4/fpm/conf.d/linkpanel.ini
sudo touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 1999
max_input_time = 1999
EOF
sudo service php7.4-fpm restart
sleep 10s

sudo apt-get -y install php8.0-fpm
sudo apt-get -y install php8.0-common
sudo apt-get -y install php8.0-curl
sudo apt-get -y install php8.0-openssl
sudo apt-get -y install php8.0-bcmath
sudo apt-get -y install php8.0-mbstring
sudo apt-get -y install php8.0-tokenizer
sudo apt-get -y install php8.0-mysql
sudo apt-get -y install php8.0-sqlite3
sudo apt-get -y install php8.0-pgsql
sudo apt-get -y install php8.0-redis
sudo apt-get -y install php8.0-memcached
sudo apt-get -y install php8.0-json
sudo apt-get -y install php8.0-zip
sudo apt-get -y install php8.0-xml
sudo apt-get -y install php8.0-soap
sudo apt-get -y install php8.0-gd
sudo apt-get -y install php8.0-imagick
sudo apt-get -y install php8.0-fileinfo
sudo apt-get -y install php8.0-imap
sudo apt-get -y install php8.0-cli
PHPINI=/etc/php/8.0/fpm/conf.d/linkpanel.ini
sudo touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 1999
max_input_time = 1999
EOF
sudo service php8.0-fpm restart
sleep 10s

sudo apt-get -y install php8.1-fpm
sudo apt-get -y install php8.1-common
sudo apt-get -y install php8.1-curl
sudo apt-get -y install php8.1-openssl
sudo apt-get -y install php8.1-bcmath
sudo apt-get -y install php8.1-mbstring
sudo apt-get -y install php8.1-tokenizer
sudo apt-get -y install php8.1-mysql
sudo apt-get -y install php8.1-sqlite3
sudo apt-get -y install php8.1-pgsql
sudo apt-get -y install php8.1-redis
sudo apt-get -y install php8.1-memcached
sudo apt-get -y install php8.1-json
sudo apt-get -y install php8.1-zip
sudo apt-get -y install php8.1-xml
sudo apt-get -y install php8.1-soap
sudo apt-get -y install php8.1-gd
sudo apt-get -y install php8.1-imagick
sudo apt-get -y install php8.1-fileinfo
sudo apt-get -y install php8.1-imap
sudo apt-get -y install php8.1-cli
PHPINI=/etc/php/8.1/fpm/conf.d/linkpanel.ini
sudo touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 1999
max_input_time = 1999
EOF
sudo service php8.1-fpm restart
sleep 10s

sudo apt-get -y install php8.2-fpm
sudo apt-get -y install php8.2-common
sudo apt-get -y install php8.2-curl
sudo apt-get -y install php8.2-openssl
sudo apt-get -y install php8.2-bcmath
sudo apt-get -y install php8.2-mbstring
sudo apt-get -y install php8.2-tokenizer
sudo apt-get -y install php8.2-mysql
sudo apt-get -y install php8.2-sqlite3
sudo apt-get -y install php8.2-pgsql
sudo apt-get -y install php8.2-redis
sudo apt-get -y install php8.2-memcached
sudo apt-get -y install php8.2-json
sudo apt-get -y install php8.2-zip
sudo apt-get -y install php8.2-xml
sudo apt-get -y install php8.2-soap
sudo apt-get -y install php8.2-gd
sudo apt-get -y install php8.2-imagick
sudo apt-get -y install php8.2-fileinfo
sudo apt-get -y install php8.2-imap
sudo apt-get -y install php8.2-cli
PHPINI=/etc/php/8.2/fpm/conf.d/linkpanel.ini
sudo touch $PHPINI
sudo cat > "$PHPINI" <<EOF
memory_limit = 256M
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 1999
max_input_time = 1999
EOF
sudo service php8.2-fpm restart
sleep 10s

# PHP EXTRA
sudo apt-get -y install php-dev php-pear


# PHP CLI
clear
echo "${bggreen}${black}${bold}"
echo "PHP CLI configuration..."
echo "${reset}"
sleep 10s

sudo update-alternatives --set php /usr/bin/php8.2



# COMPOSER
clear
echo "${bggreen}${black}${bold}"
echo "Composer setup..."
echo "${reset}"
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
echo "${reset}"
sleep 10s

sudo apt-get -y install git
sudo ssh-keygen -t rsa -C "git@github.com" -f /etc/linkpanel/github -q -P ""



# SUPERVISOR
clear
echo "${bggreen}${black}${bold}"
echo "Supervisor setup..."
echo "${reset}"
sleep 10s

sudo apt-get -y install supervisor
service supervisor restart
service supervisor status
sleep 10s



# DEFAULT VHOST
clear
echo "${bggreen}${black}${bold}"
echo "Default vhost..."
echo "${reset}"
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
echo "${reset}"
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
/usr/bin/mysql -u root -p$DBPASS <<EOF
use mysql;
CREATE USER 'linkpanel'@'%' IDENTIFIED WITH mysql_native_password BY '$DBPASS';
GRANT ALL PRIVILEGES ON *.* TO 'linkpanel'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF



# REDIS
clear
echo "${bggreen}${black}${bold}"
echo "Redis setup..."
echo "${reset}"
sleep 5s

sudo apt install -y redis-server
sudo rpl -i -w "supervised no" "supervised systemd" /etc/redis/redis.conf
sudo systemctl restart redis.service
sudo systemctl status redis.service
sleep 15s



# LET'S ENCRYPT
clear
echo "${bggreen}${black}${bold}"
echo "Let's Encrypt setup..."
echo "${reset}"
sleep 5s

sudo apt-get install -y certbot
sudo apt-get install -y python3-certbot-nginx



# NODE
clear
echo "${bggreen}${black}${bold}"
echo "Node/npm setup..."
echo "${reset}"
sleep 5s

curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
NODE=/etc/apt/sources.list.d/nodesource.list
sudo unlink NODE
sudo touch $NODE
sudo cat > "$NODE" <<EOF
deb https://deb.nodesource.com/node_20.x noble main
deb-src https://deb.nodesource.com/node_20.x noble main
EOF
sudo apt-get update
sudo apt -y install nodejs
sudo apt -y install npm




#PANEL INSTALLATION
clear
echo "${bggreen}${black}${bold}"
echo "And now LinkPanel installation begin..."
echo "${reset}"
sleep 15s


/usr/bin/mysql -u root -p$DBPASS <<EOF
CREATE DATABASE IF NOT EXISTS linkpanel;
EOF
clear
sudo rm -rf /var/www/html
cd /var/www/html && git clone https://github.com/$REPO.git
cd /var/www/html && git pull
cd /var/www/html && git checkout $BRANCH
cd /var/www/html && git pull
cd /var/www/html && sudo unlink .env
cd /var/www/html && sudo cp .env.example .env
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
echo "${reset}"
sleep 1s

sudo chown www-data:linkpanel -R /var/www/html
sudo chmod -R 750 /var/www/html
sudo echo 'DefaultStartLimitIntervalSec=1s' >> /usr/lib/systemd/system/user@.service
sudo echo 'DefaultStartLimitBurst=50' >> /usr/lib/systemd/system/user@.service
sudo echo 'StartLimitBurst=0' >> /usr/lib/systemd/system/user@.service
sudo systemctl daemon-reload

TASK=/etc/cron.d/linkpanel.crontab
touch $TASK
cat > "$TASK" <<EOF
10 4 * * 7 certbot renew --nginx --non-interactive --post-hook "systemctl restart nginx.service"
20 4 * * 7 apt-get -y update
40 4 * * 7 DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical sudo apt-get -q -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" dist-upgrade
20 5 * * 7 apt-get clean && apt-get autoclean
50 5 * * * echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a
* * * * * cd /var/www/html && php artisan schedule:run >> /dev/null 2>&1
5 2 * * * cd /var/www/html/utility/linkpanel-update && sh run.sh >> /dev/null 2>&1
EOF
crontab $TASK
sudo systemctl restart nginx.service
sudo rpl -i -w "#PasswordAuthentication" "PasswordAuthentication" /etc/ssh/sshd_config
sudo rpl -i -w "# PasswordAuthentication" "PasswordAuthentication" /etc/ssh/sshd_config
sudo rpl -i -w "PasswordAuthentication no" "PasswordAuthentication yes" /etc/ssh/sshd_config
sudo rpl -i -w "PermitRootLogin yes" "PermitRootLogin no" /etc/ssh/sshd_config
sudo service sshd restart
TASK=/etc/supervisor/conf.d/linkpanel.conf
touch $TASK
cat > "$TASK" <<EOF
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
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start all
sudo service supervisor restart

# COMPLETE
clear
echo "${bggreen}${black}${bold}"
echo "LinkPanel installation has been completed..."
echo "${reset}"
sleep 1s




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
echo " SSH root user: atsi"
echo " SSH root pass: $PASS"
echo " MySQL root user: atsi"
echo " MySQL root pass: $DBPASS"
echo ""
echo " To manage your server visit: http://$IP"
echo " and click on 'dashboard' button."
echo " Default credentials are: admin / admin1230"
echo ""
echo "***********************************************************"
echo "          DO NOT LOSE AND KEEP SAFE THIS DATA"
echo "***********************************************************"
