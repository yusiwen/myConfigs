# Entity Audit — 2026-05-13

Full wiki entity coverage scan. Methodology: scan raw/ export directory structure + grep concept pages for proper noun mentions + cross-reference against existing entities/.

## Existing Entities (393 total → 420 after batch creation)

| Entity Type | Before | After | Pages Created |
|---|---|---|---|
| tools | 391 | 391 | — (no new tools) |
| companies | 2 | 14 | 12 new (NVIDIA, Oracle, JetBrains, Meta, Microsoft, HashiCorp, Canonical, Intel, Elastic, Red Hat, Mozilla, CNCF) |
| people | 0 | 8 | 8 new (Karpathy, Hotz, Torvalds, Thompson, van Rossum, Hinton, Ng, Huang) |
| models | 0 | 7 | 7 new (BERT, LLaMA, GPT-4, Stable Diffusion, Whisper, T5, Word2Vec) |

## Missing Entity Types (defined in SCHEMA.md but empty)

All SCHEMA.md-defined entity types now have pages. Next candidates:

| Entity Directory | Status |
|---|---|
| `entities/people/` | ✅ Populated (8 pages) |
| `entities/models/` | ✅ Populated (7 pages) |
| `entities/companies/` | ✅ Expanded (14 pages) |

## People Candidates

| Name | Mentioned In | Context |
|---|---|---|
| Andrej Karpathy | tinygrad, LLM inference, large-language-models, autograd | nanoGPT, micrograd, former Tesla AI |
| George Hotz | tinygrad (entity + index) | Tinygrad creator, comma.ai |
| Linus Torvalds | git.md, minix.md | Linux kernel, Git |
| Ken Thompson | Go index | Go co-creator, Unix pioneer, B language |
| Guido van Rossum | Python index | Python creator |
| Geoffrey Hinton | knowledge-distillation | Godfather of deep learning |
| Andrew Ng | prompt-engineering | DeepLearning.AI, Stanford |
| Robert Griesemer | Go index | Go co-creator |
| Rob Pike | Go index | Go co-creator, Plan 9 |

## ML Model Candidates

| Model | Concept Page Mentions | Primary Context |
|---|---|---|
| BERT | 31 | NLP, embedding, NER, QA |
| Llama / LLaMA | 27 | LLM family, RAG |
| ResNet | 15 | Computer vision, CNN, image recognition |
| GPT-4 / GPT-3 | 14 | LLM family |
| Transformer | 33 | (straddles concept/entity — well-covered as concept) |
| YOLO | 6 | (exists as tool/yolo — but primarily a model) |
| Stable Diffusion | 9 | Image generation, diffusion models |
| Whisper | 4 | STT/TTS |
| MoE | 12 | Architecture pattern |
| T5 | 8 | Text-to-text, encoder-decoder |
| Word2Vec | 3 | Word embedding |
| Mamba | 1 | State-space model |
| CLIP | 1 | Multi-modal embedding |

## Organization Candidates

| Organization | Ref Count | Notes |
|---|---|---|
| NVIDIA | 32 | GPU, CUDA, Jetson, DeepStream — huge cross-cutting refs |
| Oracle | 38 | Database, Java (heavily tool-ref'ed) |
| IEEE | 29 | Networking standards (802.11, 802.3) |
| JetBrains | 19 | IntelliJ, CLion, GraalVM |
| CNCF | 16 | Cloud Native Computing Foundation |
| HashiCorp | 12 | Terraform, Vault, Consul, Nomad |
| ASF | 12 | Apache Software Foundation (has concept page at concepts/misc/asf.md) |
| Canonical | 10 | Ubuntu, MicroK8s, LXD |
| Elastic | 6 | Elasticsearch, Kibana, Elastic Stack |
| Mozilla | 4 | Firefox, MDN Web Docs |
| OWASP | 4 | Web security standards |
| IETF | 4 | Internet standards |
| W3C | 3 | Web standards |
| Databricks | 1 | Spark, Delta Lake, MLflow |

## Protocol / Standard Candidates

| Name | Ref Count | Type |
|---|---|---|
| PCIe | 62 | Hardware bus standard |
| VXLAN | 45 | Network overlay protocol |
| FIPS / NIST | 46+5 | Crypto compliance |
| QUIC | 35 | Transport protocol |
| WebAssembly | 19 | Cross-platform binary format |
| HTTP/3 | 18 | Web protocol (covered under HTTP concept) |
| gRPC | 15 | RPC framework |
| OAuth / OAuth2 | 14 | Authentication framework |
| AMQP | 9 | Messaging protocol |
| Geneve | 8 | Network overlay |
| GraphQL | 6 | API query language |
| OpenAPI | 6 | API specification |
| RISC-V | 5 | Open ISA |
| Kerberos | 9 | Authentication protocol |
