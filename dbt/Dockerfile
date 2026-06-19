FROM python:3.11-slim

WORKDIR /usr/app

RUN pip install --no-cache-dir \
        dbt-duckdb==1.8.1 \
        duckdb==1.1.1

# Project files are mounted at /usr/app via docker-compose.

CMD ["tail", "-f", "/dev/null"]
