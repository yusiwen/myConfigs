---
name: hermes-memory
description: >-
  Diagnose, configure, and manage Hermes Agent memory providers (Hindsight,
  Honcho, Mem0, SuperMemory, etc.). Covers provider setup, connectivity
  checks, API endpoint probing, authentication debugging, and config file
  locations.
trigger: >-
  When the user asks about memory in Hermes Agent — why it isn't working,
  how to configure it, which provider to use, or how to check connectivity.
  Also load when you see memory-related errors from hindsight_retain,
  hindsight_recall, hindsight_reflect, or similar tool failures.
category: devops
---

# Hermes Memory Provider — Diagnostics & Configuration

## Memory Provider Architecture

Hermes Agent supports multiple memory backends via a plugin system:

- **Hindsight** (`cloud` or `local_embedded`/`local_external` modes)
- **Honcho** (Dexter-based memory)
- **Mem0** (mem0-based memory)
- **SuperMemory** (supermemory-based memory)
- Others via plugin discovery

The active provider is set in `config.yaml` under `memory.provider`:

```yaml
memory:
  provider: hindsight        # <-- which plugin to load
  memory_enabled: true
  user_profile_enabled: true
  memory_char_limit: 2200
  user_char_limit: 1375
```

## Hindsight — Full Diagnostics Workflow

### 1. Verify Configuration

Check the active profile's `config.yaml`:

```bash
grep -A 10 "memory:" ~/.hermes/profiles/<profile>/config.yaml
```

Expected: `provider: hindsight` under the `memory:` section.

### 2. Check Config File Resolution Order

Hindsight config is loaded from (first match wins):

| Path | Description |
|------|-------------|
| `$HERMES_HOME/hindsight/config.json` | Profile-scoped config (preferred) |
| `~/.hindsight/config.json` | Legacy shared config |
| Environment variables | Fallback |

Relevant env vars (from `plugins/memory/hindsight/__init__.py`):

| Variable | Default | Purpose |
|----------|---------|---------|
| `HINDSIGHT_API_KEY` | (none) | API key for cloud mode |
| `HINDSIGHT_API_URL` | `https://api.hindsight.vectorize.io` | API endpoint |
| `HINDSIGHT_MODE` | `cloud` | `cloud`, `local_embedded`, or `local_external` |
| `HINDSIGHT_BANK_ID` | `hermes` | Memory bank name |
| `HINDSIGHT_BUDGET` | `mid` | `low`, `mid`, or `high` |
| `HINDSIGHT_TIMEOUT` | `120` | Request timeout in seconds |
| `HINDSIGHT_RETAIN_TAGS` | (none) | Default tags for retains |

### 3. Test API Health

The base API endpoint should respond on `/version`:

```bash
curl --max-time 15 -s "https://api.hindsight.vectorize.io/version"
```

Expected response (cloud):

```json
{"api_version":"0.5.6","features":{...}}
```

### 4. Find Actual API Endpoints

The OpenAPI-generated client (`hindsight_client_api`) uses these paths:

| Operation | Method | Path |
|-----------|--------|------|
| Recall | `POST` | `/v1/default/banks/{bank_id}/memories/recall` |
| Reflect | `POST` | `/v1/default/banks/{bank_id}/reflect` |
| Retain (batch) | `POST` | `/v1/default/banks/{bank_id}/memories` |

These are in `memory_api.py` under `hindsight_client_api/api/`. Find them with:

```bash
grep 'resource_path' $(python3 -c "import hindsight_client_api.api.memory_api; print(hindsight_client_api.api.memory_api.__file__)")
```

### 5. Test API Key Directly

```bash
curl --max-time 30 -s -w "\nHTTP:%{http_code}" \
  -H "Authorization: Bearer $HINDSIGHT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"test","budget":"low","max_tokens":512}' \
  "https://api.hindsight.vectorize.io/v1/default/banks/hermes/memories/recall"
```

Expected success: HTTP 200 with JSON results.
Common failures:
- **401** `"Invalid API key format"` → Key format wrong or corrupted
- **401** `"API key required"` → No key sent at all
- **404** → Wrong URL path or bank doesn't exist

### 6. Locate the API Key

The API key is stored in `~/.hermes/.env` (profile-level `.env`):

```bash
grep HINDSIGHT_API_KEY ~/.hermes/.env
```

To update:

```bash
export HINDSIGHT_API_KEY="new-key-here"
sed -i '' 's/^HINDSIGHT_API_KEY=.*/HINDSIGHT_API_KEY=new-key-here/' ~/.hermes/.env
```

Get a new key at: https://ui.hindsight.vectorize.io

### 7. Check Client Library Version

```bash
python3 -c "from importlib.metadata import version; print(version('hindsight-client'))"
```

Minimum required: `0.4.22`. Auto-upgrade runs on `initialize()` but can be forced:

```bash
uv pip install --python $(which python3) --upgrade "hindsight-client>=0.4.22"
```

## Other Memory Providers

### Honcho
- Configuration via `HONCHO_*` env vars
- Uses Dexter API as backend

### Mem0
- Uses `mem0ai` Python package
- Config via `MEM0_*` env vars or `$HERMES_HOME/mem0/config.json`

### SuperMemory
- Uses local SQLite backed by embedding model
- No cloud dependency

## Pitfalls

- **Memory is per-session.** A new session starts with empty memory until retain fires for the first time. If tools return "No relevant memories found" on a fresh session, check whether previous sessions stored data.
- **HINDSIGHT_API_KEY must be in profile-scoped `.env`**, not in the global shell environment. The plugin reads from `~/.hermes/.env` (per profile).
- **The `/version` endpoint doesn't require auth.** It can return 200 even when the API key is invalid — don't confuse server reachability with authentication validity.
- **HTML response from tools = proxy/gateway error.** If `hindsight_recall` etc. return HTML parsing errors, the Python client is hitting a URL that returns an HTML error page. Test the actual endpoint with curl to see the real HTTP error.
- **Bad API key triggers confusing OpenAPI validation error.** The `hindsight_client_api` library tries to deserialize the 401 HTML error body as a `RecallResponse`/`ReflectResponse`, producing a cryptic Pydantic model validation error. Always test with raw curl to see the actual HTTP status.
