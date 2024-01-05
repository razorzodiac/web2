#!/bin/sh

#########################################################################################
# Bash script to install Web Application and OSTicket Application For CSIRT Organization
# Written by Badan Siber dan Sandi Negara
#########################################################################################

# COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
                                             

#echo "#   .----------------.  .----------------.  .----------------.  .-----------------."
#echo "#  | .--------------. || .--------------. || .--------------. || .--------------. |"
#echo "#  | |   ______     | || |    _______   | || |    _______   | || | ____  _____  | |"
#echo "#  | |  |_   _ \    | || |   /  ___  |  | || |   /  ___  |  | || ||_   \|_   _| | |"
#echo "#  | |    | |_) |   | || |  |  (__ \_|  | || |  |  (__ \_|  | || |  |   \ | |   | |"
#echo "#  | |    |  __'.   | || |   '.___`-.   | || |   '.___`-.   | || |  | |\ \| |   | |"
#echo "#  | |   _| |__) |  | || |  |`\____) |  | || |  |`\____) |  | || | _| |_\   |_  | |"
#echo "#  | |  |_______/   | || |  |_______.'  | || |  |_______.'  | || ||_____|\____| | |"
#echo "#  | |              | || |              | || |              | || |              | |"
#echo "#  | '--------------' || '--------------' || '--------------' || '--------------' |"
#echo "#   '----------------'  '----------------'  '----------------'  '----------------' "


                                                
echo "$Yellow--------------------------------------------------------------------------"
echo "$Yellow*****  AUTOMATION INSTALLATION SCRIPT FOR WEB CSIRT & OSTICKET 2023  *****"
echo "$Yellow*****     DIREKTORAT KEAMANAN SIBER DAN SANDI PEMERINTAH DAERAH      *****"
echo "$Yellow*****              BADAN SIBER DAN SANDI NEGARA                      *****"
echo "$Yellow--------------------------------------------------------------------------"
echo "$Yellow* Tested on Ubuntu 20.04, 22.04, 23.04.                                  *"
echo "$Yellow* @adpermana                                                             *"
echo "$Yellow--------------------------------------------------------------------------"

echo "$Purple Pilihlah Salah Satu Untuk Instalasi :$Color_Off"
echo "$Purple [1] Web Application CSIRT v1.1 2024 $Color_Off"
echo "$Purple [2] OSTicket v1.17.2 Application $Color_Off"
echo -n "$Purple Pilihan Anda : " 
read choice

Install_PHP7(){
# Update packages and Upgrade system
echo "$Red \n***** INSTALLATION PROCESS ****** $Color_Off"
echo "$Cyan \nUpdating System.. $Color_Off"
apt update -y
apt -y install software-properties-common
add-apt-repository ppa:ondrej/php -y

# Configuration for Libgd3 PHP7.4
sed -i 's/lunar/jammy/' /etc/apt/sources.list.d/ondrej-ubuntu-php-lunar.list
apt update -y
touch /etc/apt/preferences.d/ondrejphp
cat << 'EOF' > /etc/apt/preferences.d/ondrejphp
Package: libgd3
Pin: release n=lunar
Pin-Priority: 900
EOF

# Install PHP7.4
echo "$Cyan \nInstalling PHP 7.4 & Requirements $Color_Off"
apt-get install aptitude -y
aptitude install libapache2-mod-php7.4 php7.4 php7.4-cli php7.4-json php7.4-common php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath -y
echo "$Cyan \nCheck PHP Version $Color_Off"
php -v    
}

Install_PHP8(){
# Update packages and Upgrade system
echo "$Red \n***** INSTALLATION PROCESS ****** $Color_Off"
echo "$Cyan \nUpdating System.. $Color_Off"
apt update -y
apt -y install software-properties-common
add-apt-repository ppa:ondrej/php -y

echo "$Cyan \nInstalling PHP 8.1 & Requirements $Color_Off"
apt update -y
#apt install php8.1 libapache2-mod-php8.1 php8.1-cli php-json php8.1-common php8.1-mysql php8.1-zip php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml php8.1-bcmath -y
apt install php libapache2-mod-php php-cli php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-bcmath -y
echo "$Cyan \nCheck PHP Version $Color_Off"
php -v
}

