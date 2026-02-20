#!/usr/bin/env bash
set -e

# Couleurs pour la lisibilité
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Chemin fixe vers le projet Docker
DOCKER_DIR="/home/apigem/docker/apigemweb"

echo -e "${YELLOW}Lancement du git pull pour ApigemWebMVC...${NC}"

# On se déplace dans le dossier contenant le docker-compose.yml
cd "$DOCKER_DIR"

# Exécution de la commande dans le conteneur
docker compose exec -u www-data apigemweb bash -c "cd /var/www/html/ApigemWebMVC && git pull"

echo -e "${GREEN}Pull terminé avec succès.${NC}"