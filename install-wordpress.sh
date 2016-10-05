#!/bin/bash

# install PHP and MySQL
yum install -y php php-mysql mysql mysql-server mysql-devel mysql-libs
chkconfig httpd on
chkconfig mysqld on

# Download Wordpress
curl https://wordpress.org/latest.tar.gz | tar -xz -C /var/www/html

export DB_NAME=wordpress
export DB_USER=wordpress
export DB_PWD=password

# Create Wordpress database configuration file
cat > /var/www/html/wordpress/wp-config.php << EOF
<?php
define('DB_NAME',          '$DB_NAME');
define('DB_USER',          '$DB_USER');
define('DB_PASSWORD',      '$DB_PWD');
define('DB_HOST',          'localhost');
define('DB_CHARSET',       'utf8');
define('DB_COLLATE',       '');
EOF

curl -L https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/html/wordpress/wp-config.php

cat >> /var/www/html/wordpress/wp-config.php << EOF
define('WPLANG'            , '');
define('WP_DEBUG'          , false);
\$table_prefix  = 'wp_';
if ( !defined('ABSPATH') )
   define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
EOF

chown -R apache:apache /var/www/html/wordpress

# Start Apache
/etc/init.d/httpd start

# Start MySQL
/etc/init.d/mysqld start

# Setup Password and create database
mysqladmin -u root password "$DB_PWD"

mysql -u root --password="$DB_PWD" << EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PWD';
GRANT ALL ON wordpress.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

#Initialize Wordpress user & demo site
export WEBSITE_NAME=Demo
export WEBSITE_USER=admin
export WEBSITE_PWD=password
export WEBSITE_EMAIL=name@domainXYZ.com
export HOST=$(curl 169.254.169.254/latest/meta-data/public-hostname/)

curl -XPOST http://$HOST/wordpress/wp-admin/install.php?step=2 -d "weblog_title=$WEBSITE_NAME&user_name=$WEBSITE_USER&admin_password=$WEBSITE_PWD&admin_password2=$WEBSITE_PWD&admin_email=$WEBSITE_EMAIL&blog_public=1&Submit=Install+WordPress"

















# hack to ensure IP adress is correctly updated inside the database at startup
wget -O /etc/rc3.d/S99_WP_CHANGEIP_HACK http://public-sst.s3.amazonaws.com/demo/wordpress_changeip_hack.sh
chmod 700 /etc/rc3.d/S99_WP_CHANGEIP_HACK
