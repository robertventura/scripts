#!/bin/bash

# Instalem PHP per MySQL
yum install -y php php-mysql

# Activem el servei
systemctl enable httpd.service

# Iniciem Apache
systemctl start httpd