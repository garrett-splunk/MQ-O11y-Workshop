# IBM MQ → Splunk Observability Cloud Lab

Hands-on workshop stack: IBM MQ queue manager, Node.js producer/consumer apps, **mq_otel** infrastructure metrics, MQ OpenTelemetry tracing exit, and OpenTelemetry export to **Splunk Observability Cloud**.

## Quick start

**Apple Silicon (M1/M2/M3):** IBM MQ and `mq_otel` images run under `platform: linux/amd64` in Compose (Rosetta/QEMU). First start may take several minutes.

```bash
cd ~/projects/ibm-mq-o11y-lab
cp .env.example .env
cp .env.splunk.example .env.splunk   # add Splunk ingest token
cp secrets/mqAppPassword.example.txt secrets/mqAppPassword.txt
docker compose up --build -d
bash scripts/verify-stack.sh
```

Open the guided workshop at **https://garrett-splunk.github.io/MQ-O11y-Workshop/** (GitHub Pages from the `gh-pages` branch) or **http://localhost:8091** with the stack running.

| URL | Purpose |
|-----|---------|
| http://localhost:8091 | Workshop site |
| http://localhost:8080 | Order producer API |
| http://localhost:9443/ibmmq/console | MQ web console (`admin` / password from `.env`) |
| http://localhost:13133 | OTel Collector health |

**APM environment filter:** `ibm-mq-lab`

## Send test orders

```bash
curl -X POST http://localhost:8080/orders \
  -H "Content-Type: application/json" \
  -H "X-Correlation-Id: demo-1" \
  -d '{"productId":"SKU-100","quantity":2}'

npm run load-traffic -- 30 400
```

## Splunk setup

Secrets live only in `.env.splunk` (gitignored). The collector loads them and forwards OTLP traces, metrics, and logs to Splunk O11y. See `.env.splunk.example`.

Set `OTEL_SDK_DISABLED=true` in `.env` to run locally without exporting telemetry.

## Failure demo

```bash
docker compose stop order-consumer
npm run load-traffic -- 25 200
# Observe queue depth metrics and producer 503/errors in Splunk
docker compose start order-consumer
```

## Teardown

```bash
docker compose down -v
```

## License

IBM MQ container requires `LICENSE=accept` (developer/education use). See [IBM MQ container license](https://github.com/ibm-messaging/mq-container).
