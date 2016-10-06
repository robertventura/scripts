#!/bin/bash

#--
#-- Script per la instal·lació de WikiMedia en un servidor CentOS 7.0
#-- Requisits:
#--		CentOS 7
#--

## Declaració de variables
export url_scripts="https://raw.githubusercontent.com/robertventura/scripts/master/"


## Realitzem un UPDATE dels paquets
curl -fsSL ${url_scripts}centos70-update.sh | sh

## Instal·lació d'Apache
curl -fsSL ${url_scripts}centos70-install-apache.sh | sh

## Instal·lació d'Percona MySQL
curl -fsSL ${url_scripts}centos70-install-percona-server.sh | sh

## Instal·lació PHP
curl -fsSL ${url_scripts}centos70-install-php.sh | sh

## Extensions necessàries de PHP
yum install -y php-xml php-intl php-gd texlive

#yum install epel-release php-xcache

systemctl restart httpd.service

#curl -O http://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.1.tar.gz
wget http://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.1.tar.gz

tar xvzf mediawiki-*.tar.gz

mkdir -p /var/www/html/mediawiki

mv mediawiki-1.27.1/* /var/www/html/mediawiki

chown -R apache:apache /var/www/html/mediawiki

export DB_NAME=wiki
export DB_USER=wikiuser
export DB_PWD=P0t@t0es

mysql -u root --password="$DB_PWD" << EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PWD';
GRANT INDEX, CREATE, SELECT, INSERT, UPDATE, DELETE, ALTER, LOCK TABLES ON wiki.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

#-- ------------------
#--Preparació del site
#-- ------------------

#mkdir /etc/httpd/sites-available
#mkdir /etc/httpd/sites-enable

#Modificquem el fitxer /etc/httpd/conf/httpd.conf i afegim al final
IncludeOptional sites-enabled/*.conf

#Creem el fitxer 
#vi /etc/httpd/sites-available/example.com.conf
#<VirtualHost *:80>
#
#    ServerName www.example.com
#    ServerAlias example.com
#    DocumentRoot /var/www/example.com/public_html
#    ErrorLog /var/www/example.com/error.log
#    CustomLog /var/www/example.com/requests.log combined
#</VirtualHost>

#Creem l'enllaç simbòlic per tal d'habilitar el site
#ln -s /etc/httpd/sites-available/example.com.conf /etc/httpd/sites-enabled/example.com.conf

#Afegim la directriu per selinux
#chcon -R -t httpd_sys_content_t /var/www/mediawiki/

#Faltaria editar els fitxers de configuració
#nano /var/www/html/LocalSettings.php
#https://www.digitalocean.com/community/tutorials/how-to-install-mediawiki-on-centos-7
	

	
#Incorporar sintaxi per llenguatges:
#https://www.mediawiki.org/wiki/Extension:SyntaxHighlight#Installation