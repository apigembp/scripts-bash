#!/usr/bin/env bash
set -euo pipefail

# install-configure.sh
# Installe et configure le serveur OpenSSH sur AlmaLinux:
# - installe le paquet openssh-server via dnf
# - active (enable) et démarre le service systemd sshd
# - autorise le root login (PermitRootLogin yes)

# Couleurs pour la lisibilité
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérification que le script est lancé en root
if [[ $EUID -ne 0 ]]; then
	echo -e "${RED}Ce script doit être lancé en tant que root.${NC}"
	exit 1
fi

echo -e "${YELLOW}---> [1/4] Installation d'openssh-server...${NC}"
dnf install -y openssh-server

echo -e "${YELLOW}---> [2/4] Activation et démarrage du service sshd...${NC}"
systemctl enable --now sshd

echo -e "${YELLOW}---> [3/4] Configuration: autoriser le root login (PermitRootLogin yes)...${NC}"
SSHD_CONF="/etc/ssh/sshd_config"
if [[ ! -f "$SSHD_CONF" ]]; then
	echo -e "${RED}Fichier $SSHD_CONF introuvable. Abort.${NC}"
	exit 1
fi

# Sauvegarde timestampée
BACKUP="${SSHD_CONF}.bak.$(date +%s)"
cp -a "$SSHD_CONF" "$BACKUP"
echo -e "  sauvegarde: ${BACKUP}"

# Remplacement idempotent de la directive PermitRootLogin
TMPFILE="/tmp/sshd_config.$(date +%s)"
awk '
	BEGIN{found=0}
	/^[[:space:]]*#?[[:space:]]*PermitRootLogin[[:space:]]+/ {
		print "PermitRootLogin yes"
		found=1
		next
	}
	/^[[:space:]]*Match[[:space:]]+/ && !found {
		print "PermitRootLogin yes"
		found=1
	}
	{ print }
	END{ if(!found) print "PermitRootLogin yes" }
' "$SSHD_CONF" > "$TMPFILE"

mv "$TMPFILE" "$SSHD_CONF"
chmod 600 "$SSHD_CONF"
echo -e "  mise à jour: $SSHD_CONF (PermitRootLogin yes)"

echo -e "${YELLOW}---> [4/4] Redémarrage du service sshd...${NC}"
systemctl restart sshd

if systemctl is-active --quiet sshd; then
	echo -e "${GREEN}sshd actif${NC}"
else
	echo -e "${RED}ERREUR : Le service sshd n'a pas pu démarrer.${NC}"
	echo -e "${YELLOW}Consultez 'systemctl status sshd' pour plus d'information.${NC}"
	systemctl status sshd --no-pager || true
	exit 1
fi

echo -e "${GREEN}=== Installation terminée ===${NC}"
echo -e "Directive active: $(grep -i '^PermitRootLogin' $SSHD_CONF || true)"
echo -e "Pour vérifier: systemctl status sshd --no-pager"

echo -e "${GREEN}Script terminé.${NC}"
