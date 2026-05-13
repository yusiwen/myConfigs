# Ingestion Audit Methodology

> Record of audit patterns and known gaps, to accelerate future audits.

## Audit Sequence

For each raw export, the audit follows this sequence:

1. `find` all `.md` files excluding `file/` and `image/` directories
2. `find` all existing `concepts/` and `entities/` pages
3. Build a mapping by extracting English slug keywords from Chinese raw paths
4. Check each raw file against the known mapping
5. Verify edge cases with `test -f` where keywords are ambiguous
6. Categorize into: ingested, missing, or index-only

## Known Ingestion Rates by Export

| Export | Raw files | Ingested | Missing | Rate | Est. new pages |
|--------|-----------|----------|---------|------|----------------|
| `operating-system-export` | 318 | ~40 | ~278 | ~13% | ~200+ |
| `network-export` | 265 | 236 | 21 | 89% | ~8 high-priority |
| `programming-languages-export` | 405 | ~380 | ~10 | ~95% | ~5 low-priority |
| `cloud-computing-export` | ~800 | ~90% | ~10% | ~90% | ~20 CNI/tool entities |
| `artificial-intelligence-export` | 226 | ~210 | ~5 | ~95%+ | ~2 low-priority |
| `web-export` | 35 | 35 | 0 | **100%** | 0 |
| `compilers-linkers-export` | ~30 | 30 | 0 | **100%** | 0 |
| `algorithms-data-structures-export` | ~50 | ~50 | ~1 | **95%** | 0 |
| `miscellaneous-export` | ~70 | ~65 | ~5 | **80%** | 0 (niche items) |
| `thoughts-export` | ~150 | ~135 | ~15 | **85%** | ~15 (low-priority) |
| `big-data-data-science-export` | ~50 | ~39 | ~11 | **85%** | ~11 (entity pages) |
| `database-export` | ~150 | ~90 | ~60 | **60%** | ~11 entity pages |
| `distributed-systems-export` | ~200 | ~80 | ~120 | **40%** | ~50 entity pages |
| `tools-export` | 195 | 4 | 191 | **~2%** | **~140** (biggest gap) |

**Takeaway:** Three tiers of ingestion completeness:
- **Tier 1 (100-95%)** — web, compilers-linkers, algorithms, AI/ML, programming-languages, network — all batch-ingested on 2026-05-10/11
- **Tier 2 (90-60%)** — cloud-computing, miscellaneous, thoughts, big-data — mostly ingested, missing entity pages
- **Tier 3 (<50%)** — database, distributed-systems, operating-system — heavily incomplete
- **Tier 4 (~2%)** — **tools-export** — almost entirely not ingested (only vim, git, cmake, makefile exist from other sources)

## Common Mapping Patterns

### Chinese → English slug mapping

| Chinese keyword | English slug |
|----------------|-------------|
| 系统用户界面---编程界面 | system-programming-interface |
| 嵌入式开发 | embedded-development |
| 发行版 | distribution |
| 虚拟化 | virtualization |
| 资源管理 | resource-management |
| 安全 | security |
| 工具/cli | cli-tools |
| 性能 | performance |
| 网卡 | nic |
| 设备 | device |
| 运营商网络 | carrier-network |
| 开发-&-实施 | development-and-implementation |
| 关注 | interests |
| 项目 | projects |
| 工具 | tools |
| 云原生-(cloud-native) | cloud-native |
| 边缘计算 | edge-computing |
| 容器 | container |
| 架构 | architecture |
| 原理 | principles |
| 协议 | protocol |
| 信号 | signals |
| 库 | libraries |
| 框架 | frameworks |
| 并发 | concurrency |
| 注解 | annotations |
| 字节码 | bytecode |
| 垃圾回收 | garbage-collection |
| 监控-&-性能调优 | monitoring-and-performance-tuning |
| 网络相关 | network-tools |
| 文件系统相关 | filesystem-tools |
| 数据处理相关 | data-processing-tools |
| 性能-observability | performance-observability |

