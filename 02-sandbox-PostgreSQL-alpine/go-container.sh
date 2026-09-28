#!/bin/bash

# Colores
RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BLUE='\033[1;34m'

# clear

while true; do
    # Obtener lista de contenedores corriendo (solo nombres)
    mapfile -t CONTAINERS < <(docker ps --format '{{.Names}}' | sort)

    if [ ${#CONTAINERS[@]} -eq 0 ]; then
        echo -e "${RED}No hay contenedores corriendo actualmente.${RESET}"
        exit 1
    fi

    echo -e "\n${BLUE}===========================================${RESET}"
    echo -e "${BOLD}  Contenedores Docker en ejecución$  v0.2 ${RESET}"
    echo -e "${BLUE}===========================================${RESET}"
    echo ""

    for i in "${!CONTAINERS[@]}"; do
        num=$((i + 1))
        echo -e "${YELLOW}  ${num})${RESET} ${CONTAINERS[$i]}"
    done
	
	echo -e "\n${BLUE}  x)${RESET} Salir\n"

    # echo -e "${RESET}Elegí un contenedor para ingresar:${RESET}"
    read -rp "Elige un contenedor para ingresar: " opcion

    # Salir
    if [[ "$opcion" == "x" || "$opcion" == "X" ]]; then
        echo -e "${CYAN}Saliendo...${RESET}\n"
        exit 0
    fi

    # Validar que sea un número
    if ! [[ "$opcion" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Opción inválida. Presioná Enter para continuar...${RESET}"
        read -r
        clear
        continue
    fi

    # Validar rango
    if [ "$opcion" -lt 1 ] || [ "$opcion" -gt "${#CONTAINERS[@]}" ]; then
        echo -e "${RED}Número fuera de rango. Presioná Enter para continuar...${RESET}"
        read -r
        clear
        continue
    fi

    CONTAINER_NAME="${CONTAINERS[$((opcion - 1))]}"
    echo -e "${CYAN}Ingresando al contenedor: ${BOLD}${CONTAINER_NAME} : ${RESET}"

    # Detectar shell disponible (sin abrir sesión interactiva)
    if docker exec "$CONTAINER_NAME" sh -c 'command -v bash >/dev/null 2>&1'; then
		echo -e "${BLUE}bash disponible, usando bash...\n${RESET}"
        SHELL_CMD="bash"
    elif docker exec "$CONTAINER_NAME" sh -c 'command -v sh >/dev/null 2>&1'; then
        echo -e "${BLUE}bash no disponible, usando sh...\n${RESET}"
        SHELL_CMD="sh"
    else
        echo -e "${RED}El contenedor no tiene ni bash ni sh. Presioná Enter para continuar...${RESET}"
        read -r
        clear
        continue
    fi

    docker exec -it "$CONTAINER_NAME" "$SHELL_CMD"




    echo ""
    echo -e "${CYAN}Saliste del contenedor '${CONTAINER_NAME}'. Volviendo al menú...${RESET}"
    sleep 1
    clear
done