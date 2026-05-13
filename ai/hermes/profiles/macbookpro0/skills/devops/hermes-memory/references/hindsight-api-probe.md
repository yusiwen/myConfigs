# Hindsight API Probe Reference

From a real diagnostics session (2026-05-13) on MacBook Pro (M4, macOS 26.4.1).

## Full Diagnostics Transcript

```bash
# 1. API health check (no auth needed)
curl --max-time 15 -s "https://api.hindsight.vectorize.io/version"
# → {"api_version":"0.5.6","features":{"observations":true,...}}

# 2. Check config
cat ~/.hermes/profiles/macbookpro0/config.yaml   # search for memory section
# memory.provider: hindsight

# 3. Check env vars
echo "API_KEY=${HINDSIGHT_API_KEY:+SET}"
echo "MODE=${HINDSIGHT_MODE:-not set}"
echo "API_URL=${HINDSIGHT_API_URL:-not set}"

# 4. Check config files
ls -la ~/.hermes/hindsight/config.json    # profile-scoped
ls -la ~/.hindsight/config.json            # legacy

# 5. Find actual API endpoints in the installed client library
grep 'resource_path' $(python3 -c "
import hindsight_client_api.api.memory_api
print(hindsight_client_api.api.memory_api.__file__)
") | grep -v 'list\|clear\|get\|graph\|observation\|delete'

# Output:
# /v1/default/banks/{bank_id}/memories          (clear)
# /v1/default/banks/{bank_id}/memories/{memory_id}
# /v1/default/banks/{bank_id}/memories/{memory_id}/history
# /v1/default/banks/{bank_id}/tags
# /v1/default/banks/{bank_id}/memories/recall    (RECALL)
# /v1/default/banks/{bank_id}/reflect            (REFLECT)
# /v1/default/banks/{bank_id}/memories           (RETAIN)

# 6. Test recall endpoint directly
curl --max-time 30 -s -w "\nHTTP:%{http_code}" \
  -H "Authorization: Bearer $HINDSIGHT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"test","budget":"low","max_tokens":512}' \
  "https://api.hindsight.vectorize.io/v1/default/banks/hermes/memories/recall"

# 7. Test without auth
curl --max-time 15 -s -w "\nHTTP:%{http_code}" \
  -H "Content-Type: application/json" \
  -d '{"query":"test","budget":"low","max_tokens":512}' \
  "https://api.hindsight.vectorize.io/v1/default/banks/hermes/memories/recall"
# → HTTP 401: {"detail":"Authentication failed: API key required"}

# 8. Check installed client version
python3 -c "from importlib.metadata import version; print(version('hindsight-client'))"

# 9. Check stored API key
grep HINDSIGHT_API_KEY ~/.hermes/.env
```

## Key Insight: What Invalid API Key Looks Like

When the API key is invalid, the recall endpoint returns:

```
HTTP 401
{"detail":"Authentication failed: Invalid API key format"}
```

This causes the Python `hindsight_client_api` library to fail with a confusing validation error because it tries to parse the HTML/gateway error as a `RecallResponse` or `ReflectResponse` pydantic model. The error pattern is:

```
Input should be a valid dictionary or instance of RecallResponse [type=model_type, input_value='<!doctype html>\n<html l...
```

**Root cause:** The API key in `~/.hermes/.env` is not a valid Hindsight Cloud key. Fix by getting a new key from https://ui.hindsight.vectorize.io.

## Config Architecture

The Hindsight provider resolves config in this order (from `plugins/memory/hindsight/__init__.py`):
1. `$HERMES_HOME/hindsight/config.json` (profile-scoped)
2. `~/.hindsight/config.json` (legacy fallback)
3. Environment variables

At `initialize()`, these fields are set:
- `self._api_key` ← config `apiKey` / `api_key` / env `HINDSIGHT_API_KEY`
- `self._api_url` ← config `api_url` / env `HINDSIGHT_API_URL` / default
- `self._mode` ← config `mode` / env `HINDSIGHT_MODE` / `"cloud"`
- `self._bank_id` ← template resolution or config `bank_id` / `"hermes"`