### Language mapping (programming-languages-export)

| Raw directory | Wiki domain |
|---------------|-------------|
| `golang/` | `concepts/programming/go/`, `entities/tools/` |
| `c-c++/` | `concepts/programming/c-cpp-*` |
| `java/` | `concepts/programming/java-*` (4 comprehensive pages) |
| `python/` | `concepts/programming/python/` |
| `javascript/` | `concepts/programming/javascript/` |
| `rust/` | `concepts/programming/rust/` |
| `data-serialization-language/` | `concepts/programming/data-serialization.md` |
| `principles-of-programming-lang/` | `concepts/programming/programming-concurrency.md` |
| `others/` (Makefile, Solidity, Zig, Android NDK, HarmonyOS) | `entities/tools/{makefile,solidity,zig,android-ndk,harmonyos}.md` |

### Cloud computing mapping (cloud-computing-export)

| Raw directory | Wiki domain |
|---------------|-------------|
| `iaas/` (Ceph, GlusterFS, NFS, OpenStack, Neutron) | `concepts/cloud/iaas.md`, `entities/tools/{ceph,glusterfs,nfs,openstack,neutron}.md` |
| `paas/kubernetes/` | `concepts/cloud/kubernetes-*.md` (12 pages) |
| `paas/{microk8s,openshift,others}/` | `entities/tools/{microk8s,openshift}.md` |
| `容器/` (Docker, containerd, Podman, etc.) | `concepts/container/container-*.md` (8 pages) |
| `架构/{envoy,istio,erda,service-mesh}/` | `entities/tools/{envoy,istio,erda}.md`, `concepts/architecture/service-mesh.md` |
| `工具/{ansible,terraform,traefik,rancher}/` | `entities/tools/{ansible,terraform,traefik,rancher}.md` |
| `云原生-(cloud-native)/` | `concepts/cloud/cloud-native.md`, `concepts/cloud/cloud-design-patterns.md` |
| `边缘计算/` | `concepts/cloud/edge-computing.md`, `entities/tools/kubeedge.md` |

## Methodology Refinements

### 1. Handing duplicate nesting

Some exports (especially `programming-languages-export` and `cloud-computing-export`) have deeply nested duplicate files from wolai.app's subpage folder convention:

```
golang/fundamentals/concurrency/concurrency.md          ← main page
golang/fundamentals/concurrency/concurrency/goroutine/goroutine.md  ← subpage in identically-named folder  
golang/fundamentals/concurrency/concurrency/goroutine/goroutine/goroutine.md  ← double-nested duplicate
```

**Strategy:** Count deduplicated "unique topics" (unique filename stems per directory), not raw file count. Report both numbers.

### 2. Handling "'condensed" ingestion

Some exports had many raw files that were summarized into a few comprehensive wiki pages rather than mirrored page-for-page:

| Export | Raw topics | Wiki pages | Ratio |
|--------|-----------|------------|-------|
| Java (programming-languages) | 67 unique topics | 4 pages (java-core, java-concurrency, java-frameworks, java-jvm) | 17:1 |
| Network tools | ~60 CLI tools | ~25 entity pages | 2:1 |
| Kubernetes | ~100 sub-topics | 12 pages | 8:1 |

**Strategy:** For condensed ingestion, note it separately in the report as "ingested (condensed)" rather than "missing". The sub-topics are covered within the parent page.

### 3. Index/overview pages

Top-level `index.md`-like pages in raw exports (e.g., `工具/工具.md`, `协议/protocols.md`, `设备/设备.md`) are usually just listing pages with no content worth extracting. Mark them as "INDEX — no dedicated page needed" rather than "missing".

### 4. Report structure

After 14 audits, the optimal report structure is:

