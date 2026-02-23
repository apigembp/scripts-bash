#!/usr/bin/env bash

# ==============================================================================
# Script d'installation automatique de Docker & Docker Compose sur Debian
# Basé sur la documentation officielle de Docker
# ==============================================================================

# Couleurs pour la lisibilité
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

set -euo pipefail

# Vérification que le script est lancé en root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Ce script doit être lancé en tant que root.${NC}"
   exit 1
fi

echo -e "${GREEN}=== Début de l'installation de Docker sur Debian ===${NC}"

# Prérequis : Suppression des anciennes versions et des paquets conflictuels
echo -e "${YELLOW}---> [1/6] Suppression des anciennes versions de Docker et des paquets conflictuels...${NC}"
apt remove -y docker.io docker-compose docker-doc podman-docker containerd runc

# Mise à jour du système
echo -e "${YELLOW}---> [2/6] Mise à jour du système (apt update & upgrade)...${NC}"
apt update -y
apt upgrade -y

# Ajout des dépendances nécessaires
echo -e "${YELLOW}---> [3/6] Installation des dépendances pour le dépôt Docker...${NC}"
apt install -y ca-certificates curl gnupg

# Ajout de la clé GPG officielle de Docker et du dépôt
echo -e "${YELLOW}---> [4/6] Ajout de la clé GPG et du dépôt Docker officiel...${NC}"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Détection de la version de Debian (codename)
source /etc/os-release
echo "Types: deb" > /etc/apt/sources.list.d/docker.sources
echo "URIs: https://download.docker.com/linux/debian" >> /etc/apt/sources.list.d/docker.sources
echo "Suites: $VERSION_CODENAME" >> /etc/apt/sources.list.d/docker.sources
echo "Components: stable" >> /etc/apt/sources.list.d/docker.sources
echo "Signed-By: /etc/apt/keyrings/docker.asc" >> /etc/apt/sources.list.d/docker.sources

# Mise à jour des dépôts
apt update -y

# Installation de Docker Engine et Docker Compose
echo -e "${YELLOW}---> [5/6] Installation de Docker Engine et Docker Compose...${NC}"
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#  Activation et démarrage du service
echo -e "${YELLOW}---> [6/6] Activation et démarrage du service Docker...${NC}"
systemctl enable --now docker

# Vérification si le service a bien démarré
if systemctl is-active --quiet docker; then
    echo -e "${GREEN}Service Docker démarré avec succès !${NC}"
else
    echo -e "${RED}ERREUR : Le service Docker n'a pas pu démarrer.${NC}"
    exit 1
fi

# Vérification finale
echo -e "${GREEN}=== Installation terminée ! ===${NC}"
echo -e "Version de Docker :"
docker --version
echo -e "Version de Docker Compose :"
docker compose version

echo -e "${YELLOW}Tentative d'exécution de hello-world...${NC}"
docker run hello-world

echo -e "${GREEN}Script terminé.${NC}"
