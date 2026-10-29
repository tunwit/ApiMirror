import { sql } from "drizzle-orm";
import { check, integer, jsonb, pgEnum, pgTable, text, timestamp, uniqueIndex, uuid } from "drizzle-orm/pg-core";
import { project } from "./projects.schema";

export const httpMethod = pgEnum("http_method", [
  "GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS",
]);

export type JsonValue = string | number | boolean | null | JsonValue[] | { [key: string]: JsonValue };

export const mockRoute = pgTable(
  "mock_route",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    projectId: uuid("project_id")
      .notNull()
      .references(() => project.id, { onDelete: "cascade" }),
    path: text("path").notNull(),
    method: httpMethod("method").notNull(),
    statusCode: integer("status_code").default(200).notNull(),
    responseBody: jsonb("response_body").$type<JsonValue>().default(sql`'{}'::jsonb`).notNull(),
    requiredBody: jsonb("required_body").$type<string[]>().default(sql`'[]'::jsonb`).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true })
      .defaultNow()
      .$onUpdate(() => new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("mock_route_project_method_path_idx").on(table.projectId, table.method, table.path),
    check("mock_route_status_code_check", sql`${table.statusCode} BETWEEN 200 AND 599`),
    check("mock_route_path_check", sql`${table.path} LIKE '/%' AND ${table.path} !~ '[?#]'`),
    check("mock_route_required_body_check", sql`jsonb_typeof(${table.requiredBody}) = 'array'`),
  ],
);

export type MockRoute = typeof mockRoute.$inferSelect;
export type NewMockRoute = typeof mockRoute.$inferInsert;
