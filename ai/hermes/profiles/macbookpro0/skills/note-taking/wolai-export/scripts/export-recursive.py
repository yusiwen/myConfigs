#!/usr/bin/env python3
"""
Recursive Wolai -> Markdown exporter.
Reads /tmp/blocks_*.json files and produces the export directory
matching wolai.app's convention, with recursive page nesting.

Usage:
  python3 export-recursive.py [root_page_id] [export_dir]
    1. Save each page's blocks to /tmp/blocks_<slug>.json
       Format: {"page_id": "...", "title": "...", "blocks": [...]}
    2. Run: python3 export-recursive.py [root_id] [export_path]

The recursive exporter detects sub-pages by iterating type=page blocks.
If a parent's saved JSON is missing the sub-page marker blocks,
those sub-pages are invisible. Patch them in (see Pattern C in data-flow-patterns.md).

Output structure:
  export-dir/
  ├── Root.md
  ├── SubPage/SubPage.md
  ├── SubPage/GrandChild/GrandChild.md  <- handled recursively
"""

import json, os, re, shutil, glob, sys

# ── CONFIG ──────────────────────────────────────────────
EXPORT_DIR = "/Users/yusiwen/git/mine/wiki/raw"  # override with CLI arg 2
DATA_DIR = "/tmp"
# ────────────────────────────────────────────────────────

def render_inline(items):
    if not items: return ""
    parts = []
    for item in items:
        t = item.get("title","")
        typ = item.get("type","text")
        if typ == "equation": parts.append(f"${t}$"); continue
        if typ == "bi_link": parts.append(f"[{t}](wiki:{item.get('ref_id','')})"); continue
        text = t
        if item.get("inline_code"): text = f"`{text}`"
        if item.get("bold"): text = f"**{text}**"
        if item.get("italic"): text = f"*{text}*"
        if item.get("strikethrough"): text = f"~~{text}~~"
        if item.get("underline"): text = f"<u>{text}</u>"
        link = item.get("link")
        if link: text = f"[{text}]({link} \"{t}\")"
        parts.append(text)
    return "".join(parts)

def block_to_md(block):
    typ = block.get("type","")
    if typ == "heading":
        return f"\n{'#' * block.get('level',1)} {render_inline(block.get('content',[]))}\n"
    if typ == "text":
        return render_inline(block.get("content",[])) + "\n"
    if typ == "code":
        lang = block.get("language","")
        code = "".join(p.get("title","") for p in block.get("content",[]))
        return f"\n```{lang}\n{code}\n```\n"
    if typ == "bookmark":
        url = block.get("bookmark_source","")
        info = block.get("bookmark_info",{})
        t = info.get("title","") or url
        d = info.get("description","")
        if d: return f"> [{t}]({url})\n> {d}\n"
        return f"[{t}]({url})\n"
    if typ == "callout":
        return "> " + render_inline(block.get("content",[])) + "\n"
    if typ in ("bull_list","bul_list"):
        return "- " + render_inline(block.get("content",[])) + "\n"
    if typ in ("todo_list",):
        ck = "x" if block.get("checked") else " "
        return f"- [{ck}] " + render_inline(block.get("content",[])) + "\n"
    if typ == "enum_list":
        return "1. " + render_inline(block.get("content",[])) + "\n"
    if typ == "divider": return "---\n"
    if typ == "image":
        url = block.get("media",{}).get("download_url","")
        if url: return f"![image]({url})\n"
        return ""
    if typ == "quote": return "> " + render_inline(block.get("content",[])) + "\n"
    if typ == "block_equation": return "\n$$" + render_inline(block.get("content",[])) + "$$\n"
    return ""

def slugify(name):
    name = name.strip().replace(" ","-").replace("/","-").replace(":","-")
    name = name.replace("(","").replace(")","")
    name = re.sub(r'[<>"\\|?*]','',name)
    name = re.sub(r'-+','-',name).strip('-')
    return name or "untitled"

def get_page_title(blocks):
    for b in blocks:
        if b.get("type")=="page":
            c = b.get("content",[])
            if c: return c[0].get("title","Untitled")
    return "Untitled"

def build_ordered(blocks):
    bm = {b["id"]:b for b in blocks}
    for b in blocks:
        cids = b.get("children",{}).get("ids",[])
        b["_kids"] = []
        for cid in cids:
            if cid in bm: b["_kids"].append(bm[cid])
    for b in blocks:
        if b.get("type")=="page": return flatten(b)
    return []

def flatten(node, depth=0):
    r = [(node,depth)]
    for c in node.get("_kids",[]):
        r.extend(flatten(c,depth+1))
    return r

def find_subpages(blocks):
    root_id = None
    for b in blocks:
        if b.get("type")=="page": root_id = b["id"]; break
    result = []
    for b in blocks:
        if b.get("type")=="page" and b["id"] != root_id:
            result.append(b)
    return result

def page_to_md(blocks, subpage_links=None):
    page_title = get_page_title(blocks)
    ordered = build_ordered(blocks)
    root_id = blocks[0]["id"] if blocks else ""
    lines = [f"# {page_title}\n"]
    if subpage_links:
        lines.append("## 目录\n")
        for slug, title in subpage_links:
            lines.append(f"- [{title}]({slug}/{slug}.md \"{title}\")")
        lines.append("")
    for block, depth in ordered:
        if block.get("type")=="page" and block["id"]==root_id: continue
        if block.get("type")=="page": continue
        md = block_to_md(block)
        if md and md.strip():
            lines.append(md)
    return "\n".join(lines)

def main():
    if os.path.exists(EXPORT_DIR):
        shutil.rmtree(EXPORT_DIR)
    
    # Load all block data, index by page_id
    id_map = {}
    for jf in sorted(glob.glob(f"{DATA_DIR}/blocks_*.json")):
        with open(jf) as f:
            data = json.load(f)
        id_map[data["page_id"]] = data["blocks"]
    
    # Find root page — accept CLI arg or use default
    root_id = sys.argv[1] if len(sys.argv) > 1 else "iEW5q6vke2uSz7t6Pw2y5y"
    # Export dir — accept CLI arg 2 or use configured default
    export_dir = sys.argv[2] if len(sys.argv) > 2 else EXPORT_DIR
    if root_id not in id_map:
        print("ERROR: Root page data not found!")
        return
    
    def export_recursive(blocks, output_dir):
        """Recursively export a page and its sub-pages."""
        page_title = get_page_title(blocks)
        slug = slugify(page_title)
        os.makedirs(output_dir, exist_ok=True)
        
        subpages = find_subpages(blocks)
        subpage_links = []
        
        for sp in subpages:
            sp_id = sp["id"]
            sp_title = get_page_title([sp])
            sp_slug = slugify(sp_title)
            
            if sp_id in id_map:
                sp_blocks = id_map[sp_id]
                sp_dir = os.path.join(output_dir, sp_slug)
                export_recursive(sp_blocks, sp_dir)
                subpage_links.append((sp_slug, sp_title))
            else:
                print(f"  ⚠ {sp_title}: data not found, skip")
        
        md = page_to_md(blocks, subpage_links if subpage_links else None)
        md_path = os.path.join(output_dir, f"{slug}.md")
        with open(md_path, "w", encoding="utf-8") as f:
            f.write(md)
        print(f"  ✓ {slug}/{slug}.md ({page_title})")
    
    export_recursive(id_map[root_id], export_dir)
    print(f"\n✅ Export complete → {export_dir}")

if __name__ == "__main__":
    main()
