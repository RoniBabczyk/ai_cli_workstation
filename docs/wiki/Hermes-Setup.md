# Hermes Setup

[Hermes Agent](https://hermes-agent.nousresearch.com/docs) (Nous Research) is an open-source agent with tools, memory and skills. `aiws` can use it as a **planner**, as an **agent with live tool progress**, or as a plain chat model.

## 1. Install Hermes

Follow the Installation section of the Hermes docs, then run:

```powershell
hermes setup
```

`aiws check` shows `[ok] Hermes Agent (CLI)` once `hermes` is on your PATH.

## 2. Turn on Hermes' API server

Hermes reads its settings from a `.env` file:

- Windows: `%LOCALAPPDATA%\hermes\.env`
- Linux/macOS: `~/.hermes/.env`

Add these two lines (use a fresh random secret, not a password you reuse). This PowerShell command generates one and appends it without printing it:

```powershell
$b = New-Object byte[] 32; [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b); $k = -join ($b | ForEach-Object { $_.ToString('x2') }); Add-Content "$env:LOCALAPPDATA\hermes\.env" "`nAPI_SERVER_ENABLED=true`nAPI_SERVER_KEY=$k"
```

Optional: `API_SERVER_PORT` (default `8642`) and `API_SERVER_HOST` (default `127.0.0.1`).

## 3. Start (or restart) the gateway

Hermes only reads `.env` when it starts. If it is already running, restart it:

```powershell
hermes -p default gateway restart
```

If it is not running: `hermes gateway`. When it works, `http://127.0.0.1:8642/health` answers.

## 4. Connect aiws

`aiws` finds the key itself when Hermes runs on the same PC (it reads `API_SERVER_KEY` from that `.env`). For a Hermes on another machine, store the key yourself:

```powershell
aiws key set hermes
aiws config set providers.hermes.base_url http://<host>:8642/v1
aiws config set providers.hermes_runs.base_url http://<host>:8642/v1
```

Enable and check:

```powershell
aiws config set providers.hermes.enabled true
aiws config set providers.hermes_runs.enabled true
aiws check
aiws hermes          # setup steps + connection status
```

## Three ways to use it

### `hermes`: chat endpoint

```powershell
aiws chat -p hermes "hello"
```

Streams text; Hermes' tool activity shows as `[started] web_search ...` lines.

### `hermes_runs`: agent runs with approvals

```powershell
aiws chat -p hermes_runs "list the files in this folder"
```

The CLI shows each step as it happens:

```text
  [Hermes run run_1 started]
  [started] terminal ls -la
  [completed] terminal 0.4s 3 files
I found 3 files.
  The agent asks permission:
    rm -rf build
  Allow once? [y/N]
```

- In the **TUI chat** a popup asks; press **y** to allow once or **n** / Esc to deny.
- **Esc** during a run cancels it and tells Hermes to stop.
- With nobody to ask (piped input, plain API calls) the answer is **deny**.
- Only "allow once" and "deny" exist. There is no "always".

### `hermes_cli`: local one-shot

Runs `hermes -z "<prompt>"` and prints the final answer. Whole answer at once; token counts come from Hermes' usage file when it writes one. Prompts over about 28,000 characters are refused (command-line limit); use `hermes` or `hermes_runs` for long input.

## Hermes as the planner

With the [Pipeline](Pipeline) enabled, `hermes_runs`, then `hermes`, then `hermes_cli` are tried in that order for the planning step. The planner is told to produce a plan and not to modify anything, but Hermes is a real agent: if it does call a tool, the approval popup still applies.

## Notes on the Hermes protocol

The `/v1/runs` event names are documented by Hermes (`message.delta`, `tool.started`, `tool.completed`, `approval.request`, `run.completed`, ...) but not every payload. `aiws` reads fields loosely and ignores events it does not know. If a Hermes update changes a payload, look at `HermesRuns` in `src/provider.rs`.
