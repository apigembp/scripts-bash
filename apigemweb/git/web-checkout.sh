#!/usr/bin/env bash
set -e

# Couleurs pour la lisibilité
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérification qu'une branche a bien été passée en argument
if [ -z "$1" ]; then
    echo -e "${RED}Erreur : Vous devez spécifier le nom d'une branche ou d'un tag.${NC}"
    echo "Usage : apigem-checkout <nom-de-la-branche>"
    exit 1
fi

BRANCH="$1"
DOCKER_DIR="/home/apigem/docker/apigemweb"

echo -e "${YELLOW}Récupération des nouveautés et bascule vers la branche '$BRANCH'...${NC}"

# On se déplace dans le dossier contenant le docker-compose.yml
cd "$DOCKER_DIR"

# Exécution de la commande dans le conteneur (fetch puis checkout)
docker compose exec -u www-data apigemweb bash -c "cd /var/www/html/ApigemWebMVC && git fetch && git checkout $BRANCH"

echo -e "${GREEN} Bascule sur '$BRANCH' terminée avec succès.${NC}"