# Configuration Reference

Settings live in `config.toml` (see [Getting Started](Getting-Started) for where). Change them with the TUI **Config** tab, `aiws config set <key> <value>`, or by editing the file. `aiws config show` prints every setting; `aiws config get <key>` prints one. Invalid values are rejected before anything is saved. Lists are written comma-separated on the command line: `aiws config set pipeline.executor "claude_code, anthropic"`.

Keys never go in this file: `*_env` settings hold only the **name** of a variable. See [Keys and Security](Keys-and-Security).

## Top level

| Setting | Default | Meaning |
|---|---|---|
| `default_provider` | `claude_code` | provider used when a request does not choose one and no router/pipeline applies |

## `[server]`

| Setting | Default | Meaning |
|---|---|---|
| `bind` | `127.0.0.1:7878` | daemon address. Anything not on loopback needs a token |
| `token_env` | `AIWS_TOKEN` | variable name for the API bearer token. Empty = no auth (loopback only) |

## `[storage]`

| Setting | Default | Meaning |
|---|---|---|
| `store_content` | `true` | keep prompt and response text in the log. `false` = metrics only |

## `[budget]`

| Setting | Default | Meaning |
|---|---|---|
| `daily_usd` | `0.0` | stop pay-per-token spend per local day. `0` = unlimited |
| `monthly_usd` | `0.0` | same per calendar month |

Budgets count **API** cost only; subscription usage (Claude Code) is never counted. A request over budget is refused with a clear message, and the refusal is logged.

## `[prices.<model-prefix>]`

Added with `aiws config price <model-prefix> <input> <output>` (USD per million tokens). The longest matching prefix wins. Without a price, API cost shows as unknown (and the dashboard counts unpriced calls).

```toml
[prices."claude-sonnet-5-5"]
input_per_mtok = 0.0    # fill in from the provider's price list
output_per_mtok = 0.0
```

## `[router]`

Picks a provider and model by simple/complex. Superseded by the pipeline when that is on.

| Setting | Default | Meaning |
|---|---|---|
| `enabled` | `false` | route automatically |
| `long_prompt_chars` | `1500` | longer input counts as complex |
| `simple_provider` / `simple_model` | `claude_code` / `haiku` | for simple requests |
| `complex_provider` / `complex_model` | `claude_code` / `sonnet` | for complex requests |

## `[pipeline]`

See [Pipeline](Pipeline).

| Setting | Default | Meaning |
|---|---|---|
| `enabled` | `false` | use decide, plan, execute |
| `planner` | `hermes_runs, hermes, hermes_cli` | providers tried in order for planning |
| `executor` | `claude_code, anthropic` | providers tried in order to answer |
| `fallback_any` | `true` | use any other ready provider if the listed ones are unavailable |
| `simple_model` / `complex_model` | `haiku` / `sonnet` | models for the Claude Code executor |

## `[jev]`

See [Jev Setup](Jev-Setup).

| Setting | Default | Meaning |
|---|---|---|
| `enabled` | `false` | use Jev as the decider |
| `base_url` | empty | Jev endpoint root. Nothing is sent while empty |
| `path` | `/v1/decide` | endpoint path |
| `api_key_env` | `JEV_API_KEY` | variable name for the key |
| `auth` | `bearer` | `bearer` or `x-api-key` |
| `timeout_ms` | `3000` | give up and use the heuristic after this |
| `min_confidence` | `0.6` | ignore less confident answers (0 to 1) |

## `[providers.<name>]`

| Setting | Meaning |
|---|---|
| `kind` | `anthropic`, `openai`, `claude-cli`, `hermes-api`, `hermes-runs` or `hermes-cli` |
| `enabled` | may this provider be used |
| `base_url` | API root (HTTP kinds) |
| `api_key_env` | variable name holding the key |
| `default_model` | used when a request names none. Empty = the provider's own default |
| `command` | executable for `claude-cli` / `hermes-cli` kinds (name or full path) |

Defaults:

| Provider | kind | enabled | base_url | default_model |
|---|---|---|---|---|
| `claude_code` | `claude-cli` | yes | | |
| `anthropic` | `anthropic` | no | `https://api.anthropic.com` | `claude-sonnet-5-5` |
| `openai` | `openai` | no | `https://api.openai.com/v1` | |
| `ollama` | `openai` | no | `http://localhost:11434/v1` | `llama3.2` |
| `hermes` | `hermes-api` | no | `http://127.0.0.1:8642/v1` | `hermes-agent` |
| `hermes_runs` | `hermes-runs` | no | `http://127.0.0.1:8642/v1` | `hermes-agent` |
| `hermes_cli` | `hermes-cli` | no | | |

Older config files that lack newer built-in providers get them added (disabled) when loaded.

## Environment variables

| Variable | Meaning |
|---|---|
| `AIWS_HOME` | folder for config, database, keys and UI settings |
| `AIWS_CONFIG` | path to a specific `config.toml` |
| `AIWS_REMOTE` | URL of a daemon to talk to instead of running locally |
| `AIWS_TOKEN` | default name of the token variable for the daemon and `--remote` |
| `HERMES_HOME` | where to look for Hermes' `.env` |

## UI settings (`ui.toml`)

Colors, borders, symbols, refresh rate, hints and mouse. Edit them in the TUI **Settings** tab; see [TUI Guide](TUI-Guide).
