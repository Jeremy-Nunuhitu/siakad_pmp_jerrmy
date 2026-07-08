BEGIN;

ALTER TABLE mata_kuliah
  ADD COLUMN IF NOT EXISTS kategori text NOT NULL DEFAULT 'reguler',
  ADD COLUMN IF NOT EXISTS bobot_tugas double precision NOT NULL DEFAULT 25,
  ADD COLUMN IF NOT EXISTS bobot_uts double precision NOT NULL DEFAULT 25,
  ADD COLUMN IF NOT EXISTS bobot_uas double precision NOT NULL DEFAULT 35,
  ADD COLUMN IF NOT EXISTS bobot_softskill double precision NOT NULL DEFAULT 15;

ALTER TABLE mata_kuliah
  ALTER COLUMN kategori SET DEFAULT 'reguler',
  ALTER COLUMN kategori SET NOT NULL,
  ALTER COLUMN bobot_tugas SET DEFAULT 25,
  ALTER COLUMN bobot_tugas SET NOT NULL,
  ALTER COLUMN bobot_uts SET DEFAULT 25,
  ALTER COLUMN bobot_uts SET NOT NULL,
  ALTER COLUMN bobot_uas SET DEFAULT 35,
  ALTER COLUMN bobot_uas SET NOT NULL,
  ALTER COLUMN bobot_softskill SET DEFAULT 15,
  ALTER COLUMN bobot_softskill SET NOT NULL;

CREATE TABLE IF NOT EXISTS activity_log (
  id text PRIMARY KEY,
  actor_id text NOT NULL,
  actor_name text NOT NULL,
  role text NOT NULL,
  action text NOT NULL,
  target text NOT NULL,
  description text NOT NULL,
  created_at text NOT NULL,
  data jsonb NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_activity_log_created_at ON activity_log(created_at);
CREATE INDEX IF NOT EXISTS idx_activity_log_actor_id ON activity_log(actor_id);

ALTER TABLE activity_log
  ALTER COLUMN actor_id SET NOT NULL,
  ALTER COLUMN actor_name SET NOT NULL,
  ALTER COLUMN role SET NOT NULL,
  ALTER COLUMN action SET NOT NULL,
  ALTER COLUMN target SET NOT NULL,
  ALTER COLUMN description SET NOT NULL,
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN data SET NOT NULL;

INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
VALUES ('', '20260702154500000', now())
ON CONFLICT ("module")
DO UPDATE SET "version" = '20260702154500000', "timestamp" = now();

COMMIT;
