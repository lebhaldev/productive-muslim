CREATE TABLE "habits" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" TEXT NOT NULL, "archived" INTEGER NOT NULL DEFAULT 0 CHECK ("archived" IN (0, 1)), "sort_order" INTEGER NOT NULL DEFAULT 0, "reminder_time" TEXT NULL, "created_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)));
CREATE TABLE "habit_completions" ("habit_id" INTEGER NOT NULL REFERENCES habits (id) ON DELETE CASCADE, "day_key" TEXT NOT NULL, PRIMARY KEY ("habit_id", "day_key"));
CREATE TABLE "activities" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "title" TEXT NOT NULL, "note" TEXT NULL, "start_time" TEXT NOT NULL, "duration_minutes" INTEGER NOT NULL, "day_key" TEXT NOT NULL);
CREATE TABLE "moods" ("day_key" TEXT NOT NULL, "value" INTEGER NOT NULL, "note" TEXT NULL, "updated_at" INTEGER NOT NULL, PRIMARY KEY ("day_key"));
CREATE TABLE "journals" ("day_key" TEXT NOT NULL, "title" TEXT NOT NULL DEFAULT '', "body" TEXT NOT NULL, "created_at" INTEGER NOT NULL, "updated_at" INTEGER NOT NULL, PRIMARY KEY ("day_key"));
CREATE TABLE "content_cache" ("day_key" TEXT NOT NULL, "kind" TEXT NOT NULL, "payload" TEXT NOT NULL, "fetched_at" INTEGER NOT NULL, PRIMARY KEY ("day_key", "kind"));
CREATE TABLE "weather_cache" ("id" INTEGER NOT NULL, "location_label" TEXT NOT NULL, "payload" TEXT NOT NULL, "fetched_at" INTEGER NOT NULL, PRIMARY KEY ("id"));
CREATE TABLE "settings" ("key" TEXT NOT NULL, "value" TEXT NOT NULL, PRIMARY KEY ("key"));
