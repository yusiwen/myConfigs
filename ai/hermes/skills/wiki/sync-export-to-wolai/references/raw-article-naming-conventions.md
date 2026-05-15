# Raw Article Naming Conventions

Files in `raw/articles/` are curated external source materials ingested into the wiki. Their filenames should reflect the **actual content**, not the original download filename.

## Google AI Mode Exports

Files exported from Google AI Mode follow the pattern:

```
google-ai-mode_<descriptive-content-name>.md
```

The original filenames (`llm-inference-google-ai-mode-qa*.md`) are opaque and don't reveal the content — rename them immediately upon ingestion.

### Existing files (2026-05-15)

| Current Name | Content Topic |
|-------------|---------------|
| `google-ai-mode_llm-inference-deep-dive.md` | LLM inference internals: tokenization, self-attention, encoder vs decoder, MoE (1126 lines, Chinese) |
| `google-ai-mode_llm-inference-prefill-decode.md` | Prefill vs Decode phases, KV cache, llama.cpp code example (471 lines, English) |
| `google-ai-mode_fourier-transform-visualization-tools.md` | Fourier Transform interactive visualization tools (27 lines, Chinese) |
| `google-ai-mode_docker-entrypoint-signal-variable.md` | Docker ENTRYPOINT exec vs shell format, signal handling, Drone CI, tini (454 lines, Chinese) |
| `google-ai-mode_gaussdb-distributed-replication-consistency.md` | GaussDB REPLICATION table consistency: 2PC, GTM/CSN, DN sync replication, Catch-up & Scrubbing (52 lines, Chinese) |

## Principles

1. **Name after content, not origin** — If the content is about GaussDB distributed replication consistency, the name should reflect that, not the Q&A session number.
2. **Keep the source prefix** — `google-ai-mode_` identifies the origin. If other sources are added later (e.g., Perplexity, Gemini exports), use their prefix.
3. **Be descriptive but concise** — aim for 3-5 hyphenated segments that capture the domain and specific topic.
4. **Use English** — even for Chinese-language articles, the filename should be English for shell-friendly handling.
5. **Lowercase with hyphens** — consistent with wiki SCHEMA.md conventions.
6. **Check for references before renaming** — after any rename, search the entire wiki for the old filename: `search_files(pattern="<old-path>", path="$WIKI")`. Update provenance markers (`^[raw/articles/...]`), frontmatter `sources:` fields, wikilinks, and log.md entries in a single commit.

## When to Create a raw/articles/ Entry

- The source is from an external Q&A tool (Google AI Mode, Perplexity, etc.)
- The content contains domain knowledge that could be referenced from multiple wiki pages
- The content is too long or raw to fit directly into a concept page
- ONE raw article = ONE topic. Split multi-topic exports into separate files.
