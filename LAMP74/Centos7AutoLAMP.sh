#!/bin/bash
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
yum -y install epel-release
yum -y install nano mlocate wget expect
updatedb
sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
yum -y install mariadb-server mariadb
systemctl start mariadb.service
systemctl enable mariadb.service
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Switch to unix_socket authentication\"
send \"n\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"
yum -y install httpd httpd-devel
systemctl start httpd.service
systemctl enable httpd.service
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-service=mysql
firewall-cmd --reload
firewall-cmd --reload
firewall-cmd --reload
rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum update
yum-config-manager --enable remi-php74
yum -y install php php-opcache
systemctl restart httpd.service
printf "<?php\n\techo phpinfo();\n?>" > /var/www/html/info.php
yum search php
yum -y install php-mysqlnd php-pdo
yum -y install php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-soap curl curl-devel php-devel pcre-devel gcc
systemctl restart httpd.service
yum -y install phpMyAdmin

mv /etc/httpd/conf.d/phpMyAdmin.conf /etc/httpd/conf.d/phpMyAdmin.conf.backup
wget https://galihbarkah.com/script/phpMyAdmin.conf
cp phpMyAdmin.conf /etc/httpd/conf.d/