#!/bin/bash

#--
#-- Script per la instal·lació d'un ReplicaSet de MongoDB per docker
#-- Extret de la URL: http://www.sohamkamani.com/blog/2016/06/30/docker-mongo-replica-set/
#--
#-- Topologia :
#--     xarxa: my-mongo-cluster
#--		ReplicaSet: my-mongo-rset
#-- 	mongo1 (PRIMARY)
#-- 		port:27017-->30001
#-- 	mongo2 (SECONDARY)
#-- 		port:27017-->30002
#-- 	mongo3 (SECONDARY)
#-- 		port:27017-->30003

#-- verifiquem que tenim docker
docker -v

#-- Ens assegurem que el servei està actiu
docker images

#-- Estirem la imatge de mongoDB del repositori de Docker
docker pull mongo

docker images

#-- Creem una nova xarxa anomenada my-mongo-cluster
docker network create my-mongo-cluster

#-- ---------------------------------
#-- Configurem els nostres containers
#-- ---------------------------------

echo "Aixecant el node mongo1...."

docker run \
-p 30001:27017 \
--name mongo1 \
--net my-mongo-cluster \
mongo mongod --replSet my-mongo-rset &

echo "Aixecant el node mongo2...."
docker run \
-p 30002:27017 \
--name mongo2 \
--net my-mongo-cluster \
mongo mongod --replSet my-mongo-rset &

echo "Aixecant el node mongo3...."
docker run \
-p 30003:27017 \
--name mongo3 \
--net my-mongo-cluster \
mongo mongod --replSet my-mongo-rset &

echo "Iniciant el nostre ReplicaSet (my-mongo-rset)...."
docker exec -it mongo1 mongo << EOF
rs.initiate({
  	"_id" : "my-mongo-rset",
  	"members" : [
  		{
  			"_id" : 0,
  			"host" : "mongo1:27017"
  		},
  		{
  			"_id" : 1,
  			"host" : "mongo2:27017"
  		},
  		{
  			"_id" : 2,
  			"host" : "mongo3:27017"
  		}
  	]
  })
EOF



