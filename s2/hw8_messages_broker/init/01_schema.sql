CREATE TABLE marketplace_events (
    id bigserial PRIMARY KEY,
    buyer_id integer NOT NULL,
    shop_id integer NOT NULL,
    item_id integer NOT NULL,
    pvz_id integer NOT NULL,
    order_total numeric(10, 2) NOT NULL,
    event_type text NOT NULL,
    description text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE tasks (
    id bigserial PRIMARY KEY,
    task_type text NOT NULL,
    priority integer NOT NULL DEFAULT 0,
    status text NOT NULL DEFAULT 'Ready',
    payload jsonb NOT NULL,
    attempts integer NOT NULL DEFAULT 0,
    max_attempts integer NOT NULL DEFAULT 5,
    scheduled_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    started_at timestamptz,
    completed_at timestamptz,
    updated_at timestamptz NOT NULL DEFAULT now(),
    locked_by text,
    error_message text,
    CONSTRAINT tasks_priority_check CHECK (priority IN (0, 100)),
    CONSTRAINT tasks_status_check CHECK (status IN ('Ready', 'Running', 'Completed', 'Failed')),
    CONSTRAINT tasks_attempts_check CHECK (attempts >= 0 AND attempts <= max_attempts)
) WITH (
    fillfactor = 80,
    autovacuum_vacuum_scale_factor = 0.01,
    autovacuum_vacuum_threshold = 50,
    autovacuum_analyze_scale_factor = 0.005,
    autovacuum_analyze_threshold = 50
);

CREATE INDEX idx_tasks_ready_pick
    ON tasks (priority DESC, scheduled_at, created_at, id)
    WHERE status = 'Ready';

CREATE INDEX idx_tasks_status_completed_at
    ON tasks (status, completed_at DESC);

CREATE INDEX idx_tasks_started_priority
    ON tasks (priority, started_at)
    WHERE started_at IS NOT NULL;

COMMENT ON TABLE tasks IS 'PostgreSQL-backed priority queue for marketplace order processing.';
COMMENT ON COLUMN tasks.priority IS '100 means critical marketplace order; 0 means normal order task.';
COMMENT ON COLUMN tasks.scheduled_at IS 'Ready task is visible to workers only when scheduled_at <= now().';
