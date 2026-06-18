FROM python:3.11-slim

WORKDIR /app

COPY scripts/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY scripts /app/scripts

# The container is built to be invoked once and exit (one-shot task pattern).
ENTRYPOINT ["python"]
CMD ["scripts/seed_postgres.py"]
