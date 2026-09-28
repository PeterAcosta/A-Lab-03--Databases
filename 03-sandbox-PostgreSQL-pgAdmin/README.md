<img src="docker-postgres-pgadmin.jpg" alt="Contenedor Docker con PostgreSQL 18.6" />

# Sandbox: PostgreSQL 18.6 y pgAdmin 4

Este directorio contiene un entorno local de desarrollo y aprendizaje compuesto por dos contenedores Docker: PostgreSQL 18.6 sobre Alpine y pgAdmin 4 para administrar el servidor desde una interfaz web. Docker Compose construye ambas imágenes a partir de sus respectivos Dockerfiles y conecta los servicios en una red privada.

## Componentes

| Servicio | Contenedor | Imagen base | Uso |
| --- | --- | --- | --- |
| `my-postgresql` | `04-postgresql` | `postgres:18.6-alpine3.24` | Motor de base de datos PostgreSQL |
| `my-pgadmin` | `05-pgadmin` | `dpage/pgadmin4:9.18` | Administración de PostgreSQL mediante navegador |

- PostgreSQL publica el puerto `5432` del contenedor en el puerto definido por `POSTGRES_PORT` en el host.
- pgAdmin publica el puerto `80` del contenedor en el puerto definido por `PGADMIN_PORT` en el host. Con la configuración de ejemplo, se accede a través de `http://localhost:5050`.
- Los contenedores se conectan mediante la red bridge `00-net-devel-02`, con direcciones fijas `172.30.0.4` (PostgreSQL) y `172.30.0.5` (pgAdmin). Desde pgAdmin, el host de la base de datos es el nombre de servicio `my-postgresql` y el puerto es `5432`.
- `depends_on` inicia PostgreSQL antes que pgAdmin, pero no comprueba que el servidor de base de datos ya esté listo para aceptar conexiones.

## Configuración

Docker Compose carga automáticamente las variables del archivo `.env` de este directorio. Para preparar la configuración local, copia `.env.example` como `.env` y ajusta sus valores:

```sh
cp .env.example .env
```

Configura las variables:  
`POSTGRES_USER`, `POSTGRES_PASSWORD` y `POSTGRES_DB` para el usuario inicial y la base de datos.  
`PGADMIN_DEFAULT_EMAIL` y `PGADMIN_DEFAULT_PASSWORD` definen las credenciales de acceso a pgAdmin;  
`POSTGRES_PORT` y `PGADMIN_PORT` seleccionan los puertos publicados en el host.

Los valores de `.env.example` son solo de referencia: reemplaza las contraseñas antes de usar el entorno y no publiques el archivo `.env`.

## Iniciar el entorno

Desde este directorio, construye las imágenes e inicia los contenedores en segundo plano:

```sh
docker compose -f docker-compose.yaml up -d --build
```

Comprueba su estado y consulta los logs:

```sh
docker compose -f docker-compose.yaml ps
docker compose -f docker-compose.yaml logs -f
```

Abre `http://localhost:<PGADMIN_PORT>` —`http://localhost:5050` con el puerto de ejemplo— e inicia sesión con `PGADMIN_DEFAULT_EMAIL` y `PGADMIN_DEFAULT_PASSWORD`.

### Registrar PostgreSQL en pgAdmin

En pgAdmin, crea una conexión de servidor y completa estos datos:

- **Host name/address:** `my-postgresql`
- **Port:** `5432`
- **Maintenance database:** el valor de `POSTGRES_DB`
- **Username:** el valor de `POSTGRES_USER`
- **Password:** el valor de `POSTGRES_PASSWORD`

El nombre del servicio funciona como hostname dentro de la red Docker; `localhost` en pgAdmin apuntaría al propio contenedor de pgAdmin, no al contenedor de PostgreSQL.

## Datos persistentes

Compose administra dos volúmenes nombrados:

- `04-vol-postgresql-database`, montado en `/var/lib/postgresql`, conserva los datos de PostgreSQL.
- `05-vol-pgadmin-data`, montado en `/var/lib/pgadmin`, conserva los datos de configuración de pgAdmin.

Detener y eliminar los contenedores no elimina estos volúmenes:

```sh
docker compose -f docker-compose.yaml down
```

Para eliminar también los volúmenes y **borrar permanentemente los datos** de ambos servicios:

```sh
docker compose -f docker-compose.yaml down -v
```

## Acceso a PostgreSQL y contenedores

Conéctate a PostgreSQL con `psql` dentro del contenedor:

```sh
docker exec -it 04-postgresql psql -U <POSTGRES_USER> -d <POSTGRES_DB>
```

También puedes abrir una shell en el contenedor:

```sh
docker exec -it 04-postgresql bash
docker exec -it 05-pgadmin bash
```

El script `go-container.sh` ofrece un menú interactivo para elegir un contenedor en ejecución y abrir una shell disponible en él.

## Personalizaciones de las imágenes

- `Dockerfile.04-postgres-alpine` parte de la imagen oficial PostgreSQL 18.6 Alpine e instala `nano`. Su entrypoint personalizado muestra información del sistema y luego delega en el entrypoint oficial, que conserva la inicialización estándar de PostgreSQL.
- `Dockerfile.05-pgAdmin` parte de `dpage/pgadmin4:9.18`, instala `nano` y `tzdata` y configura ajustes de shell. Su entrypoint personalizado registra el inicio y delega en el entrypoint oficial de pgAdmin.
- Ambos servicios usan la zona horaria `America/Argentina/Buenos_Aires`.

## Autor

**Pedro Javier Acosta**

- LinkedIn: [linkedin.com/in/acosta-peter](https://linkedin.com/in/acosta-peter)
- GitHub: [github.com/peteracosta](https://github.com/peteracosta)
