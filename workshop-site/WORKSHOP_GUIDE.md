# IBM MQ → Splunk O11y — Facilitator Guide

**Participant site:** https://garrett-splunk.github.io/MQ-O11y-Workshop/ (GitHub Pages) or http://localhost:8091 (with local stack)

**Lab root:** `~/projects/ibm-mq-o11y-lab`

---

## Timing (~60–75 min)

| Block | Duration | Section |
|-------|----------|---------|
| Intro + concepts | 10 min | Overview, Concepts 101 |
| Start + topology | 15 min | Steps 1–3 |
| Message flow + logs | 15 min | Steps 4–5 |
| MQ metrics + tracing | 20 min | Steps 6–7 |
| Failure demo + Q&A | 10 min | Step 8, teardown |

---

## Pre-workshop checklist

- [ ] Docker Desktop running (8 GB RAM recommended for IBM MQ + builds)
- [ ] Splunk O11y **ingest** token in `.env.splunk`
- [ ] `cp secrets/mqAppPassword.example.txt secrets/mqAppPassword.txt`
- [ ] `docker compose up --build -d` verified with `bash scripts/verify-stack.sh`
- [ ] Splunk UI: APM environment filter **`ibm-mq-lab`** ready

---

## Facilitator demo script

1. **Start stack** — Step 2; show MQ console at https://localhost:9443/ibmmq/console
2. **Business flow** — POST `/orders`; tail consumer logs
3. **Metrics** — Splunk Metrics: search `ibmmq` / queue depth for `ORDER.REQ`
4. **Traces** — APM service map: `order-producer` → `order-consumer`; mention MQ native spans when tracing exit active
5. **Failure** — `docker compose stop order-consumer`; `npm run load-traffic`; show depth + 503s; restart consumer

---

## Cheat sheet

```bash
cd ~/projects/ibm-mq-o11y-lab
docker compose up --build -d
bash scripts/verify-stack.sh
npm run load-traffic -- 30 400
docker compose stop order-consumer && npm run load-traffic -- 20 200
docker compose start order-consumer
docker compose down -v
```

---

## Key talking points

- **Three telemetry paths:** app OTLP (traces/logs), `mq_otel` (infrastructure metrics), MQ tracing exit (PUT/GET spans).
- **Environment tag:** `deployment.environment:ibm-mq-lab` on all signals.
- **MQ license:** `LICENSE=accept` is for IBM MQ developer/education use only.
