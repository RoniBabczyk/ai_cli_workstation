# Daemon and API

`aiws serve` runs the same engine as the CLI behind an HTTP API, so other machines, containers and scripts share one setup, one log and one set of budgets.

```powershell
aiws key set AIWS_TOKEN            # a long random secret (required off-loopback)
aiws serve                         # 127.0.0.1:7878
aiws serve --bind 0.0.0.0:7878     # all interfaces; refuses to start without a token
```

The daemon reloads `config.toml` automatically when it changes, and picks up keys saved with `aiws key set` on the next request.

## Endpoints

All except `/health` need `Authorization: Bearer <token>` when a token is configured.

| Method | Path | Purpose |
|---|---|---|
| GET | `/health` | liveness, no auth |
| GET | `/metrics` | Prometheus text: requests, errors, tokens, spend, latency |
| GET | `/v1/snapshot` | dashboard data as JSON |
| GET | `/v1/requests/{id}` | one logged request, full text |
| POST | `/v1/chat` | send a request (JSON, or an event stream) |
| POST | `/v1/approvals/{id}` | answer an agent approval |
| GET / PUT | `/v1/config` | read or replace the config (validated) |

## Chat

```powershell
curl -s http://127.0.0.1:7878/v1/chat `
  -H "Authorization: Bearer $env:AIWS_TOKEN" -H "Content-Type: application/json" `
  -d '{"messages":[{"role":"user","content":"hello"}],"provider":"anthropic"}'
```

Request fields: `messages` (required, `role` + `content`), `system`, `provider`, `model`, `max_tokens`, `stream`. Without `provider`, the pipeline or router (if on) or the default provider is used. The response includes the text, provider, model, tokens, `cost_usd` (null if unknown), `billing`, latency and the routing reason.

### Streaming

Add `"stream": true` for Server-Sent Events. Each `data:` line is one JSON object with a `type`:

| type | fields | meaning |
|---|---|---|
| `text` | `text` | part of the answer |
| `tool` | `name`, `state`, `detail` | agent tool step (`started`, `completed`, `error`) |
| `status` | `text` | progress line (decision, plan, which provider is running) |
| `approval` | `id`, `summary` | the agent wants permission |
| `done` | `response` | final result (same shape as the non-streaming reply) |
| `error` | `message` | final failure |

```text
data: {"type":"status","text":"Hermes run run_1 started"}
data: {"type":"tool","name":"terminal","state":"started","detail":"ls -la"}
data: {"type":"text","text":"I found 3 files. "}
data: {"type":"approval","id":"run_1:p1","summary":"rm -rf build"}
data: {"type":"done","response":{...}}
```

Answer an approval while the stream is open:

```powershell
curl -s -X POST http://127.0.0.1:7878/v1/approvals/run_1:p1 `
  -H "Authorization: Bearer $env:AIWS_TOKEN" -H "Content-Type: application/json" `
  -d '{"choice":"once"}'
```

`choice` is `once` or `deny`; anything else means deny. Without a streaming client nobody can answer, so approvals are denied. **Closing the connection cancels the request** (and stops a Hermes run).

## Using a remote daemon from the CLI and TUI

```powershell
$env:AIWS_REMOTE = "http://server:7878"
aiws key set AIWS_TOKEN              # or: $env:AIWS_TOKEN = "..."
aiws chat "hello"
aiws stats
aiws tui
aiws config set budget.daily_usd 5   # changes the server's config
```

Keys are stored on the machine that runs `aiws`; to change a server's keys run `aiws key set` on that server.

## Docker

```powershell
$env:AIWS_TOKEN = "<long random secret>"
docker compose up -d
```

`docker-compose.yml` publishes `127.0.0.1:7878`, keeps data in the `aiws-data` volume (`AIWS_HOME=/data`), and passes `AIWS_TOKEN`, `ANTHROPIC_API_KEY` and `OPENAI_API_KEY` through from your environment.

The container does not include Claude Code or Hermes, so use API-key providers or point Hermes' `base_url` at a Hermes server reachable from the container. The Dockerfile has not been built in CI yet; treat it as a starting point.

## Reaching it over SSH

Safest: do not expose the port. Tunnel it.

```powershell
ssh -L 7878:127.0.0.1:7878 user@server
aiws --remote http://127.0.0.1:7878 tui
```
