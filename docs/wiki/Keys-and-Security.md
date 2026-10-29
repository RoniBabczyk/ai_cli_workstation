# Keys and Security

## The rule

`api_key_env` in the config holds the **name** of a variable (for example `HERMES_API_KEY`), never the key itself. If you type a key into that setting by mistake, `aiws` refuses it, and hides invalid names in messages so a pasted secret is not echoed.

## Where a key comes from

`aiws` looks for a key in this order:

1. **Your shell environment**: a variable with that name.
2. **aiws' private key file**: `secrets.env` in the aiws folder.
3. **Hermes only**: `API_SERVER_KEY` from Hermes' own `.env`, but only when Hermes runs on this machine (a loopback address such as `127.0.0.1`). The key is never sent to a remote host.

## Saving a key

### From the terminal

```powershell
aiws key set hermes
aiws key set anthropic
aiws key set JEV_API_KEY
```

You can pass a provider name or the variable name. The prompt hides what you type. For scripts: `echo $KEY | aiws key set anthropic --stdin`.

```powershell
aiws key list        # where each key comes from; never the values
aiws key rm hermes   # delete a stored key
```

### From the TUI

1. Open the **Config** tab (`4`).
2. Select a row ending in `api_key_env` (or `token_env`).
3. Press **`s`**, type or paste the key (shown as `****`), press Enter.
4. The row shows `key saved in aiws`. Press `x` on it to remove the stored key.

The key is used immediately; no shell setup or restart is needed, and a running daemon picks it up on the next request.

## What the key file is

`secrets.env` is a **plain-text** file restricted to your user account (permissions `0600` on Linux/macOS; on Windows `icacls` removes inherited access and grants only you). It is not encrypted. It is never written to `config.toml`, the request log, error messages or the screen. If your machine is shared or backed up to an untrusted place, use environment variables from a secrets manager instead.

## Never commit secrets

The repository's `.gitignore` excludes `secrets.env`, `.env*`, `config.toml`, `ui.toml`, databases and key files. Do not remove those lines. If a real key was ever pasted somewhere it should not be (a config file, a chat, a commit), treat it as exposed and **rotate it**.

## Request log content

By default the prompt and the answer text are stored in `aiws.db` so you can inspect them in the TUI. To keep metrics only:

```powershell
aiws config set storage.store_content false
```

## Daemon security

- `aiws serve` listens on `127.0.0.1:7878` by default.
- It **refuses to listen on any other address without a token**. Set one (`aiws key set AIWS_TOKEN`) before using `--bind 0.0.0.0:7878`.
- Clients send `Authorization: Bearer <token>`. `/health` is the only open endpoint.
- Traffic is plain HTTP. Put it behind a VPN, an SSH tunnel (`ssh -L 7878:127.0.0.1:7878 user@host`) or a TLS proxy; do not expose it to the internet.

## Agent approvals

When a Hermes agent run asks permission for an action, the answer is **allow once** or **deny**. If nobody can answer (a plain API call, a pipe), the answer is **deny**. There is no "always allow".
