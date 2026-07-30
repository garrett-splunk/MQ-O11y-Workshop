# syntax=docker/dockerfile:1
# MQ workshop image: IBM MQ dev server + mq_otel exporter (bindings) for Splunk metrics.
ARG MQOTEL_EXPORTER_IMAGE=ibm-mq-o11y-lab-mq-otel-exporter:latest

FROM ${MQOTEL_EXPORTER_IMAGE} AS mqotel

FROM icr.io/ibm-messaging/mq:latest

USER root
COPY mq/mqtracingexit.conf /etc/mqm/mqtracingexit.conf
COPY mq/10-dev.mqsc /etc/mqm/
COPY mq/20-lab-connect.mqsc /etc/mqm/
COPY mq/install-tracing-config.sh /usr/local/bin/install-tracing-config.sh
COPY mq/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --from=mqotel /opt/bin/mq_otel /opt/bin/mq_otel
COPY mq-otel-exporter/mq_otel.yaml /opt/config/mq_otel.yaml
RUN chmod 755 /usr/local/bin/install-tracing-config.sh /usr/local/bin/docker-entrypoint.sh /opt/bin/mq_otel \
  && grep -q '^app:' /etc/passwd || echo 'app:x:1002:0:app user:/home/app:/sbin/nologin' >> /etc/passwd \
  && mkdir -p /home/app && chown 1002:0 /home/app \
  && chmod 755 /opt/config/mq_otel.yaml

USER 1001
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
