#!/usr/bin/env bash

# ==============================================================================
# Script d'installation automatique de Docker & Docker Compose sur AlmaLinux 9 LXC
# Basé sur https://www.linuxtricks.fr/wiki/red-hat-alma-linux-installer-docker
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

echo -e "${GREEN}=== Début de l'installation de Docker sur AlmaLinux 9 LXC ===${NC}"

# 1. Prérequis : Suppression de podman et buildah
echo -e "${YELLOW}---> [1/6] Suppression de podman et buildah (conflits potentiels)...${NC}"
dnf remove -y podman buildah

# 2. Mise à jour du système
echo -e "${YELLOW}---> [2/6] Mise à jour du système (dnf upgrade)...${NC}"
# On installe d'abord dnf-plugins-core nécessaire pour config-manager
dnf install -y dnf-plugins-core
dnf upgrade -y

# 3. Ajout des dépôts
echo -e "${YELLOW}---> [3/6] Ajout du dépôt Docker officiel (Version CentOS)...${NC}"
# Comme indiqué dans le tuto, RHEL 9 n'est pas supporté officiellement, on utilise le repo CentOS
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 4. Installation de Docker Engine et Docker Compose
echo -e "${YELLOW}---> [4/6] Installation de Docker Engine et du plugin Compose...${NC}"
# Installation combinée du moteur et du plugin compose
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 5. Activation et démarrage du service
echo -e "${YELLOW}---> [5/6] Démarrage du service Docker...${NC}"
systemctl enable --now docker

# Vérification si le service a bien démarré (Souvent problématique en LXC si Nesting OFF)
if systemctl is-active --quiet docker; then
    echo -e "${GREEN}Service Docker démarré avec succès !${NC}"
else
    echo -e "${RED}ERREUR : Le service Docker n'a pas pu démarrer.${NC}"
    echo -e "${YELLOW}ASTUCE LXC : Vérifiez que l'option 'Nesting' est activée dans les options de votre conteneur (Proxmox).${NC}"
    exit 1
fi


# 6. Vérification finale
echo -e "${YELLOW}---> [6/6] Vérification de l'installation...${NC}"
echo -e "${GREEN}=== Installation terminée ! ===${NC}"
echo -e "Version de Docker :"
docker --version
echo -e "Version de Docker Compose :"
docker compose version

echo -e "${YELLOW}Tentative d'exécution de hello-world...${NC}"
docker run hello-world

echo -e "${GREEN}Script terminé.${NC}"