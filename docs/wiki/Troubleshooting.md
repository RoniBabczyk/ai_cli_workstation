# Troubleshooting

Start with:

```powershell
aiws check
```

It shows what is installed and configured and what each pipeline role would use.

## Errors

| Message | Cause | Fix |
|---|---|---|
| `no API key for provider 'X': run aiws key set ...` | no shell variable and no stored key | `aiws key set X` (use the provider name), or set the variable |
| `no Hermes key for provider 'hermes_runs'` | no `HERMES_API_KEY` and no `API_SERVER_KEY` found in Hermes' `.env` | add `API_SERVER_KEY` to Hermes' `.env` and restart its gateway, or `aiws key set hermes` |
| `'...api_key_env' must be the NAME of an environment variable` | a key was typed where a variable name goes | put the variable name there (for example `HERMES_API_KEY`) and save the key with `aiws key set`. **If that was a real key, rotate it** |
| `(invalid name, hidden)` in a message | the same mistake in an older config | reset it: `aiws config set providers.<name>.api_key_env HERMES_API_KEY` |
| `could not start 'claude': is Claude Code installed and on PATH?` | Claude Code missing, or PATH differs in this terminal | install it (see [Providers](Providers)); open a new terminal; or set `providers.claude_code.command` to the full path |
| `nothing is set up to answer this: no executor is ready` | pipeline is on but no executor provider works | `aiws check`; enable a provider |
| `daily budget reached` / `monthly budget reached` | spend cap hit | raise `budget.daily_usd` / `budget.monthly_usd` or wait |
| `refusing to listen on ... without authentication` | daemon bound off-loopback with no token | `aiws key set AIWS_TOKEN`, then start again |
| `Access is denied. (os error 5)` while building | `aiws.exe` is running and Windows won't overwrite it | close the TUI/daemon, or stop the process, then rebuild |
| `provider 'X' is disabled` | not enabled | `aiws config set providers.X.enabled true` |

## Hermes

| Symptom | Fix |
|---|---|
| `hermes gateway` says "already serves profile 'default'" but nothing answers on port 8642 | the API server is off or Hermes started before `.env` was edited. Check `API_SERVER_ENABLED=true` and `API_SERVER_KEY` are in Hermes' `.env`, then `hermes -p default gateway restart` |
| `aiws check` says "not found on PATH" for `hermes` | PATH differs between terminals; run `aiws check` from the terminal where `hermes` works, or set `providers.hermes_cli.command` |
| Approval popup never appears | the run isn't asking, or you are using `hermes` (chat endpoint) rather than `hermes_runs` |
| Token counts show 0 / "(tokens estimated)" | the stream gave no usage; counts are then a rough estimate (characters / 4) |

## Jev

| Symptom | Fix |
|---|---|
| Decider shows "built-in heuristic (Jev off: ...)" | read the reason: not enabled, no `base_url`, or no key |
| Note `Jev unavailable (...); heuristic used` | endpoint unreachable, HTTP error or unusable answer. Compare with [Jev Setup](Jev-Setup) |

## TUI

| Symptom | Fix |
|---|---|
| Boxes or symbols look broken | Settings tab: Symbols = `ascii` |
| Can't select text with the mouse | Settings tab: Mouse wheel = off, or hold Shift while selecting |
| Long answer cut off | scroll: arrows, PgUp/PgDn, Home/End, wheel |
| Colors hard to read | Settings tab: try the `contrast` or `mono` preset |

## Data and reset

- Everything is in the aiws folder (`aiws check` prints it). Delete `aiws.db` to clear the log; delete `ui.toml` to reset the look; `aiws init --force` rewrites the config with defaults.
- Use a throwaway `AIWS_HOME` to experiment without touching your real data.
