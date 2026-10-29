# Shared database package

`@apimirror/database` owns the PostgreSQL connection factory, Drizzle schemas and migration history. It has no dependency on the backend or its authentication configuration.

Install dependencies with `bun install --frozen-lockfile` from the repository root. The backend, playground and this package are Bun workspaces; the frontend retains its independent installation.

Each server creates one connection pool using its own configuration:

```ts
import { createDatabase, type Database } from "@apimirror/database";
import { project } from "@apimirror/database/schema";

const { db, pool } = createDatabase(databaseURL);
// Pass db to repositories; call pool.end() when shutting down.
```

Schemas live in `src/schema/`. SQL migrations, snapshots and the journal live in `drizzle/`. Keep the existing history when changing schema files.

Run `bun run db:generate`, `bun run db:migrate` or `bun run db:studio` from `backend/`. Its Drizzle configuration points to this package and uses the backend's existing database environment settings. `bun run db:seed` also remains in the backend because the seed creates Better Auth credentials.

Run `bun run typecheck` at the repository root to check all three workspaces. The playground depends on `@apimirror/database` using `workspace:*` and creates its own pool with the same factory.
