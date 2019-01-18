#!/bin/bash
echo "===== LAMP Install ====="
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
yum -y install epel-release
echo "Installing Apache..."
yum -y install httpd
systemctl start httpd.service
systemctl enable httpd.service
yum -y install mod_ssl
echo "Installing MariaDB..."
yum -y install mariadb-server mariadb
systemctl start mariadb.service
systemctl enable mariadb.service
mysql_secure_installation
echo "Setting Firewall..."
firewall-cmd --permanent --zone=public --add-service=http 
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
echo "Installing PHP..."
rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum -y update
yum-config-manager --enable remi-php72
yum -y install php php-opcache
systemctl restart httpd.service
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
if [ $(curl -s -G http://127.0.0.1/info.php | grep -q 'phpinfo' ; echo $?) == '0' ] ; then
echo "PHP is working" ; else
echo "PHP is NOT working" ; fi
yum search php
yum -y install php-mysqlnd php-pdo
yum -y install php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-soap curl curl-devel
yum -y install php php-cli vim php-fpm php-mysqlnd git php-opcache php-lz4 php-lzma php-gd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json -q
systemctl restart httpd.service
echo "Installing phpMyAdmin..."
yum -y install phpMyAdmin
curl -o /etc/httpd/conf.d/phpMyAdmin.conf https://raw.githubusercontent.com/akkradet/lamp/master/phpMyAdmin.conf
systemctl restart httpd.service
