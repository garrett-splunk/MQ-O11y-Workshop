#!/bin/sh
# Re-apply lab MQSC after QM1 is ready; start mq_otel in bindings mode for Splunk metrics.
set -eu

apply_lab_mqsc() {
  attempt=0
  while [ "$attempt" -lt 90 ]; do
    if chkmqready 2>/dev/null; then
      for mqsc in /etc/mqm/20-lab-connect.mqsc /etc/mqm/10-dev.mqsc; do
        if [ -f "$mqsc" ]; then
          echo "Applying ${mqsc}..."
          runmqsc "${MQ_QMGR_NAME:-QM1}" < "$mqsc" || true
        fi
      done
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 2
  done
  echo "Lab MQSC: queue manager not ready within timeout" >&2
  return 1
}

  (
  if apply_lab_mqsc && [ -x /opt/bin/mq_otel ]; then
    # Let the command server finish starting after chkmqready.
    sleep 15
    export IBMMQ_GLOBAL_CONFIGURATIONFILE=/opt/config/mq_otel.yaml
    export LD_LIBRARY_PATH="/opt/mqm/lib64:/usr/lib64"
    echo "Starting mq_otel metrics exporter (bindings)..."
    while true; do
      /opt/bin/mq_otel || echo "mq_otel exited ($?); restarting in 15s..." >&2
      sleep 15
    done
  fi
) &

exec runmqdevserver
