# IBM MQ → Splunk O11y — Facilitator Guide (metrics track)

**Participant site:** https://garrett-splunk.github.io/MQ-O11y-Workshop/

**Lab root:** `~/projects/ibm-mq-o11y-lab`

This session focuses on **IBM MQ infrastructure metrics** via `mq_otel` → OpenTelemetry Collector → Splunk **Metrics** (not APM/traces/logging in the lab narrative).

---

## Timing (~45–60 min)

| Block | Duration | Section |
|-------|----------|---------|
| Intro + concepts | 10 min | Overview, Concepts |
| Token + secrets + start | 20 min | Steps 1–4 |
| Verify + traffic | 15 min | Steps 5–7 |
| Metrics in Splunk + failure demo | 15 min | Steps 8–9 |
| Wrap-up | 5 min | Teardown |

---

## Pre-workshop checklist

- [ ] Docker Desktop running (8 GB RAM recommended)
- [ ] Participants cloned repo and have ingest token ready
- [ ] `cp .env.splunk.example .env.splunk` + token pasted
- [ ] `cp secrets/mqAppPassword.example.txt secrets/mqAppPassword.txt`
- [ ] Facilitator: `bash scripts/verify-stack.sh` passes

---

## Facilitator demo script

1. Walk through **Step 2** (token in `.env.splunk`) live.
2. **Step 4–5** — `docker compose up --build -d`, then verify script line by line.
3. **Step 7** — `npm run load-traffic -- 30 400`.
4. **Step 8** — Splunk Metrics: filter `metric_name:ibmmq*` or search queue depth for `ORDER.REQ`, environment `ibm-mq-lab`.
5. **Step 9** — stop consumer, load traffic, show depth spike, restart consumer.

---

## Cheat sheet

```bash
cd ~/projects/ibm-mq-o11y-lab
cp .env.example .env
cp .env.splunk.example .env.splunk
cp secrets/mqAppPassword.example.txt secrets/mqAppPassword.txt
docker compose up --build -d
bash scripts/verify-stack.sh
npm run load-traffic -- 30 400
docker compose stop order-consumer && npm run load-traffic -- 25 200
docker compose start order-consumer
docker compose down -v
```
