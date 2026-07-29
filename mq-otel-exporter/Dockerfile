# syntax=docker/dockerfile:1
# Builds ibm-messaging/mq-metric-samples mq_otel exporter (pinned clone).
ARG EXPORTER=mq_otel
ARG RUNTIME_IMAGE=registry.access.redhat.com/ubi8-minimal:latest
ARG BASE_IMAGE=registry.access.redhat.com/ubi8/go-toolset:1.21
ARG METRIC_SAMPLES_REF=master

FROM ${BASE_IMAGE} AS builder

ARG EXPORTER
ARG METRIC_SAMPLES_REF
ENV EXPORTER=${EXPORTER} \
    ORG="github.com/ibm-messaging" \
    REPO="mq-metric-samples" \
    VRMF=10.0.0.0 \
    CGO_CFLAGS="-I/opt/mqm/inc/" \
    CGO_LDFLAGS_ALLOW="-Wl,-rpath.*" \
    genmqpkg_incnls=1 \
    genmqpkg_incsdk=1 \
    genmqpkg_inctls=1

ENV GOVERSION=1.22.8
USER 0

ARG GOPROXY=https://proxy.golang.org,direct
RUN go env -w GOPROXY="$GOPROXY"
ENV GOTOOLCHAIN="go${GOVERSION}+auto"
ENV GO=go

RUN mkdir -p /go/src /go/bin /go/pkg \
    && chmod -R 777 /go \
    && mkdir -p /go/src/${ORG} \
    && mkdir -p /opt/mqm \
    && mkdir -p /MQINST \
    && chmod a+rx /opt/mqm

RUN git clone --depth 1 --branch "${METRIC_SAMPLES_REF}" \
    "https://github.com/ibm-messaging/mq-metric-samples.git" \
    "/go/src/${ORG}/${REPO}"

ARG TARGETARCH TARGETOS
ARG RDURL_ARG="https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqdev/redist"
RUN T="$TARGETOS/$TARGETARCH"; \
      if [ "$T" = "linux/amd64" ]; \
      then \
        MQARCH=X64; \
        RDURL=${RDURL_ARG}; \
        RDTAR="IBM-MQC-Redist-Linux${MQARCH}.tar.gz"; \
        cd /opt/mqm \
        && curl -fsSL "$RDURL/$VRMF-$RDTAR" -o mqclient.tar.gz \
        && tar -zxf mqclient.tar.gz \
        && rm -f mqclient.tar.gz \
        && bin/genmqpkg.sh -b /opt/mqm; \
      elif [ "$T" = "linux/arm64" ]; \
      then \
        echo "ARM64: mount MQ client tar in MQINST or use amd64 Docker"; exit 1; \
      else \
        echo "Unsupported platform $T"; exit 1; \
      fi

WORKDIR /go/src/${ORG}/${REPO}
RUN cp "cmd/${EXPORTER}"/*.go . \
    && buildStamp=`date +%Y%m%d-%H%M%S`; \
    hw=`uname -m`; os=`uname -s`; bp="$os/$hw"; \
    gitCommit=`git rev-parse --short HEAD 2>/dev/null || echo Unknown`; \
    BUILD_EXTRA_INJECT="-X \"main.BuildStamp=$buildStamp\" -X \"main.BuildPlatform=$bp\" -X \"main.GitCommit=$gitCommit\""; \
    $GO build -mod=vendor -ldflags "$BUILD_EXTRA_INJECT" -o "/go/bin/${EXPORTER}" ./*.go

FROM ${RUNTIME_IMAGE} AS runtime

ARG EXPORTER

RUN mkdir -p /opt/bin /opt/mqm /opt/config \
    && chmod -R 777 /opt/bin \
    && chmod 775 /opt/mqm \
    && chmod a+rx /opt/config

WORKDIR /opt/mqm
RUN mkdir -p /IBM/MQ/data/errors /.mqm \
    && chmod -R 777 /IBM /.mqm

ENV EXPORTER=${EXPORTER} \
    LD_LIBRARY_PATH="/opt/mqm/lib64:/usr/lib64" \
    MQ_CONNECT_TYPE=CLIENT \
    IBMMQ_GLOBAL_CONFIGURATIONFILE=/opt/config/${EXPORTER}.yaml

COPY --chmod=555 --from=builder /go/bin/${EXPORTER} /opt/bin/${EXPORTER}
COPY --from=builder /opt/mqm/ /opt/mqm/
COPY mq_otel.yaml /opt/config/mq_otel.yaml

CMD ["sh", "-c", "/opt/bin/${EXPORTER}"]
