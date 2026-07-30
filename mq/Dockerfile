FROM icr.io/ibm-messaging/mq:latest

USER root
COPY mqtracingexit.conf /etc/mqm/mqtracingexit.conf
COPY 10-dev.mqsc /etc/mqm/
COPY 20-lab-connect.mqsc /etc/mqm/
COPY install-tracing-config.sh /usr/local/bin/install-tracing-config.sh
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/install-tracing-config.sh /usr/local/bin/docker-entrypoint.sh \
  && grep -q '^app:' /etc/passwd || echo 'app:x:1002:0:app user:/home/app:/sbin/nologin' >> /etc/passwd \
  && mkdir -p /home/app && chown 1002:0 /home/app

USER 1001
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