1. **Summary table** — at the top: raw files, unique topics, ingested, missing, rate
2. **✅ Already Ingested** — organized by category with table mapping raw topic → existing wiki page
3. **📋 Index/Overview Pages** — pages counted as "not missing" but not needing new pages
4. **❌ Truly Missing** — each item: `#`, raw path, suggested wiki page, priority (High/Medium/Low), rationale
5. **Priority Matrix** — quick overview of effort by priority tier

### 5. Report storage convention

Save all audit reports to `raw/tasks/ingest/missing-page_<export-name>.md`. This is the wiki-side convention for pre-ingest audit plans.

### 6. Priority guidance

- **High**: Core protocol missing (UDP), major concept absent (datacenter networking, SD-WAN), entity for widely-used tool (Helm, kubectl, Calico, Cilium, Harbor)
- **Medium**: Useful sub-concept or enhancement to existing page (Segment Routing, IP troubleshooting, Open vSwitch)
- **Low**: Single-article merge, niche tool entities, troubleshooting notes, trivia items

### Duplicate nesting patterns in raw exports

Some raw exports have deeply nested duplicate files (wolai.app export pattern):
- `protocols/tcp/缺陷/缺陷/缺陷.md` — same content as `protocols/tcp/缺陷/缺陷.md` (wolai creates subpages in identically-named folders)
- `protocols/vpn/wireguard/wireguard/wireguard.md` — same pattern
- These duplicates can be safely ignored in audit counts

## Pitfalls

- **Do not count deeply nested duplicates** as separate missing items — they're wolai.app folder-level duplicates
- **Do not modify raw files** — they are source-of-truth imports
- **Do not run the audit as a script** — the mapping requires human judgment for creative translations
- **A "missing" item with priority Low may be intentionally skipped** — if the content is trivial (single FAQ page, troubleshooting note)
- **"Report-only" mode: when the user says "DO NOT TOUCH the wiki yet" or "give a list"**, only produce the report. Do NOT create any pages, update any files, or run any git commands. The audit is a plan, not execution.
- **Single-export vs batched**: When the user says "proceed one folder by one", do each export as a separate file. When they say "do the same task on the rest", batch them into sequential operations.
- **tools-export is a special case**: Unlike other exports which are 90%+ ingested, the `tools-export` is only ~2% ingested. This is because it was never batch-processed on 2026-05-10 like the others. Its report should note this explicitly.
- **Entity-only vs concept-only gaps**: Some exports (database, distributed-systems) have all concept pages ingested but missing entity pages. Others (tools-export) are missing everything. Distinguish this in the report.
- **Audit reports are planning documents, not execution**: The `raw/tasks/ingest/` directory stores audit plans. Do not confuse creating a report with executing the ingestion. The user decides which gaps to prioritize.

## Master Summary of All 14 Exports

| Export | % Ingested | Missing pages | Key gaps |
|--------|-----------|---------------|----------|
| web | 100% | 0 | — |
| compilers-linkers | 100% | 0 | — |
| algorithms-data-structures | 95% | ~1 | LeetCode index |
| artificial-intelligence | 95% | ~2 | LLM thoughts, troubleshooting |
| programming-languages | 95% | ~10 | Java trivia, CGLIB, Apache Commons |
| network | 94% | ~21 | UDP, SRv6, DC networking, OVS, SD-WAN |
| cloud-computing | 90% | ~20 | CNI plugins, K8s tools, Harbor |
| big-data-data-science | 85% | ~11 | HDFS, YARN, Doris, Greenplum, Presto, DuckDB, Iceberg |
| thoughts | 85% | ~15 | System design sub-topics, crypto sub-topics |
| miscellaneous | 80% | ~5 | Niche hardware/interest items |
| database | 60% | ~11 | Oracle, ClickHouse, Couchbase, etc. |
| operating-system | ~50% | ~200 | Kernel deep-dive, CLI tools, distros, virtualization, security |
| distributed-systems | ~40% | ~50 | nginx, Prometheus, SSO/OAuth, RocketMQ, Minio, Nacos, Consul |
| tools | ~2% | ~140 | Maven, IDEA, VSCode, testing frameworks, profilers, editors |
