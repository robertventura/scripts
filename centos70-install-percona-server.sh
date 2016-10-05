#!/bin/bash

#Versió del Percona server a instal·lar.
versio=57

# Afegim el repositori de Percona
yum install -y http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm

# Instal·lem el SGBD Percona Server
yum install -y Percona-Server-server-$versio


# Activem el servei
systemctl enable mysql.service
systemctl start  mysql.service

#Obtenim el pwd temporal del fitxer /var/log/mysqld
#Busquem la línia "[Note] A temporary password is generated for root@localhost: "
#cat /var/log/mysqld.log  | grep  "A temporary password is generated for root@localhost"

echo "executa mysql_secure_installation"


yum -y install expect

// Not required in actual script
MYSQL_ROOT_PASSWORD=P0t@t0es

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL\r\"
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

yum -y remove expect

