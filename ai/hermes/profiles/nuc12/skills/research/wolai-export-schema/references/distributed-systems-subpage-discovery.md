# Distributed Systems Export — Subpage Discovery Worked Example

## Context

The distributed-systems-export has 197 local files and 23 L1 pages in Wolai. 16 of those L1 pages were marked "has subpages" but had no subpage IDs recorded. This reference documents the subpage discovery process and results.

## Method

For each of the 16 L1 pages, called `mcp_wolai_get_page_blocks(page_id)` and filtered the root block's `children.ids` array for blocks where `"type": "page"`.

## Results: Subpages by L1 Page

| L1 Page | Subpage Count | Subpage IDs and Titles |
|---------|:------------:|----------------------|
| API | 5 | `5p7Pv2cdL8GbWcFfqL88c4` (API网关), `3mfaMBHHFJ4t1zYXg3twcp` (API管理), `8epZeEoda4HBiCDDwcpPsj` (GraphQL), `7f7fxz6TX2uN13a34FTARd` (REST API), `kKopcizL55L6k7vs6GDYuB` (RPC) |
| Monitoring & Tracing | 6 | `5RQQ3W1MCgM8sUxPvv7yj5` (APM), `kfvmyT6tgkxyYMJKho8pxa` (链路追踪), `vJXiZ4p5X65thaMbjb4NpY` (Prometheus), `fzX9hG61VwTnofzHZ9PSeh` (美团CAT), `sDEREwrvRDnb1NDUefASga` (cAdvisor), `uGPcg2AqP4qkL5FWonYcGY` (告警) |
| Principles | 3 | `c31HX3ayPH36231jCXZZmj` (System Designs), `erB5iveoYmRgCtUDxzzGuR` (Patterns), `7FGorFBzcjeUPgj1HnkZr6` (一致性算法) |
| 分布式事务 | **0** | No direct page children — all content is bookmarks/headings |
| 分布式任务 | 5 | `uZ385cf9dgjkZgnv7x84jH` (任务框架), `bDxNXX9cej1Er5NYxZu5bo` (XXL-Job), `guyz9A4sigKrWXgaG1bbAf` (ElasticJob), `uqMHuxyuhCaUvdM8nRPujT` (PowerJob), `cjQZkTHKzDh1YX1mqvZdEj` (Slurm) |
| 分布式锁 | **0** | No direct page children — content is headings/bookmarks. Subpages `MultiLock` and `NestedLock` exist deeper under heading blocks |
| 协调器 | 3 | `cYuCnzyutsP3PbxsdgfZVs` (etcd), `uDNPLmnekMH9VDGT5dfhrj` (Zookeeper), `xzs5Eu386kXaTi6peeZyLS` (Hazelcast) |
| 存储 | 9 | `nFi4VxG4qp21ntdrQj2H2d` (MinIO), `9moLZGZxFN8YyEZHjLrL5q` (FastCFS), `vDW18BL1vJz2BV7jXmjZTt` (FastDFS), `9jXMVXBxj1u5ABHQw3SarZ` (JuiceFS), `kKXVn9LkB6HAY8o6zSvQdh` (Apache Ozone), `eD5mAucX1tAg6q6bTkWRMk` (OwnCloud), `eGBgR6UXhswhxfkFc8PLqV` (阿里云OSS), `4Xe6aQu91GYwo7fDD4ghkR` (Amazon S3), `ueVWhEq9sC1Qy4HewxLs1o` (华为OBS) |
| 安全 | 5 | `rGtTAN9bamAzPAhdJtpuPo` (SSO), `wDfjZe7imBGdxpfxoTjWFy` (框架&项目), `bZmkF7F5S5PSAERu2Q4DCB` (WAF), `no6nj4q2RRgnQSdvoY4X2A` (RADIUS), `5BSEf6YohySbhbqRcpZGMt` (CVE) |
| 微服务 | 3 | `dmagLLWTo4BbHsYaHDfLXe` (框架), `9ttSEHK45PWgLeEpiFcooC` (微服务的安全), `tr9uZWThGMqSej7yd49UT4` (微服务治理) |
| 注册中心 | 2 | `dLFZ5ZqebLhePbiQoYZMrZ` (Nacos), `uoFcP5EcPJCUGYdwbzxCRV` (Consul) |
| 消息队列 | 6 | `8ny39o8sZmZgEAWtL8ehJH` (RocketMQ), `uhQRgtiQbVUEjRq8bp3T7P` (RabbitMQ), `2BwEexew1BiFzbxg1drPKu` (QMQ), `27ENqKs5knejuL8AQtU6GR` (NSQ), `sBoXEh6muDbdw2bAMz7g6a` (MQTT), `aDsZaUXrmuunPiAeDpKPdq` (ZeroMQ) |
| 缓存 | 4 | `6jRBA71JNKAGses1mVjNJe` (Redis), `fU4oxjcPGhiCrGCiq3bJgn` (Hazelcast), `3mjWTUsW9NrWhYze8oBjNA` (KeyDB), `8HJJPFyk6NhUUtWVKpibd9` (DrgonflyDB) |
| 编排 | 1 | `pMeFX2PYqfTomtRkcDCqUu` (编排可视化) |
| 网络 | 3 | `g9dhMBevnZiFeiwmM1gPin` (Proxies), `9yJYJwq6S3yFjNtfCewJ2u` (反向代理), `uZ42HytRNZJzvLvUJa9w2b` (框架) |
| 配置中心 | 1 | `wXnYmtacZfXZxRgR4Y2rf3` (Apollo) |

**Totals:** 61 subpages discovered across 14/16 L1 pages (2 had zero direct page children).

## Key Observations

1. **Rate limiting**: Used 2 parallel `get_page_blocks` calls per turn (8 batches total). No throttling or errors observed at this rate.

2. **Actual subpage count < expected count**: The original mapping estimated far more subpages than exist as actual `type: "page"` blocks. Many expected subpages are heading/bookmark children, not sub-page blocks.

3. **Heading-nested pages**: Some real subpages (e.g., MultiLock, NestedLock under 分布式锁) live as children of heading blocks, not the root page block. BFS crawling needs to recurse through headings too.

4. **Empty page children**: Pages like 分布式事务 have bookmarks and headings as direct children but no `type: "page"` blocks. The page content is external references, not sub-pages.

## Mapping Table Template Used

```markdown
| # | Page ID | Title | Local Path | Depth | Status | Subpage IDs |
|---|---------|-------|-----------|-------|--------|-------------|
| 2 | `PAGE_ID` | Title | `path/file.md` | 1 | ✅ has subpages | `ID` (Name), `ID2` (Name 2) |
```

All 23 L1 pages confirmed. Status upgraded from generic "has subpages" to explicit subpage ID list.
