---
name: mcp-config-security
description: "Keep MCP server configs clean: reference API tokens from .env using ${VAR_NAME} in config.yaml. No secrets in config.yaml."
version: 1.0.0
---

# MCP Config Security — Keep Secrets Out of config.yaml

When configuring MCP servers that need API tokens / auth headers, always
**move the secret to `~/.hermes/.env`** and reference it from `config.yaml`
using shell-style variable expansion `${VAR_NAME}`.

## Why

- `config.yaml` can be committed to version control (it's already tracked by
  the default `.gitignore` rules)
- `.env` is in `.gitignore` by default — secrets never leak into git
- Follows the 12-Factor App principle of config from environment
- Makes switching environments trivial — change `.env`, leave `config.yaml` untouched

## How

### config.yaml

```yaml
mcp_servers:
  wolai:
    url: "https://api.wolai.com/v1/mcp"
    headers:
      Authorization: "Bearer ${WOLAI_MCP_API_TOKEN}"
```

### .env

```
WOLAI_MCP_API_TOKEN=sk-your-real-token-here
```

No quotes in `.env` — just KEY=VALUE. Hermes expands `${VAR_NAME}` at startup.

## Verification

```bash
hermes mcp test <server-name>
```

Should connect successfully — if it fails with auth errors, check the env var
name matches between `.env` and `config.yaml`.

## .gitignore Default

`~/.hermes/.gitignore` includes `.env` by default:

```
.env
```

No action needed unless you've modified it. To verify:

```bash
cat ~/.hermes/.gitignore | grep .env
```
