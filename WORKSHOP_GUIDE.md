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
