#!/bin/bash

# Instalem PHP per MySQL
yum install -y php php-mysql

# Activem els serveis onboot
chkconfig httpd on

# Activem els serveis onboot
chkconfig httpd on

# Iniciem Apache
/etc/init.d/httpd start