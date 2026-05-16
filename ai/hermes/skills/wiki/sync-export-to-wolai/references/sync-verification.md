# Sync Verification: Does a Wiki Page Have a Wolai Counterpart?

## The Check Flow

Given a wiki page path (e.g., `concepts/ai-ml/cross-encoder-reranking.md` or `entities/tools/security-auth/authelia.md`), determine its sync status:

```
               ┌─────────────────────────────┐
               │ Read page frontmatter       │
               │ Does it have `sources:`?    │
               └──────────┬──────────────────┘
                          │
          ┌───────────────┴───────────────┐
          │ Yes                           │ No
          ▼                               ▼
   Check export mapping             Wiki-native page
   for that export path             ❌ No Wolai counterpart
          │
          ▼
   Find page ID in mapping
          │
          ▼
   Query Wolai page outline
   Compare content structure
```

## Case 1: Page Has `sources:` → Export-Derived

1. **Extract export name** from the sources path. E.g.:
   - `sources: [raw/distributed-systems-export/安全/框架&项目/authelia/authelia.md]` → export = `distributed-systems-export`
   - `sources: [raw/big-data-data-science-export/应用/推荐系统/召回模型/召回模型.md]` → export = `big-data-data-science-export`

2. **Find the mapping file** at `raw/tasks/mapping/<export-name>.md`.

3. **Search the mapping** for the page title or local path:
   ```bash
   # Search by local path (leaf filename)
   search_files(path="raw/tasks/mapping", pattern="召回模型.md", target="content")
   
   # The mapping line will show: 召回模型 (tFDAXrEALASkM3MEaXN6Y6)
   ```

4. **Query Wolai** to compare content:
   ```
   mcp_wolai_get_page_outline(page_id="tFDAXrEALASkM3MEaXN6Y6")
   ```
   If the Wolai page is missing sections that the wiki concept page has, those enrichments were never synced back.

5. **Check parent chain** to verify the page is at the expected location in the tree (see SKILL.md Step 2 for parent verification logic).

## Case 2: Page Has No `sources:` → Wiki-Native

- No Wolai page exists. The content was written directly in markdown.
- To create a Wolai counterpart: decide which export tree it belongs under, create the page via MCP, add it to the mapping file, and sync.

## Example from Session

```
Wiki page: concepts/ai-ml/recall-models.md
sources:
  - raw/big-data-data-science-export/应用/推荐系统/召回模型/召回模型.md
  - raw/big-data-data-science-export/应用/推荐系统/推荐系统.md

→ Has sources → export-derived
→ Mapping: big-data-data-science-export → 召回模型 (tFDAXrEALASkM3MEaXN6Y6)
→ Wolai outline: only DSSM + YouTubeDNN (2 sections)
→ Rich cross-encoder mention in wiki (116 lines) → NOT synced
→ Action needed: Direction B sync
```

```
Wiki page: concepts/ai-ml/cross-encoder-reranking.md
→ No sources → wiki-native
→ No Wolai page exists
→ No sync action possible (would need to create from scratch)
```

## Pitfalls

- **Same title, multiple Wolai results**: Search can return multiple pages with identical titles (e.g., "推荐系统" appears twice). Verify the parent chain to disambiguate.
- **Mapping not committed**: The mapping file may not reflect recently created pages. Fall back to Wolai search + parent verification.
- **`page_id` field in MCP response is misleading**: It returns the top-level L1 ancestor, not the page's own ID — never use it for parent verification. Use the `parent_id` field + `mcp_wolai_get_block()` for heading-children.
