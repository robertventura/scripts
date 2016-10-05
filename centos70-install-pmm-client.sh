#!/bin/bash


# Afegim el repositori de Percona
yum install -y http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm

#Amb la següent comanda mirem quins paquets percona podem instal·lar
#yum list | grep percona

# Instal·lem el PMM client
yum install -y pmm-client