Install_AMP(){
# Check IP System
check_ip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

# Install Apache2
echo "$Cyan \nInstalling Apache2.. $Color_Off"
apt-get install apache2 apache2-utils ssl-cert unzip wget curl -y
a2enmod rewrite

# Install MySQL Server
echo "$Cyan \nInstalling MySQL.. $Color_Off"
apt-get install mysql-server -y

# Starting Service
echo "$Cyan \nStarting Apache2 and MySQL $Color_Off"
systemctl start apache2
systemctl start mysql
systemctl enable apache2
systemctl enable mysql
}

WebCSIRT_Configuration(){
# Install Composser
echo "$Cyan \nInstalling Composser.. $Color_Off"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Download Web Application Source
echo "$Cyan \nStart Downloading Web App CSIRT.. $Color_Off"
wget "https://cloud.bssn.go.id/s/4fFrNAKqrQYn2s2/download?path=%2F8.%20Web%20Aplikasi%20CSIRT&files=MasterWebCSIRT_2022_v01.zip" -O WEB-CSIRT.zip
unzip WEB-CSIRT.zip

# Configure Permission Files
echo "$Cyan \nConfiguring Permission Files.. $Color_Off"
rm -rf ./MasterWebCSIRT_2022/template-csirt/public/storage/
cp -r ./MasterWebCSIRT_2022/template-csirt/ /var/www/html
mv /var/www/html/template-csirt /var/www/html/csirt
chown -R www-data:www-data /var/www/html/csirt
chmod -R 775 /var/www/html/csirt/storage

# Configure Apache2 Files
echo "$Cyan \nConfiguring Apache2 Files.. $Color_Off"
touch /etc/apache2/sites-available/webcsirt.conf
cat << 'EOF' > /etc/apache2/sites-available/webcsirt.conf
<VirtualHost *:80>
    ServerAdmin domain.go.id
    ServerName domain.go.id
    DocumentRoot /var/www/html/csirt/public
     
    <Directory /var/www/html/csirt>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

a2dissite 000-default.conf
a2ensite webcsirt.conf
systemctl restart apache2

# Generate Random Password
tmp_pass=0
if [ $tmp_pass = 0 ]; then
    tmp_pass=`tr -dc A-Za-z0-9 </dev/urandom | head -c 15`
fi

# Insert data for database
username="adminCSIRT"
dbname="dbwebcsirt"
userpass=$tmp_pass
dir=$PWD

# Insert to Database
echo "$Cyan \nInsert Data to MySQL Database $Color_Off"
mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpass}';"
mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${username}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
mysql -u ${username} -p${userpass} ${dbname} < $dir/MasterWebCSIRT_2022/template_csirt.sql
echo "$Green \nDatabase successfully configured! $Color_Off"

echo "$Cyan \nConfiguring Composser.. $Color_Off"
file_env=/var/www/html/csirt/.env

# Variable for environment
app_env=production
app_debug=false
fs_driver=public

# Database credential
database_csirt=$dbname
user_mysql=$username
pass_mysql=$userpass

# Insert data to file .env
sed -i 's/APP_ENV=.*/APP_ENV='$app_env'/' $file_env
sed -i 's/APP_DEBUG=.*/APP_DEBUG='$app_debug'/' $file_env
sed -i 's/FILESYSTEM_DRIVER=.*/FILESYSTEM_DRIVER='$fs_driver'/' $file_env
sed -i 's/DB_DATABASE=.*/DB_DATABASE='$database_csirt'/' $file_env
sed -i 's/DB_USERNAME=.*/DB_USERNAME='$user_mysql'/' $file_env
sed -i 's/DB_PASSWORD=.*/DB_PASSWORD='$pass_mysql'/' $file_env

# Migrate Laravel Composser
cd /var/www/html/csirt/
composer update -n
composer install -n
php artisan key:generate --force
php artisan cache:clear -n
php artisan migrate --force
php artisan storage:link --force

echo "$Purple --------------------------------------------------------------------------------------------------$Color_Off"
echo "$Purple \nPlease Access to : http://$check_ip $Color_Off"
echo "$Purple \nUpdate Whitelist IP to access Login-Page : http://$check_ip/csirt-login $Color_Off"
echo "$Purple --------  WEB CSIRT MYSQL/DATABASE CREDENTIAL  --------$Color_Off"
echo "$Purple # Your MySQL Database : $dbname $Color_Off"
echo "$Purple # Your MySQL User     : $username $Color_Off"
echo "$Purple # Your MySQL Password : $userpass $Color_Off"
echo "$Purple -------------------------------------------------------$Color_Off"
echo "$Purple \nInstallation Web CSIRT Finished!! $Color_Off"
echo "$Purple --------------------------------------------------------------------------------------------------$Color_Off"
}

