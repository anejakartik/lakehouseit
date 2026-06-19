# lakehouseit — orchestrate the full demo pipeline.
#
# Usage:
#     make up          # start core services
#     make seed        # populate Postgres with synthetic data
#     make snapshot    # snapshot Postgres → warehouse/bronze/*.parquet
#     make build       # run dbt — builds silver + gold tables
#     make query       # run sample analytics queries
#     make demo        # end-to-end: up → seed → snapshot → build → query
#     make down        # tear everything down

.DEFAULT_GOAL := demo
SHELL := /bin/bash

.PHONY: up down seed snapshot build query demo streaming-up logs

up:
	docker compose up -d postgres dbt
	@echo "→ waiting for postgres health…"
	@until [ "$$(docker compose ps --format '{{.Name}} {{.Health}}' postgres | awk '{print $$2}')" = "healthy" ]; do sleep 1; done
	@echo "✓ postgres ready"

seed: up
	docker compose --profile seed up --build --abort-on-container-exit seeder

snapshot: seed
	docker compose --profile snapshot up --build --abort-on-container-exit snapshotter

build: snapshot
	docker compose exec dbt dbt deps   || true
	docker compose exec dbt dbt run

query: build
	docker compose exec dbt duckdb /warehouse/lakehouseit.duckdb < /usr/app/queries.sql || true
	@echo ""
	@echo "Or from the host: ./scripts/query.sh"

streaming-up:
	docker compose --profile streaming up -d --build kafka debezium iceberg-rest consumer
	@echo "→ waiting 15s for Debezium + consumer to settle…"
	@sleep 15
	CONNECT_URL=http://localhost:8083 ./scripts/register_debezium.sh
	@echo ""
	@echo "✓ streaming track up."
	@echo "  Tail the consumer:    docker compose logs -f consumer"
	@echo "  Re-run dbt to ingest: make build"

demo: query
	@echo ""
	@echo "✓ pipeline complete."
	@echo "  Inspect:   docker compose exec dbt duckdb /warehouse/lakehouseit.duckdb"
	@echo "  Streaming: make streaming-up"

logs:
	docker compose logs -f --tail=50

down:
	docker compose --profile all down -v
