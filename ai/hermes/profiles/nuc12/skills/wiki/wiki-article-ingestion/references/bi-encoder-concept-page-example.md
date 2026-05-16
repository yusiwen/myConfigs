# Worked Example: Bi-Encoder Concept Page (Research-Driven)

Created: 2026-05-16
Source: Web research (10 searches, 3 extract attempts, ~15 minutes)

## Research Process Used

1. **Wiki check first** — `search_files("bi-encoder", path="$WIKI")` → found 6 files across concepts/ and raw/
2. **Broad coverage searches** — 3 parallel searches covering:
   - General architecture explanation
   - Training techniques (contrastive learning, InfoNCE, hard negatives)
   - Comparison with cross-encoder and ColBERT
3. **Deep dives** — 3 additional searches on:
   - Pooling strategies (mean, CLS, attention)
   - DPR and two-tower recommendation models
   - Model families (BGE, E5, Instructor, GTE)
4. **Extraction attempts** — web_extract on 3 URLs (all blocked). Used web_search results descriptions + browser for structured content
5. **Synthesis** — Organized into architecture diagram → training → inference → comparison table → model classification → applications → code → history

## Structure of the Resulting Page

`concepts/ai-ml/bi-encoder.md` (335 lines, 17KB)

### Sections created:

| Section | Key content |
|---------|-------------|
| **Architecture** | ASCII diagram, Siamese vs Asymmetric table, 4 pooling strategies, L2 normalization |
| **Training** | InfoNCE/Multiple Negatives Ranking Loss formula, 5 loss functions table, 5 negative sampling strategies with quality |
| **Inference pipeline** | Offline precompute → ANN index → query encode → ANN search flowchart |
| **Bi-Encoder vs Cross-Encoder vs ColBERT** | 9-row comparison covering encoding, interaction, precomputability, speed, accuracy, storage |
| **Model Classification** | NLP retrieval models (10 families) + recommendation two-tower models (5 systems) + embedding type taxonomy |
| **Applications** | 6 use cases with examples |
| **Strengths & Limitations** | 6 pros, 6 cons |
| **Code Example** | Runable Python using BGE-small + cosine similarity retrieval |
| **Historical Context** | 2013 (DSSM) → 2025–2026 (Matryoshka, LLM-as-embedding) |
| **Related Pages** | 5 cross-references to existing wiki pages |

### Cross-linking:

- Added `> Full standalone coverage: [[bi-encoder]]` to existing `cross-encoder-reranking.md` comparison section
- Added `[[bi-encoder]]` link to `recall-models.md` Related Pages section
- Updated `log.md` with creation entry

### Research constraints encountered:

- **web_extract blocked several sources** (Medium, Milvus, shadecoder.com returned empty or blocked). Workaround: rely on web_search descriptions + browser for these sites
- **Self-hosted SearXNG worked fine** for web_search
- **Log formatting pitfall** — `patch` tool displayed pipes as line-number separators; copying `old_string` from `read_file` output included invisible pipes → corrupted log entry. Fixed by re-reading the file and patching a clean `old_string`.

## Key research sources used

All sourced via web_search results pages when direct extraction was blocked:

- **ShadeCoder** — bi-encoder architecture comprehensive guide (2025)
- **Milvus AI Quick Reference** — bi-encoder vs cross-encoder decision guide
- **WaterCrawl** — beyond simple embeddings deep dive
- **Emergent Mind** — bi-encoder architecture topic page
- **ArXiv 2502.14822** — Survey of Model Architectures in Information Retrieval
- **Sentence Transformers docs** — loss functions, pooling modules
- **Ethen8181** — Training Bi-Encoder Models with Contrastive Learning Notes
- **Daily Dose of Data Science** — Visual guide to bi-encoders, cross-encoders and ColBERT

## Lessons for future research-driven pages

1. Always search wiki FIRST before web research — avoids duplicating existing coverage
2. Parallel web_search calls save time (up to 3 at once)
3. Have a fallback when web_extract is blocked — browser or rely on search result descriptions
4. Comparison tables are the highest-value content for concept pages — invest in getting 6-10 rows right
5. Always cross-link FROM existing related pages (not just TO them) — the bi-encoder page links to cross-encoder-reranking, AND the cross-encoder page should link back
6. Verify log.md patch content by re-reading before committing — the pipe-prefix bug is easy to miss
