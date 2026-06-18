#!/usr/bin/env bash
# Register the Postgres → Kafka CDC connector with Debezium.
# Idempotent: deletes the connector if it already exists before re-creating.
#
# Run from the host:
#     ./scripts/register_debezium.sh
# or from inside the network:
#     docker compose exec debezium ./register.sh

set -euo pipefail

CONNECT_URL="${CONNECT_URL:-http://localhost:8083}"
CONNECTOR_NAME="${CONNECTOR_NAME:-lakehouseit-postgres}"

echo "→ registering Debezium connector at ${CONNECT_URL}"

# Drop any existing connector with the same name so this script is idempotent.
curl -s -o /dev/null -w "delete existing: HTTP %{http_code}\n" \
    -X DELETE "${CONNECT_URL}/connectors/${CONNECTOR_NAME}" || true

cat <<JSON | curl -s -X POST -H "Content-Type: application/json" --data @- "${CONNECT_URL}/connectors" | jq .
{
  "name": "${CONNECTOR_NAME}",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "tasks.max": "1",
    "database.hostname": "postgres",
    "database.port": "5432",
    "database.user": "postgres",
    "database.password": "lakehouseit",
    "database.dbname": "appdb",
    "topic.prefix": "lakehouseit",
    "table.include.list": "public.users,public.orgs,public.subscriptions,public.events",
    "plugin.name": "pgoutput",
    "publication.autocreate.mode": "filtered",
    "snapshot.mode": "initial",
    "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema-history.lakehouseit",
    "time.precision.mode": "connect",
    "decimal.handling.mode": "double"
  }
}
JSON

echo "→ done. Connector status:"
curl -s "${CONNECT_URL}/connectors/${CONNECTOR_NAME}/status" | jq .
