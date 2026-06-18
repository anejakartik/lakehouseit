"""Seed the source Postgres database with synthetic SaaS data.

Idempotent: TRUNCATEs the four source tables before re-seeding, so running it
twice produces the same content.

Usage:
    python scripts/seed_postgres.py
    # or via docker compose
    docker compose run --rm seeder
"""

from __future__ import annotations

import os
import random
import uuid
from datetime import datetime, timedelta

import psycopg2
import psycopg2.extras


SEED = 20260617
PLANS = ("starter", "growth", "enterprise")
PLAN_MRR = {"starter": 49.0, "growth": 199.0, "enterprise": 999.0}
EVENT_NAMES = (
    "login",
    "dashboard_view",
    "report_run",
    "export_csv",
    "invite_sent",
    "settings_update",
    "billing_view",
)

# Default counts — tune via env for bigger demos.
N_USERS = int(os.environ.get("SEED_USERS", "200"))
N_ORGS = int(os.environ.get("SEED_ORGS", "60"))
EVENTS_PER_USER = int(os.environ.get("SEED_EVENTS_PER_USER", "120"))


def _dsn() -> str:
    return (
        f"host={os.environ.get('POSTGRES_HOST', 'postgres')} "
        f"port={os.environ.get('POSTGRES_PORT', '5432')} "
        f"user={os.environ.get('POSTGRES_USER', 'postgres')} "
        f"password={os.environ.get('POSTGRES_PASSWORD', 'lakehouseit')} "
        f"dbname={os.environ.get('POSTGRES_DB', 'appdb')}"
    )


def _date_between(start: datetime, end: datetime, rnd: random.Random) -> datetime:
    span = int((end - start).total_seconds())
    return start + timedelta(seconds=rnd.randint(0, span))


def main() -> None:
    rnd = random.Random(SEED)
    today = datetime(2026, 6, 17, 12, 0, 0)
    one_year_ago = today - timedelta(days=365)

    user_ids = [str(uuid.UUID(int=rnd.getrandbits(128))) for _ in range(N_USERS)]
    org_ids = [str(uuid.UUID(int=rnd.getrandbits(128))) for _ in range(N_ORGS)]

    users = []
    for uid in user_ids:
        signup = _date_between(one_year_ago, today, rnd)
        users.append(
            (uid, f"user-{uid[:8]}@example.com", signup, rnd.choice(PLANS))
        )

    orgs = []
    for oid in org_ids:
        owner = rnd.choice(user_ids)
        orgs.append((oid, f"Org {oid[:6]}", owner))

    subscriptions = []
    for oid in org_ids:
        first_start = _date_between(one_year_ago, today - timedelta(days=30), rnd)
        first_plan = rnd.choice(PLANS)
        churn = rnd.random() < 0.2
        if churn:
            ended = first_start + timedelta(days=rnd.randint(30, 270))
            ended = min(ended, today)
            subscriptions.append(
                (
                    str(uuid.UUID(int=rnd.getrandbits(128))),
                    oid,
                    first_plan,
                    first_start,
                    ended,
                    PLAN_MRR[first_plan],
                )
            )
            # 25% reactivate on a new plan
            if rnd.random() < 0.25:
                restart = ended + timedelta(days=rnd.randint(7, 60))
                if restart <= today:
                    new_plan = rnd.choice(PLANS)
                    subscriptions.append(
                        (
                            str(uuid.UUID(int=rnd.getrandbits(128))),
                            oid,
                            new_plan,
                            restart,
                            None,
                            PLAN_MRR[new_plan],
                        )
                    )
        else:
            subscriptions.append(
                (
                    str(uuid.UUID(int=rnd.getrandbits(128))),
                    oid,
                    first_plan,
                    first_start,
                    None,
                    PLAN_MRR[first_plan],
                )
            )

    events = []
    for uid in user_ids:
        org = rnd.choice(org_ids)
        # signup is the first row in users for this uid
        signup = next(u[2] for u in users if u[0] == uid)
        n = max(0, int(rnd.gauss(EVENTS_PER_USER, EVENTS_PER_USER * 0.4)))
        for _ in range(n):
            ts = _date_between(signup, today, rnd)
            name = rnd.choice(EVENT_NAMES)
            props = '{"source": "web"}' if rnd.random() < 0.7 else '{"source": "mobile"}'
            events.append(
                (
                    str(uuid.UUID(int=rnd.getrandbits(128))),
                    uid,
                    org,
                    name,
                    ts,
                    props,
                )
            )

    with psycopg2.connect(_dsn()) as conn:
        with conn.cursor() as cur:
            print("→ truncating source tables…")
            cur.execute("TRUNCATE events, subscriptions, orgs, users RESTART IDENTITY")
            print(f"→ inserting {len(users)} users…")
            psycopg2.extras.execute_batch(
                cur,
                "INSERT INTO users (id, email, signup_at, plan) VALUES (%s, %s, %s, %s)",
                users,
                page_size=500,
            )
            print(f"→ inserting {len(orgs)} orgs…")
            psycopg2.extras.execute_batch(
                cur,
                "INSERT INTO orgs (id, name, owner_id) VALUES (%s, %s, %s)",
                orgs,
                page_size=500,
            )
            print(f"→ inserting {len(subscriptions)} subscriptions…")
            psycopg2.extras.execute_batch(
                cur,
                """
                INSERT INTO subscriptions (id, org_id, plan, started_at, ended_at, mrr_usd)
                VALUES (%s, %s, %s, %s, %s, %s)
                """,
                subscriptions,
                page_size=500,
            )
            print(f"→ inserting {len(events)} events…")
            psycopg2.extras.execute_batch(
                cur,
                """
                INSERT INTO events (id, user_id, org_id, event_name, occurred_at, props)
                VALUES (%s, %s, %s, %s, %s, %s::jsonb)
                """,
                events,
                page_size=1000,
            )
        conn.commit()

    print(
        f"✓ seeded: {len(users)} users · {len(orgs)} orgs · "
        f"{len(subscriptions)} subscriptions · {len(events)} events"
    )


if __name__ == "__main__":
    main()
