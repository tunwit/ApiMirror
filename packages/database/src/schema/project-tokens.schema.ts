import { pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";
import { project } from "./projects.schema";

export const projectToken = pgTable("project_token", {
  id: uuid("id").defaultRandom().primaryKey(),
  projectId: uuid("project_id")
    .notNull()
    .unique()
    .references(() => project.id, { onDelete: "cascade" }),
  tokenHash: text("token_hash").notNull().unique(),
  tokenPrefix: text("token_prefix").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true })
    .defaultNow()
    .$onUpdate(() => new Date())
    .notNull(),
});

export type ProjectToken = typeof projectToken.$inferSelect;
export type NewProjectToken = typeof projectToken.$inferInsert;
