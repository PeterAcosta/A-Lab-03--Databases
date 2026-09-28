#!/bin/sh
set -e

date +"1 - %Y-%m-%d  %A  %T - Entrypoint : starting pgAdmin [ $THIS_IMAGE_TAG $THIS_IMAGE ]" \
    >> /tmp/00-pgAdmin-docker-init.log 2>/dev/null || true

# Delega en el entrypoint oficial de la imagen
exec /entrypoint.sh "$@"

