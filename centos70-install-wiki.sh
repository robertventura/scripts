#!/bin/bash

#--
#-- Script per la instal·lació de WikiMedia en un servidor CentOS 7.0
#-- Requisits:
#--		CentOS 7
#--

## Declaració de variables
url_scripts="https://raw.githubusercontent.com/robertventura/scripts/master/"


## Realitzem un UPDATE dels paquets
curl -fsSL ${url_scripts}update-centos70.sh | sh

## Instal·lació d'Apache
curl -fsSL ${url_scripts}install-apache-centos70.sh | sh

## Instal·lació d'Percona MySQL
curl -fsSL ${url_scripts}install-percona-server-centos70.sh | sh

## Instal·lació PHP
curl -fsSL ${url_scripts}install-php-centos70.sh | sh


	

	
