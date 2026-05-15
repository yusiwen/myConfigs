# Comparison Audit Result — 2026-05-13

Audited all 14 raw export directories (~3,600+ markdown files) for comparison content.

## Baseline

**Existing wiki pages in `comparisons/`:** 3 pages across 2 sub-categories

| Sub-category | Page | Topic |
|---|---|---|
| `comparisons/ai-ml/` | `parallelism-strategies` | TP, DP, PP, SP, EP |
| `comparisons/ai-ml/` | `nvidia-agx-thor-vs-dgx-spark` | NVIDIA AGX Thor vs DGX Spark |
| `comparisons/networking/` | `iot-protocols-zigbee-vs-thread-vs-matter-vs-z-wave` | ZigBee vs Z-Wave vs Thread vs Matter |

## Raw Comparison Content Found

### Full Dedicated Comparison Documents

| # | Raw path (relative to wiki/raw/) | Topic | Export source |
|---|---|---|---|
| 1 | `artificial-intelligence-export/nlp/word-embedding/sparse-and-dense-embedding-mod/sparse-and-dense-embedding-models.md` | Sparse vs Dense Embeddings | artificial-intelligence-export |
| 2 | `network-export/protocols/wireless-networks/802.11/comparison-of-802.11-and-802.3/comparison-of-802.11-and-802.3.md` | 802.11 vs 802.3 (WiFi vs Ethernet) | network-export |
| 3 | `distributed-systems-export/缓存/redis/问题/一致性哈希和哈希槽对比/一致性哈希和哈希槽对比.md` | Consistent Hashing vs Hash Slot | distributed-systems-export |
| 4 | `thoughts-export/security/cryptography-(密码学)/pki/x.509/x509-server---client-certifica/x509-server---client-certificates-comparison.md` | X509 Server vs Client Certificates | thoughts-export |
| 5 | `operating-system-export/工具/cli/包管理/nix/single-user-vs-mutli-user/single-user-vs-mutli-user.md` | Nix Single-user vs Multi-user | operating-system-export |
| 6 | `programming-languages-export/java/frameworks/spring/spring-boot/问题/difference-between-putting-a-p/difference-between-putting-a-property-on-applicati.md` | application.yml vs bootstrap.yml | programming-languages-export |

### Comparison Sections Within Documents

Each entry lists the parent file and the comparison heading found within.

| # | Raw path | Comparison heading | Topic |
|---|---|---|---|
| 7 | `artificial-intelligence-export/.../agentic-ai/memory/memory.md` | ## RAG vs Memory | AI/ML |
| 8 | `artificial-intelligence-export/.../models/models.md` | ## Instruct vs Chat | AI/ML |
| 9 | `artificial-intelligence-export/.../the-decoder-only-architecture/` | § Encoder-Decoder vs Decoder-Only | AI/ML |
| 10 | `network-export/protocols/nfs/nfs.md` | ## NFS vs SMB | Networking |
| 11 | `network-export/network-virtualization/nfv/nfv.md` | ## NFV vs 传统物理网络设备 | Networking |
| 12 | `network-export/sdn/open-vswitch/open-vswitch.md` | ## Kernel vs Userspace OVS | Networking |
| 13 | `network-export/工具/route/route.md` | ## iptables vs route | Networking |
| 14 | `distributed-systems-export/网络/反向代理/caddy/caddy.md` | ## Caddy vs Nginx | Distributed Systems |
| 15 | `distributed-systems-export/api/api网关/kong/kong.md` | ## Kong vs Traefik | Distributed Systems |
| 16 | `distributed-systems-export/编排/编排.md` | ## Orchestration vs Choreography | Distributed Systems |
| 17 | `cloud-computing-export/架构/service-mesh/service-mesh.md` | ## Service Mesh vs API Gateway | Cloud |
| 18 | `cloud-computing-export/.../statefulsets/statefulsets.md` | ## StatefulSets vs Deployment | Kubernetes |
| 19 | `cloud-computing-export/.../replicaset/replicaset.md` | ## ReplicaSet vs Deployment vs StatefulSet | Kubernetes |
| 20 | `big-data-data-science-export/hadoop/hadoop.md` | ## HBase vs Hive | Big Data |
| 21 | `database-export/mysql/mysql.md` | ## 5.7 vs 8.0 | Databases |
| 22 | `database-export/mysql/performance/performance.md` | ## count(*) vs count(1) | Databases |
| 23 | `programming-languages-export/.../微服务---web-frameworks.md` | ## Micronaut vs Quarkus vs Spring Boot Reactive | Java Frameworks |
| 24 | `programming-languages-export/.../spring-cloud-alibaba-sentinel.md` | ## Sentinel vs Hystrix | Java Frameworks |
| 25 | `programming-languages-export/.../retrofit/retrofit.md` | ## Retrofit vs OpenFeign | Java Frameworks |
| 26 | `programming-languages-export/.../lombok/lombok.md` | ## @Data vs @Value | Java |
| 27 | `programming-languages-export/.../类加载器-(classloader).md` | ## Classloader vs Class.forName() | JVM |
| 28 | `tools-export/git/commands/merge-&-rebase/merge-&-rebase.md` | ## Rebase vs Merge | Git |
| 29 | `tools-export/git/commands/git-clone/git-clone.md` | ## --bare vs --mirror | Git |

## Search Pattern Used

The multi-pass approach that produced this inventory:

```
Pass 1: find + grep -iE '(vs|对比|compar|versus|区别|差异|diff)' on filenames
Pass 2: rg -n '^#+ .+ (vs|VS|versus|对比|比较|区别|差异) .+' on heading content
Pass 3: Verify each candidate by reading first 6 lines
Pass 4: Categorize by domain + type (full doc vs section)
```
