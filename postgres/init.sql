-- Initial schema for the synthetic SaaS source database.
-- Real seed data generation lands with the full pipeline this week (~100K rows).

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    email TEXT NOT NULL,
    signup_at TIMESTAMP NOT NULL,
    plan TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS orgs (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    org_id UUID NOT NULL,
    event_name TEXT NOT NULL,
    occurred_at TIMESTAMP NOT NULL,
    props JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY,
    org_id UUID NOT NULL,
    plan TEXT NOT NULL,
    started_at TIMESTAMP NOT NULL,
    ended_at TIMESTAMP,
    mrr_usd NUMERIC NOT NULL
);

CREATE INDEX IF NOT EXISTS events_user_idx ON events(user_id);
CREATE INDEX IF NOT EXISTS events_occurred_at_idx ON events(occurred_at);
