<img src="docker-postgres-debian.jpeg" alt="Contenedor Docker con PostgreSQL 18.6" />

# Docker sandbox: PostgreSQL 18.6 sobre Debian 13 Trixie

Entorno local para levantar un servidor PostgreSQL en un contenedor Docker y
practicar su administración sin instalar el servidor directamente en el
equipo anfitrión. El stack consta de un servicio de base de datos, un volumen
persistente y una red Docker dedicada.


## Componentes y arquitectura

```text
Aplicación / cliente PostgreSQL
               │
               │ localhost:5432
               ▼
┌──────────────────────────────┐
│ 04-postgresql                │
│ PostgreSQL 18.6              │
│ Imagen: postgres:18.6-trixie │
└──────────────┬───────────────┘
               │
               │ datos persistentes
               ▼
   04-vol-postgresql-database

Red Docker: 00-net-devel-02 (bridge, 172.30.0.0/16)
```

- **`04-postgresql`**: servicio definido en `docker-compose.yaml`. Construye
  una imagen local desde `Dockerfile.04-postgresql` y publica el puerto
  PostgreSQL `5432` del contenedor en el puerto `5432` del anfitrión.
- **Imagen base**: `postgres:18.6-trixie`, que incluye PostgreSQL 18.6 sobre
  Debian 13 Trixie. El Dockerfile agrega `nano` y `mc`, configura la zona
  horaria y personaliza el prompt de Bash.
- **Entry point**: `entrypoint.04-postgresql.sh` muestra información del
  sistema y de PostgreSQL y luego delega el arranque al entrypoint oficial de
  la imagen PostgreSQL.
- **Persistencia**: el volumen nombrado `04-vol-postgresql-database` se monta
  en `/var/lib/postgresql`, de modo que los datos sobreviven al borrado del
  contenedor.
- **Red**: `00-net-devel-02` es una red bridge con la subred `172.30.0.0/16`.
- **Zona horaria**: `America/Argentina/Buenos_Aires`.

## Requisitos

- Docker Engine.
- Docker Compose v2 (`docker compose`).

## Puesta en marcha

Desde este directorio, construir la imagen y arrancar el servicio:

```bash
docker compose up -d --build
```

Comprobar el estado y consultar los logs:

```bash
docker compose ps
docker compose logs -f my-postgresql
```

Para abrir una shell en el contenedor:

```bash
docker exec -it 04-postgresql bash
```

Para conectarse a la base de datos desde el propio contenedor:

```bash
docker exec -it 04-postgresql psql -U postgres -d postgres
```

El servicio configura estos valores iniciales en `docker-compose.yaml`:

| Parámetro | Valor |
| --- | --- |
| Usuario | `postgres` |
| Contraseña | `postgres` |
| Base de datos | `postgres` |
| Puerto publicado | `5432` |

Un cliente PostgreSQL instalado en el anfitrión puede conectarse a
`localhost:5432` con esas credenciales.  
**IMPORTANTE:** Usuario y Contraseña de estudio y pruebas , no llevar a produccion

## Detener el entorno y conservar los datos

```bash
docker compose down
```

Este comando elimina el contenedor y la red de Compose, pero conserva el
volumen de datos. Para volver a iniciar el entorno:

```bash
docker compose up -d
```

**Para borrar también los datos de PostgreSQL**, ejecutar:

```bash
docker compose down -v
```

La opción `-v` elimina el volumen `04-vol-postgresql-database`; la información
guardada allí no se podrá recuperar.

## Estructura principal

```text
.
├── docker-compose.yaml          # Servicio, puertos, red, credenciales y volumen
├── Dockerfile.04-postgresql     # Imagen personalizada basada en PostgreSQL 18.6
├── entrypoint.04-postgresql.sh  # Información inicial y delegación al entrypoint oficial
├── Makefile                     # Atajos y comandos heredados de otros experimentos
└── go-container.sh              # Menú interactivo para entrar a contenedores activos
```

El archivo `go-container.sh` muestra los contenedores en ejecución y permite
abrir una shell con Bash (o con `sh` si Bash no está disponible). Requiere que
Docker esté instalado y que el usuario tenga permiso para ejecutar comandos
Docker.

El `Makefile` contiene algunos objetivos útiles, como `bake`, `rebuild` y
`rerun`, pero también incluye comandos heredados de otros stacks y operaciones
potencialmente destructivas. En particular, **no ejecutar `make wipe` sin
revisarlo**: elimina todas las imágenes Docker locales y el volumen de datos de
este servicio. Para las operaciones habituales, se recomienda usar directamente
`docker compose`.


## Conectarse a PostgreSQL desde fuera
Si el contenedor publica el puerto `5432`, podemos conectarnos desde otro equipo utilizando `psql`:

```bash
psql -h IP_DEL_SERVIDOR -p 5432 -U postgres -d NOMBRE_BASE
```

Ejemplo (desde entorno local):

```bash
psql -h localhost -p 5432 -U postgres -d postgres
```

> El puerto `5432` debe estar publicado por Docker y permitido por el firewall del servidor.




## Notas de seguridad

Este entorno está pensado para desarrollo y aprendizaje local, no para
producción. La contraseña `postgres` está definida directamente en el archivo
Compose y el puerto `5432` se publica sin restringir la dirección del
anfitrión. Antes de utilizar o exponer este servicio fuera del equipo local:

- Cambiar y gestionar de forma segura las credenciales.
- Restringir la publicación del puerto y revisar las reglas de red.
- Configurar copias de seguridad y una política de recuperación de datos.

## Autor

**Pedro Javier Acosta**

- LinkedIn: [linkedin.com/in/acosta-peter](https://linkedin.com/in/acosta-peter)
- GitHub: [github.com/peteracosta](https://github.com/peteracosta)
