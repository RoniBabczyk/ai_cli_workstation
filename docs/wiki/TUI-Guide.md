# TUI Guide

```powershell
aiws tui                    # local
aiws tui --tab chat         # start on a tab: dashboard, requests, chat, config, settings, help
aiws --remote http://host:7878 tui     # another machine's aiws (token from $AIWS_TOKEN or the key store)
```

Tabs: **1 Dashboard · 2 Requests · 3 Chat · 4 Config · 5 Settings · 6 Help**. The footer always shows the keys that apply right now.

## Global keys

| Key | Action |
|---|---|
| `1`-`6`, `F1`-`F6` | jump to a tab (F-keys also work while typing) |
| `Tab` / `Shift+Tab` | next / previous tab |
| `r` | refresh data and reload config |
| `?` | Help tab |
| `q` | quit (not while typing) |
| `Ctrl+C` | quit from anywhere |

## Dashboard

- Today, this month and all-time totals: requests, errors, tokens, **API spend**, subscription value (notional), average latency.
- Budget bars (daily, monthly) turn yellow at 70% and red at 90%.
- Usage per model for the last 30 days, and a requests-per-hour chart.
- **Pipeline roles** box: which provider fills Decider, Planner and Executor right now. Yellow means a fallback is in use.

## Requests

Every logged call, newest first. The right side shows the selected request in full: provider, model, tokens, cost, latency, routing reason, error, the prompt and the response.

| Key | Action |
|---|---|
| `↑` `↓` / `j` `k` | select (your selection stays put as new requests arrive) |
| `g` / `G` | first / last |
| `PgUp` `PgDn`, mouse wheel | scroll the detail pane |
| `/` | filter by text (provider, model, status, prompt, response, error) |
| `Esc` | clear the filter |

## Chat

Type and press Enter. History is sent with each message. Answers stream in live; tool steps from agents appear in grey above the text.

| Key | Action |
|---|---|
| `Enter` | send |
| `Esc` or `Ctrl+X` | cancel the running request |
| `↑` `↓`, `PgUp` `PgDn`, mouse wheel | scroll |
| `Home` / `End` | oldest / latest |
| `Ctrl+P` | cycle provider: pipeline/router/default, then each enabled provider |
| `Ctrl+L` | clear the conversation |

A scrollbar appears when the text is longer than the screen. A new non-streamed answer opens at its first line so long text is read from the start. The title shows the active provider and, when scrolled up, how many lines are below you.

### Approval popup

When a Hermes agent asks permission, a box shows what it wants to do. **`y`** / Enter allows once, **`n`** / Esc denies.

## Config

Every setting in a table, with a description of the selected one underneath.

| Key | Action |
|---|---|
| `↑` `↓` | select |
| `Enter`, `e`, `Space` | edit; booleans toggle at once |
| `s` | on an `api_key_env` / `token_env` row: enter the key itself (stored privately) |
| `x` | remove the stored key for that row |
| `r` | reload |

Changes are checked before saving (a bad value shows a message and nothing is written) and take effect on the next request. With a remote daemon, settings change on that daemon.

`api_key_env` rows show whether a key is available: `key set in your shell`, `key saved in aiws`, or `no key: select + press s`.

## Settings (look and feel)

Saved per machine in `ui.toml`; they never change a remote server.

| Option | Choices |
|---|---|
| Theme preset | default, ocean, forest, sunset, mono, contrast |
| Accent / Your messages / AI messages | 14 named colors, or press `e` and type `#rrggbb` |
| Border style | plain, rounded, double, thick |
| Symbols | unicode or ascii (use ascii if your font draws `▶ ● █` badly) |
| Refresh every | 500 ms to 5 s |
| Key hints | show or hide the footer |
| Mouse wheel | on or off (turn off to select text with the mouse) |

Keys: `↑↓` select, `Enter`/`→` next value, `←` previous, `d` reset all. A live preview shows your colors.

**Fonts** are set by your terminal, not by `aiws` (Windows Terminal: Settings, Profiles, Appearance, Font face).
