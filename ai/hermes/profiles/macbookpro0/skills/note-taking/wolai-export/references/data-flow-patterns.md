# Data Flow Patterns for Wolai Export

This reference documents the three data-flow patterns for moving block data from MCP to the export filesystem.

## Pattern A: Inline Save Script (Compact Pages)

For pages with <50 blocks whose block data fits in the agent context.

**Steps:**
1. Call `mcp_wolai_get_page_blocks(page_id="...")` — result appears in agent context
2. Write a Python save script via `write_file()`
3. Run it: `terminal("python3 /tmp/save_script.py")`

**Example** (DNS, 3 blocks):

```python
# /tmp/save_dns.py
import json
blocks = [
  {"id":"w5aZjRdK8sc5zz2XAvCDVb","type":"page","content":[{"title":"DNS","type":"text"}],"parent_id":"...","page_id":"...","parent_type":"page","children":{"ids":["r9kBMw6UkEMrvoKPHLqmHM","7sswub6Drwqx9wynn7TrQ4"]}},
  {"id":"r9kBMw6UkEMrvoKPHLqmHM","type":"text","content":[{"title":"DNS","type":"bi_link","ref_id":"a9JXymMZK44KjrYtj3hgmR","block_id":"xk9tgLzkgmexn12novPP4i"}],"parent_id":"w5aZjRdK8sc5zz2XAvCDVb","page_id":"w5aZjRdK8sc5zz2XAvCDVb","parent_type":"page","children":{"ids":[]}},
]
with open('/tmp/blocks_dns.json','w',encoding='utf-8') as f:
    json.dump({"page_id":"w5aZjRdK8sc5zz2XAvCDVb","title":"DNS","blocks":blocks},f,ensure_ascii=False)
```

## Pattern B: Extract from Persisted Temp File (Large Pages, 100+ blocks)

Large MCP results auto-persist to `/var/folders/.../hermes-results/call_*.txt`.

**Steps:**
1. Call `mcp_wolai_get_page_blocks(page_id="...")` — result auto-persisted
2. Run the extract script:

```bash
python3 <skill_dir>/scripts/extract-blocks.py \
  /var/folders/hz/.../T/hermes-results/call_02_xxx.txt \
  /tmp/blocks_security.json \
  "2wHRAJhGEkPNXDqjn7qV6p" \
  "安全"
```

**Script** (bundled as `scripts/extract-blocks.py`):

```python
import json, sys
with open(sys.argv[1]) as f: raw = f.read()
wrapper = json.loads(raw)
inner = json.loads(wrapper["result"])
blocks = inner["data"]["data"]
with open(sys.argv[2], "w", encoding="utf-8") as f:
    json.dump({"page_id": sys.argv[3], "title": sys.argv[4], "blocks": blocks}, f, ensure_ascii=False)
print(f"{sys.argv[4]}: {len(blocks)} blocks saved")
```

### Sub-page Reference Rules

1. **The sub-page type="page" block must exist** in the parent's blocks array. The recursive exporter finds sub-pages by scanning for `type="page"` blocks.
2. **The parent's `children.ids` must include the sub-page block ID**. Even if the block exists, the tree builder only visits children listed in the parent's `children.ids` array.
3. **Each sub-page needs its own JSON file** with full block data, indexed by `page_id`.

### Iterative Workflow

For deep hierarchies (5+ levels):
1. Fetch top-level pages first
2. Run the exporter to see which sub-pages are missing (`⚠ data not found`)
3. Fetch those pages, save their data, patch parent refs if needed
4. Re-run — repeat until no warnings

## Pattern C: Patch Missing Sub-page References

The recursive exporter detects sub-pages by iterating `type="page"` blocks. If a simplified save omitted the sub-page marker blocks, use this pattern.

**When needed:**
- You saved a parent page with a simplified block set
- The exporter shows "⚠ SubPage: data not found, skip" for a page whose data DOES exist

**Steps:**
1. Check which IDs are in the parent's data:
   ```python
   with open('/tmp/blocks_parent.json') as f: data = json.load(f)
   existing_ids = {b['id'] for b in data['blocks']}
   ```
2. Add missing type="page" references:
   ```python
   refs = [
     {"id":"gJs2eJ6A5LrhUZrU3aMw6K","type":"page","content":[{"title":"HTTPS","type":"text"}],
      "parent_id":"w91HnFpPXXNzSzDWKwDQr1","page_id":"2wHRAJhGEkPNXDqjn7qV6p",
      "parent_type":"header","children":{"ids":["bgTT38bCdsi4mE8hk4BAYE","s7WRaXDit2nFCtA9q6gmZ1"]}},
   ]
   for sp in refs:
       if sp['id'] not in existing_ids:
           data['blocks'].append(sp)
   with open('/tmp/blocks_parent.json','w') as f: json.dump(data, f, ensure_ascii=False)
   ```

## Running the Export

After all block data files are in `/tmp/blocks_*.json`:

```bash
python3 <skill_dir>/scripts/export-recursive.py
```

This reads all `/tmp/blocks_*.json` files, indexes by `page_id`, then recursively traverses from the root page, writing nested folders for each sub-page level.

## Quick Check

```bash
find /tmp -name 'blocks_*.json' | sort   # list all data files
find <export_dir> -type f | sort          # verify output structure
```
