CREATE TYPE "public"."http_method" AS ENUM('GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS');--> statement-breakpoint
CREATE TABLE "project" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"owner_id" text NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "mock_route" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"project_id" uuid NOT NULL,
	"path" text NOT NULL,
	"method" "http_method" NOT NULL,
	"status_code" integer DEFAULT 200 NOT NULL,
	"response_body" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"required_body" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "mock_route_status_code_check" CHECK ("mock_route"."status_code" BETWEEN 100 AND 599),
	CONSTRAINT "mock_route_path_check" CHECK ("mock_route"."path" LIKE '/%' AND "mock_route"."path" !~ '[?#]'),
	CONSTRAINT "mock_route_required_body_check" CHECK (jsonb_typeof("mock_route"."required_body") = 'array')
);
--> statement-breakpoint
CREATE TABLE "project_token" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"project_id" uuid NOT NULL,
	"token_hash" text NOT NULL,
	"token_prefix" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "project_token_project_id_unique" UNIQUE("project_id"),
	CONSTRAINT "project_token_token_hash_unique" UNIQUE("token_hash")
);
--> statement-breakpoint
ALTER TABLE "project" ADD CONSTRAINT "project_owner_id_user_id_fk" FOREIGN KEY ("owner_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "mock_route" ADD CONSTRAINT "mock_route_project_id_project_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."project"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "project_token" ADD CONSTRAINT "project_token_project_id_project_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."project"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "project_owner_id_idx" ON "project" USING btree ("owner_id");--> statement-breakpoint
CREATE UNIQUE INDEX "mock_route_project_method_path_idx" ON "mock_route" USING btree ("project_id","method","path");