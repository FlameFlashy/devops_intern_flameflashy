#!/usr/bin/env bash

workers_cnt=$(( $(nproc) * 2 + 1 ))

alembic upgrade head

gunicorn --bind 0.0.0.0:8000 -w "$workers_cnt" -k uvicorn.workers.UvicornWorker presentation.main:create_app