#!/bin/bash

#install-apache-centos70.sh

# Instalem Apache
yum -y install httpd

# Activem el servei
systemctl start httpd.service

# Iniciem Apache
systemctl start httpd


#Activem les regles del firewall
firewall-cmd --permanent --add-port=80/tcp

firewall-cmd --permanent --add-port=443/tcp

firewall-cmd --reload