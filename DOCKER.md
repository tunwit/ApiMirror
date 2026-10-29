# Docker

Each service has its own `Dockerfile`, `compose.yaml`, `.env`, and `.env.example`.
Every Compose service loads only its own `.env`:

```yaml
env_file:
  - .env
```

All services join the external `api-mirror-network`. The existing root `docker-compose.yaml` runs PostgreSQL on the same network.

## Environment files

The existing `.env` files are configured for Docker. On a fresh checkout, copy each `.env.example` to `.env` in the same directory, then fill in real credentials.

- Root `.env`: PostgreSQL user, password, and database.
- `backend/.env`: the same database credentials, `POSTGRES_HOST=postgres`, `POSTGRES_PORT=5432`, `PORT=3001`, `BETTER_AUTH_SECRET`, and public auth/frontend/playground URLs.
- `playground/.env`: the same database credentials, `POSTGRES_HOST=postgres`, `POSTGRES_PORT=5432`, and `PLAYGROUND_PORT=3002`.
- `frontend/.env`: `NEXT_PUBLIC_API_URL=http://backend:3001` and `NEXT_PUBLIC_APP_URL=http://localhost:3000`.

Backend and playground use `DATABASE_URL=` (empty) to select the `POSTGRES_*` settings. Actual credentials remain in ignored `.env` files and are excluded from Docker images.

For running directly on your computer instead of Docker, change `POSTGRES_HOST` to `localhost`, the frontend API URL to `http://localhost:3001`, and `NODE_ENV` to `development` in the relevant `.env` files.

## Build

Run these commands inside each app directory (`backend`, `playground`, then `frontend`):

```sh
docker compose build
```

Compose automatically reads that directory's `.env` for frontend build arguments as well as runtime settings. Rebuild the frontend when changing `NEXT_PUBLIC_*` values.

Default image names are `local/apimirror-backend:local`, `local/apimirror-playground:local`, and `local/apimirror-frontend:local`. Optional `DOCKERHUB_USERNAME` and `IMAGE_TAG` entries in each `.env` customize image names. Nothing is pushed automatically.

## Run

Create the network once if it does not already exist:

```sh
docker network create api-mirror-network
```

From the repository root, start the existing PostgreSQL stack:

```sh
docker compose -f docker-compose.yaml up -d --wait postgres
```

Then, inside `backend`, `playground`, and `frontend` respectively:

```sh
docker compose up -d --no-build --wait
```

Start in that order because separate Compose projects cannot use `depends_on` across projects. Stop existing local development servers if they occupy ports 3000–3002.

Frontend: http://localhost:3000. Backend: http://localhost:3001. Playground: http://localhost:3002.

This setup builds the current code. It does not apply migrations, seed accounts, or configure production HTTPS. A fresh database needs the existing schema applied separately.

Run `docker compose down` inside an app directory to stop only that app. PostgreSQL and the shared external network remain in place.
