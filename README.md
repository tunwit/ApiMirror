# Project setup

ApiMirror uses Bun, Elysia, PostgreSQL and Drizzle in the backend, with Next.js and TanStack Query in the frontend. Better Auth handles username-and-password authentication.

- `backend/`: Better Auth server, PostgreSQL connection, authentication schema and migrations. The API listens on port 3001; authentication endpoints live under `/api/auth`.
- `frontend/`: Simple sign-in and create-account pages, a Better Auth React client, and a protected dashboard on one domain.

## Commands

The root `.env` supplies `POSTGRES_USER`, `POSTGRES_PASSWORD` and `POSTGRES_DB` to Docker and the backend. Existing credentials are preserved. Start PostgreSQL from the project root:

```sh
# Only needed once, if the external network does not exist:
docker network create api-mirror-network
docker compose up -d postgres
```

`backend/.env` contains a generated local `BETTER_AUTH_SECRET` and local URLs. On a new checkout, copy `backend/.env.example` to `backend/.env` and replace the placeholder secret with a random value of at least 32 characters. Never commit `.env` files. You can set `DATABASE_URL` in `backend/.env` to override the root PostgreSQL settings.

Inside `backend/`:

```sh
bun install --frozen-lockfile
bun run db:migrate
bun run dev
```

Inside `frontend/`, in another terminal:

```sh
bun install --frozen-lockfile
bun run dev
```

Use the same frontend domain for every user:

- Sign in: `http://localhost:3000/signin`
- Create an account: `http://localhost:3000/signup`
- Dashboard: `http://localhost:3000/dashboard`

Browser authentication requests to `/api/auth/*` are proxied to Elysia at `http://localhost:3001`. Better Auth uses a normal host-only HttpOnly session cookie. The protected dashboard layout forwards that cookie to the backend session helper and redirects unauthenticated users to `/signin`. Each session identifies its user; dashboard URLs do not contain usernames. No custom domains, subdomains, handoff tickets, or hosts-file entries are required.

Restart both development servers after changing configuration. `FRONTEND_URL=http://localhost:3000` configures the backend's trusted frontend origin. `NEXT_PUBLIC_APP_URL=http://localhost:3000` is the frontend URL, and `NEXT_PUBLIC_API_URL=http://localhost:3001` is the server session helper's backend address. For deployment, update these URLs and the backend rewrite destination and use HTTPS.

## Using authentication in a client component

Import `authClient` and `useSession` from `app/lib/auth.ts` using the relative path for your component.

```ts
// Signup still requires an email and name in Better Auth's standard username plugin.
const signup = await authClient.signUp.email({
  name: "Alex Morgan",
  email: "alex@example.com",
  username: "alex",
  password: "a-long-unique-password",
});

// Login uses username and password, without an email.
const signin = await authClient.signIn.username({
  username: "alex",
  password: "a-long-unique-password",
});

// Check result.error before treating signup or login as successful.
const session = await authClient.getSession();
await authClient.signOut();
```

`useSession()` exposes the signed-in user, loading state and errors in React. The client sends cookies automatically. Usernames contain 3–30 letters, digits, underscores or dots and are normalized to lowercase. Passwords must contain at least 8 characters. Password hashing and session cookies are handled by Better Auth.

Backend routes can check a session with `auth.api.getSession({ headers: request.headers })` and return 401 when it is null. The authentication server and database credentials stay in the backend. No separate Next.js authentication handler is needed.

## Verification and schema changes

Run `bun run typecheck` in each app. In `backend/`, run `bun run test:auth` with PostgreSQL running to exercise the frontend client through Elysia against the database. Tests create uniquely named temporary users and remove their own records afterwards.

After changing the Drizzle schema, run `bun run db:generate`, review the generated SQL, then run `bun run db:migrate`. The initial migration includes `user`, `account`, `session`, and `verification`, including username fields. It has already been applied to the local database during setup.

Email verification, password reset email delivery, social sign-in and dashboard features are not configured.

References: [Better Auth username plugin](https://better-auth.com/docs/plugins/username), [Elysia integration](https://better-auth.com/docs/integrations/elysia), [Drizzle PostgreSQL](https://orm.drizzle.team/docs/get-started-postgresql).
