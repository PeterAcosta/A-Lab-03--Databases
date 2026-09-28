# Makefile for docker

# LINE-1="\033[0;34m==================================================================================================================================\033[0m"
# LINE-2="\n\033[0;34m==================================================================================================================================\033[0m"
# LINE-3="\n\033[0;34m---------------------------------------------------------------------------------------------------------------------------------\033[0m"

# LINE-1="\033[0;34m-------------------------------------------------------------------------------------------------------------------------------------\033[0m"
# LINE-2="\n\033[0;34m-------------------------------------------------------------------------------------------------------------------------------------\033[0m"
# LINE-3="\n\033[0;34m-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -   \033[0m"


# DOCKER-PS-AQ=$(shell docker ps -aq)


# Proporciona ayuda
.PHONY: help
help: ## 			ayuda
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//' | sort


bake: ##                  Usa docker compose BAKE para construir y levantar los contenedores
	COMPOSE_BAKE=true docker compose up -d

wipe: ## 			Arrasa con todo, cierra todo, borras las imagenes y borra los directorios
	@ echo " "
	@sudo -v
	docker compose down 
	docker rmi  $$(docker images -aq )
## 	Ojo borra el volumen :
	docker volume rm 04-vol-postgresql-database




rebuild:  ## 		Detiene los contenedores, borra las imagens y recontruye todo
	clear 
	@echo $(C2a)"Deteniendo los contenedores:\n"$(LINE-1)$(C0)
	docker compose down
	@echo  $(C2a)$(LINE-1)"\n Borrando imagenes:"$(C0)
	docker rmi  $$(docker images -aq )	
	@echo  $(C2a)$(LINE-1)"\n Reconstruyendo imagenes y iniciando contenedores:"$(C0)
	docker compose up 

rerun: ## 		Detiene los contenedores y los vuelve a ejecutar
	clear 
	@echo $(C2a)"Deteniendo los contenedores:\n"$(LINE-1)$(C0)
	docker compose down
	@echo  $(C2a)$(LINE-1)"\n Re-iniciando contenedores:"$(C0)
	docker compose up 


delete_all_images: ## 	Borra todas TODAS  las imagenes 
	docker rmi  $$(docker images -aq )


delete_all_volumes: ## 	Borra todos los volumenes
	docker volume rm $$(docker volume ls -q)


# delete_all_directories: ##Borra todos los directorios
#	sudo rm -R v-03-mariadb-logs/
#	sudo rm -R v-03-mariadb-backups/    


pull_all_images: ## 	Hace el pull de todas las imagenes base necesarias
	docker pull nginx:1.25.2-bookworm
	docker pull php:8.2.9-fpm-bookworm
#	docker pull node:alpine3.17


delete_images: ## 	Borra las 3 imagenes de este stack
	docker rmi  01-image-php-8.2.6  
	docker rmi  02-image-node-3.17
# 	docker rmi  03-image-mariadb


# bring_gulp:
# 	docker cp 09-gulp:/workdir/package.json      ./gulp
# 	docker cp 09-gulp:/workdir/package-lock.json ./gulp
# 	docker cp 09-gulp:/workdir/node_modules     ./gulp

gulp: ##			Ejecuta gulp dentro de su contenedor
	docker exec -ti 09-gulp gulp


permissions-fix: ##	Arregla los permisos de los directorios y archivos del proyecto
	sudo chown -R $$(id -u):$$(id -g) .
	chmod -R u+rw .