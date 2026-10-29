# Providers

A **provider** is one way of reaching a model. Each has a name, a `kind`, and settings under `[providers.<name>]` in `config.toml`. Providers that are not set up are simply skipped by the pipeline.

| Name (default) | Kind | Billing | Streams? | Needs |
|---|---|---|---|---|
| `claude_code` | `claude-cli` | your Claude subscription (shown as a notional cost, never counted against budgets) | no, answer arrives whole | Claude Code installed and signed in |
| `anthropic` | `anthropic` | pay per token | yes | an Anthropic API key |
| `openai` | `openai` | pay per token | yes | an API key and `default_model` |
| `ollama` | `openai` | local, free | yes | Ollama running on `localhost:11434` |
| `hermes` | `hermes-api` | whatever Hermes uses | yes, with tool progress | Hermes API server + key |
| `hermes_runs` | `hermes-runs` | same | yes, with tool progress and approvals | same |
| `hermes_cli` | `hermes-cli` | same | no | `hermes` on PATH |

Only `claude_code` is enabled by default.

## Enable and choose

```powershell
aiws config set providers.anthropic.enabled true
aiws config set default_provider anthropic
```

Or in the TUI: **Config** tab, select the row, press Enter (booleans toggle).

## Claude Code (subscription)

`aiws` runs `claude -p` for you, so usage counts against your subscription and needs no API key.

1. Install: `irm https://claude.ai/install.ps1 | iex` (Windows) or `npm install -g @anthropic-ai/claude-code`.
2. Run `claude` once and sign in.
3. `aiws check` should show `[ok] Claude Code (CLI)`.

A subscription does **not** include API access. For the Anthropic API you need a separate API key.

## Anthropic API

```powershell
aiws key set anthropic            # hidden prompt, see Keys and Security
aiws config set providers.anthropic.enabled true
aiws chat -p anthropic "hello"
```

Set prices so cost is known (otherwise it shows as unknown):

```powershell
aiws config price claude-sonnet-5-5 <usd-per-million-input> <usd-per-million-output>
```

Take the numbers from Anthropic's pricing page. `aiws` ships with no prices because they change.

## OpenAI and compatible APIs

Anything that speaks the Chat Completions format (OpenAI, OpenRouter, Ollama, many gateways):

```powershell
aiws config set providers.openai.default_model <model-name>
aiws key set openai
aiws config set providers.openai.enabled true
```

For Ollama install it, run `ollama serve`, pull a model, then `aiws config set providers.ollama.enabled true`.

You can add your own provider by editing `config.toml`:

```toml
[providers.openrouter]
kind = "openai"
enabled = true
base_url = "https://openrouter.ai/api/v1"
api_key_env = "OPENROUTER_API_KEY"
default_model = "<model>"
```

## Hermes

Three providers, details on [Hermes Setup](Hermes-Setup):

- `hermes`: Hermes' chat endpoint (streams text and shows tool progress).
- `hermes_runs`: agent runs with live tool steps and approval prompts.
- `hermes_cli`: runs `hermes -z "<prompt>"` locally, answer arrives whole.

## Command resolution on Windows

CLI-based providers find their executable the way the shell does (`PATH` plus `.exe`, `.cmd`, `.bat`), so both the native installer and npm installs work. To use a specific copy set `providers.<name>.command` to the full path.
