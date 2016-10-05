#!/bin/bash

#--
#-- Script per la instal·lació de WikiMedia en un servidor CentOS 7.0
#-- Requisits:
#--		CentOS 7
#--

## Declaració de variables
url_scripts="https://raw.githubusercontent.com/robertventura/scripts/master/"


## Realitzem un UPDATE dels paquets
curl -fsSL ${url_scripts}centos70-update.sh | sh

## Instal·lació d'Apache
curl -fsSL ${url_scripts}cento70-install-apache.sh | sh

## Instal·lació d'Percona MySQL
curl -fsSL ${url_scripts}centos70-install-percona-server.sh | sh

## Instal·lació PHP
curl -fsSL ${url_scripts}centos70-install-php.sh | sh

## Extensions necessàries de PHP
yum install -y php-xml php-intl php-gd texlive

#yum install epel-release php-xcache

sudo systemctl restart httpd.service

curl -O http://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.1.tar.gz

tar xvzf mediawiki-*.tar.gz

mkdir -p /var/www/html/mediawiki

mv mediawiki-1.27.1/* /var/www/html/mediawiki

chown -R apache:apache /var/www/html/mediawiki

export DB_NAME=wiki
export DB_USER=wiki
export DB_PWD=P0t@t0es

mysql -u root --password="$DB_PWD" << EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PWD';
GRANT INDEX, CREATE, SELECT, INSERT, UPDATE, DELETE, ALTER, LOCK TABLES ON wiki.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

#Faltaria editar els fitxers de configuració

	

	
