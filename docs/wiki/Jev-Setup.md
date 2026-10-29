# Jev Setup

[Jev](https://typesafe.ai) (TypeSafe AI) is a **decision model**, not a chat model. It answers typed questions (a choice, a score, yes/no) quickly and cheaply. In `aiws` it plays the **Decider** role in the [Pipeline](Pipeline): is this request simple or complex, does it need a plan, is it risky?

## Honest status

Jev's API is **not publicly documented**, so the client in `src/jev.rs` is built on an **assumption** taken from the vendor's description (state and typed questions in, choices with confidence out). It has never been run against the real service. Safeguards:

- It is **off by default**.
- **No prompt text is sent anywhere** until `jev.base_url` is set.
- Parsing is lenient (several response shapes are accepted).
- Any failure (timeout, HTTP error, unusable answer, low confidence) falls back to the built-in heuristic and the request still completes.

## What you need from Jev

1. Access to the service (see typesafe.ai; it was described as early access).
2. The **endpoint URL** and **path** for decisions.
3. How the key is sent (`Authorization: Bearer` or an `x-api-key` header).
4. An example request and response, to check them against what `aiws` sends.

## Configure

```powershell
aiws config set jev.base_url https://<host-from-the-docs>
aiws config set jev.path /<path-from-the-docs>      # default /v1/decide
aiws config set jev.auth x-api-key                  # only if the docs say so; default bearer
aiws key set JEV_API_KEY
aiws config set jev.enabled true
aiws check
```

Other settings: `jev.timeout_ms` (default 3000) and `jev.min_confidence` (default 0.6; answers less confident than this are ignored in favour of the heuristic).

## What aiws sends (the assumption)

`POST {base_url}{path}`

```json
{
  "input": "<last user message, up to 6000 chars>",
  "context": { "system": "<system prompt, up to 1000 chars>", "turns": 3 },
  "questions": [
    { "id": "complexity", "type": "choice", "options": ["simple", "complex"] },
    { "id": "needs_plan", "type": "boolean" },
    { "id": "risk", "type": "choice", "options": ["low", "high"] }
  ]
}
```

## What it accepts back

Either an object or an array, with or without an `answers` wrapper:

```json
{ "answers": {
    "complexity": { "choice": "complex", "probabilities": { "simple": 0.1, "complex": 0.9 } },
    "needs_plan": { "value": true, "confidence": 0.8 },
    "risk": "high"
} }
```

```json
{ "results": [ { "id": "complexity", "value": "complex", "confidence": 0.95 } ] }
```

Value keys tried: `choice`, `value`, `answer`, `label`. Confidence keys: `confidence`, `probability`, `score`, or the highest number in `probabilities` / `scores`. A missing confidence counts as 1.0.

## If the real API is different

Only two functions need changing, both in `src/jev.rs`: `ask()` builds the request, `answer()` / `interpret()` read the response. There are unit tests for the parser at the bottom of the file; add the real example response as a test first.

## Without Jev

Nothing breaks. The heuristic decides using prompt length, keywords ("refactor", "implement", "design", ...), code fences, and risk words ("delete", "production", ...). `aiws check` and the TUI Dashboard show which decider is active.
