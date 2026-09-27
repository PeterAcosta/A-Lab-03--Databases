#!/bin/sh

set -e

# Colores ANSI
BLUE='\033[94m'
RESET='\033[0m'

# Información del sistema
DOCKER_OS_VERSION=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d '"' -f2)
POSTGRES_VERSION=$(postgres --version)

printf "\n\n"
printf "${BLUE}=====================================================================${RESET}\n"
printf "  04 - PostgreSQL\n"
printf "${BLUE}---------------------------------------------------------------------${RESET}\n"
printf "  Image       : %s\n" "${THIS_IMAGE}"
printf "  Tag         : %s\n" "${THIS_IMAGE_TAG}"
printf "  TZ          : %s\n" "${TZ}"
printf "${BLUE}---------------------------------------------------------------------${RESET}\n"
printf "  Sistema     : %s\n" "${DOCKER_OS_VERSION}"
printf "  PostgreSQL  : %s\n" "${POSTGRES_VERSION}"
printf "${BLUE}=====================================================================${RESET}\n"
printf "\n\n\n"




# ---------------------------------------------------------------------
# Ejecutar el ENTRYPOINT oficial de PostgreSQL
# ---------------------------------------------------------------------
#
# La imagen oficial de PostgreSQL ya trae su propio entrypoint:
#
# /usr/local/bin/docker-entrypoint.sh
#
# No debemos reemplazar su funcionamiento.
# Nuestro script simplemente hace las personalizaciones anteriores
# y luego le entrega el control al entrypoint oficial.
# ---------------------------------------------------------------------

exec /usr/local/bin/docker-entrypoint.sh "$@"
