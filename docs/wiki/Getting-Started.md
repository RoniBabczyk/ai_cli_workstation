# Getting Started

## 1. Requirements

| Needed | Why | Check |
|---|---|---|
| Rust (stable) | to build `aiws` | `cargo --version` |
| A C/C++ build toolchain | the bundled SQLite and TLS libraries compile native code. On Windows: Visual Studio Build Tools with "Desktop development with C++" | `cargo build` succeeds |
| At least one model provider | otherwise there is nothing to talk to | `aiws check` (after building) |

Install Rust on Windows:

```powershell
winget install Rustlang.Rustup
rustup default stable
```

## 2. Build

```powershell
git clone https://github.com/<owner>/<repo>.git
cd <repo>
cargo build --release
```

The program is `target\release\aiws.exe` (`target/release/aiws` on Linux/macOS). Put it on your `PATH`, or run it with `cargo run --release --` in front of the commands below.

> While `aiws.exe` is running (for example the TUI is open), Windows will not let you rebuild it: *"Access is denied (os error 5)"*. Close it, then build again.

## 3. First run

```powershell
aiws init        # writes config.toml
aiws check       # what is installed / configured, and what to install
aiws tui         # the terminal UI
```

`aiws check` lists each tool as `[ok]` or `[--]` and prints the install step for anything missing. It never installs anything. The program works with whatever is ready.

## 4. Your first request

With Claude Code installed and signed in (the default provider is `claude_code`, which uses your Claude subscription):

```powershell
aiws chat "explain what a mutex is in two sentences"
```

Output ends with a footer: provider, model, tokens, cost, time, and why it was routed there.

Read the prompt from a pipe:

```powershell
Get-Content notes.txt | aiws chat "summarize this"
```

Pick a provider or model for one request:

```powershell
aiws chat -p anthropic -m claude-sonnet-5-5 "hello"
```

## 5. Where files live

| File | Location | Purpose |
|---|---|---|
| `config.toml` | `%LOCALAPPDATA%\aiws` (Windows), `~/.local/share/aiws` (Linux) | settings, no secrets |
| `aiws.db` | same folder | request log (SQLite) |
| `secrets.env` | same folder | keys saved with `aiws key set` |
| `ui.toml` | same folder | your colors and TUI preferences |

Set `AIWS_HOME` to use a different folder (Docker uses `/data`).

## 6. Next steps

- Add more providers: [Providers](Providers)
- Save an API key: [Keys and Security](Keys-and-Security)
- Combine models: [Pipeline](Pipeline)
- Learn the UI: [TUI Guide](TUI-Guide)

## Command overview

| Command | Purpose |
|---|---|
| `aiws init` | create a default config |
| `aiws chat [-p provider] [-m model] [-s system] "prompt"` | send a prompt (streams the answer) |
| `aiws stats [--json]` | usage and spend summary |
| `aiws log -n 20` | recent requests |
| `aiws config show / get / set / price / path` | view and change settings |
| `aiws key set / rm / list` | manage API keys |
| `aiws check` (alias `doctor`) | installation and setup report |
| `aiws hermes` | Hermes setup steps and connection check |
| `aiws serve [--bind addr]` | run the daemon and HTTP API |
| `aiws tui [--tab name]` | terminal UI |

Global options: `--config <file>`, `--remote <url>`, `--token-env <VAR>`.
