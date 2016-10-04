#!/bin/bash

#--
#-- Script per la instal·lació del Percona Monitoring and Management Server
#-- Requisits:
#--		CentOS 7
#-- 	Instal·lada una versió de Docker 
#--

#Definició de variables
versio_pmm = "1.0.4"
port_host = "80"
pmm_data_nom = "pmm-data"
pmm_server_nom = "pmm-server"

# Preparem un container per dades
docker create \
	-v /opt/prometheus/data \
	-v /opt/consul-data \
	-v /var/lib/mysql \
	--name $pmm_data_nom \
	percona/pmm-server:$versio_pmm /bin/true

#Preparem el container del PMM-Server
docker run -d \
	-p $port_host:80 \
	--volumes-from $pmm_data_nom \
	--name $pmm_server_nom \
	--restart always \
	percona/pmm-server:$versio_pmm

	

	

	
