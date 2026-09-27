<img src="docker-postgres-alpine.jpg" alt="Contenedor Docker con PostgreSQL 18.6" />

# Docker sandbox: PostgreSQL 18.6 sobre Alpine 3.24

Entorno local para practicar el uso y la administración de PostgreSQL en un
contenedor Docker, sin instalar el servidor en el equipo anfitrión. La imagen
oficial `postgres:18.6-alpine3.24` combina PostgreSQL 18.6 con Alpine Linux
3.24.


## Componentes y arquitectura

```text
           Cliente PostgreSQL
                   │
                   │ localhost:5432
                   ▼
┌──────────────────────────────────────┐
│ Contenedor: 04-postgresql            │
│ Servicio:   my-postgresql            │
│ Imagen:     04-image-postgresql      │
│ Base:       postgres:18.6-alpine3.24 │
└──────────────────┬───────────────────┘
                   │
                   │ datos persistentes
                   ▼
       04-vol-postgresql-database

Red bridge: 00-net-devel-02 (172.30.0.0/16)
IP del contenedor: 172.30.0.4
```

- **Compose** (`docker-compose.yaml`): define el servicio, el puerto publicado,
  las variables de inicialización, el volumen y la red bridge con dirección
  IP fija.
- **Imagen** (`Dockerfile.04-postgres-alpine`): parte de
  `postgres:18.6-alpine3.24`, establece la zona horaria y las variables de
  identificación de la imagen, y configura el entrypoint personalizado.  
  **No instala herramientas adicionales: los bloques para instalar Bash y
  personalizar el entorno están comentados.
- **Entry point** (`entrypoint.04-postgres-alpine.sh`): muestra la versión del
  sistema y de PostgreSQL y luego ejecuta el entrypoint oficial de PostgreSQL,
  conservando la inicialización normal de la imagen.
- **Persistencia**: el volumen nombrado `04-vol-postgresql-database` se monta
  en `/var/lib/postgresql`; sobrevive a la eliminación del contenedor.
- **Red**: `00-net-devel-02` usa el rango `172.30.0.0/16`, la puerta de enlace
  `172.30.0.1` y asigna `172.30.0.4` al contenedor.
- **Zona horaria**: `America/Argentina/Buenos_Aires`.

## Requisitos

- Docker Engine.
- Docker Compose v2 (`docker compose`).

## Configuración y puesta en marcha

El archivo `.env.example` sirve como plantilla. Cree el archivo local `.env`
(si aún no existe) y ajuste el usuario, la contraseña, la base de datos y el
puerto según sus necesidades:

```bash
cp -n .env.example .env
```

La plantilla usa estos valores de ejemplo:

| Variable | Valor de ejemplo |
| --- | --- |
| `POSTGRES_USER` | `my_user_db_name` |
| `POSTGRES_PASSWORD` | `una_clave_larga_y_aleatoria` |
| `POSTGRES_DB` | `my_database_name` |
| `POSTGRES_PORT` | `5432` |
| `TZ` | `America/Argentina/Buenos_Aires` |

`POSTGRES_PORT` es el puerto del anfitrión; el servidor escucha en el puerto
`5432` dentro del contenedor. Compose lee `.env` automáticamente al ejecutarse
desde este directorio.
Los valores `POSTGRES_USER`, `POSTGRES_PASSWORD` y `POSTGRES_DB` se aplican
cuando PostgreSQL inicializa un volumen vacío. Si el volumen ya contiene una
base de datos, cambiar `.env` no cambia automáticamente las credenciales ni
crea otra base.

Construir la imagen y arrancar el servicio:

```bash
docker compose up -d --build
```

Comprobar el estado y consultar los registros:

```bash
docker compose ps
docker compose logs -f my-postgresql
```

Abrir una shell en el contenedor Alpine:

```bash
docker exec -it 04-postgresql /bin/sh
```

Conectarse desde el contenedor con `psql` (reemplace los valores por los que
configuró en `.env`):

```bash
docker exec -it 04-postgresql psql -U my_user_db_name -d my_database_name
```

También puede conectarse desde el anfitrión con un cliente PostgreSQL:

```bash
psql -h localhost -p 5432 -U my_user_db_name -d my_database_name
```

Si cambió `POSTGRES_PORT`, use ese puerto en lugar de `5432`. Para conectarse
desde otro equipo, use la IP del anfitrión y asegúrese de que el puerto esté
permitido por el firewall.

## Detener el entorno y administrar los datos

Detener y eliminar el contenedor y la red administrados por Compose, conservando
el volumen:

```bash
docker compose down
```

Volver a iniciar el entorno:

```bash
docker compose up -d
```

**Para eliminar también los datos de PostgreSQL**, ejecutar:

```bash
docker compose down -v
```

La opción `-v` elimina `04-vol-postgresql-database`; los datos almacenados allí
no se podrán recuperar.

## Archivos del directorio

```text
.
├── .env.example                       # Plantilla de variables para Compose
├── .gitignore                         # Excluye el archivo local .env
├── docker-compose.yaml                # Servicio, puerto, red, credenciales y volumen
├── Dockerfile.04-postgres-alpine      # Imagen basada en PostgreSQL 18.6 sobre Alpine 3.24
├── entrypoint.04-postgres-alpine.sh   # Muestra versiones y delega al entrypoint oficial
├── go-container.sh                    # Menú para abrir shells en contenedores activos
└── Makefile                           # Atajos para tareas Docker
```

`go-container.sh` es un menú interactivo que requiere Bash y Docker en el
anfitrión. Permite seleccionar un contenedor activo e intenta abrir Bash; si no
está disponible, usa `/bin/sh`.

El `Makefile` contiene algunos atajos, pero también objetivos que afectan
recursos Docker ajenos a este stack. **No ejecutar `make wipe`,
`make delete_all_images` ni `make delete_all_volumes` sin revisar su alcance**:
pueden borrar imágenes o volúmenes de otros proyectos, incluidos datos que no
se pueden recuperar. Para las operaciones habituales, se recomienda usar
directamente `docker compose`.

## Seguridad y convivencia con otros stacks

Este entorno es para desarrollo y aprendizaje, no para producción. El archivo
`.env` puede contener credenciales y está excluido de Git; no lo publiques ni
uses contraseñas reales en un entorno expuesto. Los valores de `.env.example`
son ilustrativos y deben cambiarse antes de iniciar el servicio.

El puerto se publica en todas las interfaces del anfitrión según la forma
`${POSTGRES_PORT}:5432`. Si se necesita acceso solo local, se puede restringir
la publicación en `docker-compose.yaml` a `127.0.0.1:${POSTGRES_PORT}:5432`.

Este stack reutiliza nombres fijos para el contenedor, el volumen y la red
(`04-postgresql`, `04-vol-postgresql-database` y `00-net-devel-02`). Por ello,
puede entrar en conflicto con otros stacks del repositorio que usen los mismos
nombres; no deben ejecutarse simultáneamente sin cambiar esos identificadores
y revisar el direccionamiento de red.

## Autor

**Pedro Javier Acosta**

- LinkedIn: [linkedin.com/in/acosta-peter](https://linkedin.com/in/acosta-peter)
- GitHub: [github.com/peteracosta](https://github.com/peteracosta)
