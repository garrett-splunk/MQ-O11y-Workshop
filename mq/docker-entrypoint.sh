#!/bin/sh
# Re-apply lab MQSC after QM1 is ready (fixes reused volumes missing DEV.APP.SVRCONN).
set -eu

(
  attempt=0
  while [ "$attempt" -lt 90 ]; do
    if chkmqready 2>/dev/null; then
      for mqsc in /etc/mqm/20-lab-connect.mqsc /etc/mqm/10-dev.mqsc; do
        if [ -f "$mqsc" ]; then
          echo "Applying ${mqsc}..."
          runmqsc "${MQ_QMGR_NAME:-QM1}" < "$mqsc" || true
        fi
      done
      exit 0
    fi
    attempt=$((attempt + 1))
    sleep 2
  done
  echo "Lab MQSC: queue manager not ready within timeout" >&2
) &

exec runmqdevserver
