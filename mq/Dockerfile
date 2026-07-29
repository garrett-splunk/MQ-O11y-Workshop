FROM icr.io/ibm-messaging/mq:latest

USER root
COPY mqtracingexit.conf /etc/mqm/mqtracingexit.conf
COPY 10-dev.mqsc /etc/mqm/
COPY install-tracing-config.sh /usr/local/bin/install-tracing-config.sh
RUN chmod 755 /usr/local/bin/install-tracing-config.sh

USER 1001
