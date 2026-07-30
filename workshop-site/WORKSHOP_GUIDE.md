# IBM MQ → Splunk O11y — Facilitator Guide (metrics track)

**Participant site:** https://garrett-splunk.github.io/MQ-O11y-Workshop/

**Lab root:** `~/projects/ibm-mq-o11y-lab`

This session focuses on **IBM MQ infrastructure metrics** via `mq_otel` → OpenTelemetry Collector → Splunk **Metrics** (not APM/traces/logging in the lab narrative).

---

## Timing (~45–60 min)

| Block | Duration | Section |
|-------|----------|---------|
| Intro + concepts | 10 min | Overview, Concepts |
| Token + secrets + collector ref | 15 min | Steps 1–4 |
| Start + verify + traffic | 20 min | Steps 5–8 |
| MQ console + metrics + failure demo | 20 min | Steps 7–10 |
| Wrap-up | 5 min | Teardown |

---

## Pre-workshop checklist

- [ ] Docker Desktop running (8 GB RAM recommended)
- [ ] Participants cloned repo
- [ ] **Facilitator:** shared workshop **ingest token** + realm (slide/chat — not committed to git)
- [ ] Participants: `cp .env.splunk.example .env.splunk` and pasted token via **nano** or **vi** (Step 2c on participant site)
- [ ] `cp secrets/mqAppPassword.example.txt secrets/mqAppPassword.txt`
- [ ] Facilitator: `bash scripts/verify-stack.sh` passes

---

## Facilitator: sharing the token

1. Create or reuse an **Ingest** access token in Splunk O11y (Organization Settings → Access Tokens).
2. Display the token once on a slide or paste into the workshop chat; tell learners their realm (e.g. `us1`) and matching ingest URLs if not US1.
3. Ask learners to follow **Step 2** on the participant site: `cp` the template, then edit with terminal only:
   - **nano:** `nano .env.splunk` → replace `SPLUNK_ACCESS_TOKEN=` → Ctrl+O, Enter, Ctrl+X
   - **vi:** `vi .env.splunk` → `i` → edit token → Esc → `:wq`
4. Have them run the Step 2d check commands (must show `OK: token line edited`, not `WARN`).

---

## Facilitator demo script

1. Walk through **Step 2** live — emphasize **workshop token** callout and **nano** path; offer **vi** for experienced users.
2. **Step 4** — skim OTel collector reference (`docker-compose.yml` + `collector/otelcol-config.yaml` metrics pipeline); no manual install.
3. **Step 5–6** — `docker compose up --build -d`, then verify script line by line.
4. **Step 8** — `npm run load-traffic -- 30 400`.
5. **Step 7 (optional live)** — MQ web console: <code>https://localhost:9443/ibmmq/console</code>, admin login, Queues → <code>ORDER.REQ</code> depth, Channels → <code>DEV.APP.SVRCONN</code>.
6. **Step 9** — Splunk UI: **Settings → Metric Metadata**, search `ibmmq`; or **Create → Chart**, signal `ibmmq`, filter `deployment.environment:ibm-mq-lab` and queue `ORDER.REQ`. Mention out-of-box metrics (object status + publications; statistics off). Reference links on participant site **9c** (IBM `metrics.txt`, `mq_otel` README).
7. **Step 10** — stop consumer, load traffic, show depth spike in Splunk and optionally in MQ console, restart consumer.

---

## Metric reference (facilitator)

| Resource | URL |
|----------|-----|
| IBM full metric list | https://github.com/ibm-messaging/mq-metric-samples/blob/master/metrics.txt |
| `mq_otel` naming & OTLP | https://github.com/ibm-messaging/mq-metric-samples/blob/master/cmd/mq_otel/README.md |
| IBM $SYS publication metrics | https://www.ibm.com/docs/en/ibm-mq/latest?topic=trace-metrics-published-system-topics |
| Splunk Metadata Catalog | https://help.splunk.com/en/splunk-observability-cloud/data-tools/metric-finder-and-metadata-catalogue |
| Splunk Chart Builder | https://help.splunk.com/en/splunk-observability-cloud/create-dashboards-and-charts/create-charts/plot-metrics-and-events-using-chart-builder |
| Splunk OTel Collector (production) | https://help.splunk.com/en/splunk-observability-cloud/manage-data/splunk-distribution-of-the-opentelemetry-collector/get-started-with-the-splunk-distribution-of-the-opentelemetry-collector/collector-for-linux/install-the-collector-for-linux-manual |
| Splunk OTel Collector releases | https://github.com/signalfx/splunk-otel-collector/releases |

Default lab exporter flags: `useObjectStatus: true`, `usePublications: true`, `useStatistics: false` (see `mq-otel-exporter/mq_otel.yaml`).

---

## Phase 2 (future session — not in Phase 1 lab)

Use the **Phase 2** section on the participant site as the roadmap. Facilitator talking points:

- **APM** — same stack, traces already exported; show service map for `order-producer` → MQ → `order-consumer`
- **MQ tracing exit** — `scripts/mq-tracing-enable.sh` + `mqtracingexit.conf`
- **Logs** — Log Observer search on JSON logs with correlation ID
- **Statistics metrics** — `ALTER QMGR STATMQI(ON)` + `useStatistics: true`
- **Detectors** — depth threshold on `ORDER.REQ` from Phase 1 metrics

---

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
