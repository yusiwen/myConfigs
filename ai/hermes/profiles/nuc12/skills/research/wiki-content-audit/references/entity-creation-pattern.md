# Entity Creation Pattern — Session Reference (2026-05-14)

## What Was Done

Created a gVisor entity page at `entities/tools/container-vm/gvisor.md` following the React entity pattern, with cross-links to the existing concept page at `concepts/container/gvisor.md`.

## Entity Page Template (Concrete Example)

Frontmatter:
```yaml
---
title: gVisor
created: 2026-05-14
updated: 2026-05-14
type: entity
tags: [containers, security, cloud, sandbox, go]
sources:
  - concepts/container/gvisor.md
  - raw/cloud-computing-export/容器/工具/开发/开发.md
---
```

Body structure:
- **Short description** (one sentence)
- **Overview** — type, released, language, license, website, GitHub
- **Architecture** — component table (Sentry/Gofer/Netstack/Platforms)
- **Integrations** — Docker, Kubernetes, containerd
- **Alternatives** — runC, Kata, Firecracker
- **See Also** → concept page via wikilink + related entities

## Index Update

Insert under the correct Entities section heading in `index.md`:
```markdown
- [[entities/tools/container-vm/gvisor|gVisor]] — Google's application kernel for containers: userspace syscall handling, netstack, OCI runtime (runsc).
```

Bump total page count in the index header.

## Log Entry Format

```markdown
## [YYYY-MM-DD] create | gVisor entity page
- **Source:** `concepts/container/gvisor.md` (existing concept page), `raw/cloud-computing-export/容器/工具/开发/开发.md`
- **Created (entity):**
  - `entities/tools/container-vm/gvisor.md` — Entity page with key facts, architecture overview, ecosystem, cross-links
- **Updated:**
  - `index.md` — Added gVisor entry under Containers & VM section, bumped total pages to 542
```

## Existing Entity Categories (as of 2026-05-14)

- `entities/tools/ai-ml-frameworks/` | `container-vm/` | `network-services/` | `network-diagnostics/`
- `entities/tools/security-auth/` | `web-app-frameworks/` | `build-systems/` | `code-editors/`
- `entities/tools/perf-debug/` | `shells-scripting/` | `sysadmin-utils/` | `test-quality/`
- `entities/people/` | `entities/models/`
