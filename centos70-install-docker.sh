#!/bin/bash

#-- Script per la instal·lació de Docker en un CentOS7

# Fem un update dels paquets
yum update -y

#Afegim el repositori de Docker
 tee /etc/yum.repos.d/docker.repo <<-'EOF'
 [dockerrepo]
 name=Docker Repository
 baseurl=https://yum.dockerproject.org/repo/main/centos/7/
 enabled=1
 gpgcheck=1
 gpgkey=https://yum.dockerproject.org/gpg
EOF


# Instal·lem el paquet de docker
yum install -y docker-engine

# execució del script d'instal·lació (això és el mateix que els dos passos anteriors)
#curl -fsSL https://get.docker.com/ | sh

# Activem el servei
systemctl enable docker.service

# Iniciem el servei Docker
systemctl start docker

# Verifiquem la instl·lació mitjançant l'execució d'una container de prova
docker run --rm hello-world