OSTicket_Configuration(){
# Install Dependencies
echo "$Cyan \nInstalling Dependencies.. $Color_Off"
apt install php-cgi php-fpm php-imap php-pear php-intl php8.2-apcu php-common -y

# Download OSTicket v1.17.2
echo "$Cyan \nDownloading OSTicket Sources.. $Color_Off"
wget https://github.com/osTicket/osTicket/releases/download/v1.17.2/osTicket-v1.17.2.zip -O OSTicket-v1.17.2.zip
mkdir /var/www/html/osticket
unzip OSTicket-v1.17.2.zip -d /var/www/html/osticket
chown -R www-data:www-data /var/www/html/osticket
chmod -R 755 /var/www/html/osticket
mv /var/www/html/osticket/upload/include/ost-sampleconfig.php /var/www/html/osticket/upload/include/ost-config.php

# Generate Random Password
tmp_pass_osticket=0
if [ $tmp_pass_osticket = 0 ]; then
    tmp_pass_osticket=`tr -dc A-Za-z0-9 </dev/urandom | head -c 15`
fi

# Insert data for database
username_osticket="adminOSTicket"
dbname_osticket="dbosticket"
userpass_osticket=$tmp_pass_osticket

# Insert to Database
echo "$Cyan \nInsert Data to MySQL Database $Color_Off"
mysql -e "CREATE DATABASE ${dbname_osticket} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -e "CREATE USER ${username_osticket}@localhost IDENTIFIED BY '${userpass_osticket}';"
mysql -e "GRANT ALL PRIVILEGES ON ${dbname_osticket}.* TO '${username_osticket}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
echo "$Green \nDatabase successfully configured! $Color_Off"

# Configure VirtualHost for OSTicket
echo "$Cyan \nConfiguring Apache2 Files.. $Color_Off"
touch /etc/apache2/sites-available/osticket.conf
cat << 'EOF' > /etc/apache2/sites-available/osticket.conf
<VirtualHost *:80>
    ServerAdmin domain.go.id
    ServerName domain.go.id
    DocumentRoot /var/www/html/osticket/upload
     
    <Directory /var/www/html/osticket/upload>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

a2dissite 000-default.conf
a2ensite osticket.conf
systemctl restart apache2

echo "$Purple --------------------------------------------------------------------------------------------------$Color_Off"
echo "$Purple \nPlease Access to : http://$check_ip $Color_Off"
echo "$Purple --------  OSTICKET MYSQL/DATABASE CREDENTIAL  --------$Color_Off"
echo "$Purple # Your MySQL Database : $dbname_osticket $Color_Off"
echo "$Purple # Your MySQL User     : $username_osticket $Color_Off"
echo "$Purple # Your MySQL Password : $userpass_osticket $Color_Off"
echo "$Purple -------------------------------------------------------$Color_Off"
echo "$Purple \nInstallation OSTicket Finished!! $Color_Off"
echo "$Purple --------------------------------------------------------------------------------------------------$Color_Off"
}

restartApache2(){
# Restart Apache
echo "$Cyan \nRestarting Apache $Color_Off"
service apache2 restart
echo "$Cyan \nDone!!$Color_Off"
}

Wazuh_Installation(){
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh && sudo bash ./wazuh-install.sh -a
}

if [ $choice -eq 1 ] 
then
    echo "$Yellow----------------------------------------------------------"
    echo "$Yellow*****  WEB APPLICATION CSIRT v1.1 2024 INSTALLATION  *****"
    echo "$Yellow----------------------------------------------------------"
    Install_PHP8
    Install_AMP
    WebCSIRT_Configuration
    restartApache2
elif [ $choice -eq 2 ]
then
    echo "$Yellow-------------------------------------------------------"
    echo "$Yellow*****  OSTICKET v1.17.2 APPLICATION INSTALLATION  *****"
    echo "$Yellow-------------------------------------------------------"
    Install_PHP8
    Install_AMP
    OSTicket_Configuration
    restartApache2
else
    exit 0;
fi