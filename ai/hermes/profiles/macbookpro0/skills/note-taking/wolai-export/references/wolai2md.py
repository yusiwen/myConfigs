#!/usr/bin/env python3
"""Wolai blocks → Markdown exporter.
Converts get_page_blocks output to .md files matching wolai.app's export convention.

Usage: python3 wolai2md.py
Expects /tmp/blocks_*.json files with format:
    {"page_id": "...", "title": "...", "blocks": [...]}

Output: raw/<category>-export/ following the export structure convention.
"""
import json, os, re, sys, shutil

EXPORT_DIR = "/Users/yusiwen/git/mine/wiki/raw/web-export"

def render_inline(items):
    if not items:
        return ""
    parts = []
    for item in items:
        title = item.get("title", "")
        typ = item.get("type", "text")
        if typ == "equation":
            parts.append(f"${title}$")
            continue
        if typ == "bi_link":
            parts.append(f"[{title}](wiki:{item.get('ref_id','')})")
            continue
        text = title
        if item.get("inline_code"): text = f"`{text}`"
        if item.get("bold"): text = f"**{text}**"
        if item.get("italic"): text = f"*{text}*"
        if item.get("strikethrough"): text = f"~~{text}~~"
        if item.get("underline"): text = f"<u>{text}</u>"
        link = item.get("link")
        if link: text = f"[{text}]({link} \"{title}\")"
        parts.append(text)
    return "".join(parts)

def block_to_md(block, indent=0):
    typ = block.get("type", "")
    if typ == "heading":
        lvl = block.get("level", 1)
        return f"\n{'#' * lvl} {render_inline(block.get('content',[]))}\n"
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
        c = render_inline(block.get("content",[]))
        ico = block.get("icon",{}).get("icon","")
        return f"> {ico} {c}\n"
    if typ == "bull_list":
        return "- " + render_inline(block.get("content",[])) + "\n"
    if typ == "enum_list":
        return "1. " + render_inline(block.get("content",[])) + "\n"
    if typ == "todo_list":
        ck = "x" if block.get("checked") else " "
        return f"- [{ck}] " + render_inline(block.get("content",[])) + "\n"
    if typ == "divider": return "---\n"
    if typ == "image":
        url = block.get("media",{}).get("download_url","")
        if url: return f"![image]({url})\n"
        return ""
    if typ == "quote":
        return "> " + render_inline(block.get("content",[])) + "\n"
    if typ in ("toggle_list",):
        c = render_inline(block.get("content",[]))
        return f"<details><summary>{c}</summary>\n\n</details>\n"
    if typ == "block_equation":
        return "\n$$" + render_inline(block.get("content",[])) + "$$\n"
    if typ == "simple_table":
        rows = block.get("table_content",[])
        if not rows: return ""
        lines = ["| " + " | ".join(str(c) for c in r) + " |" for r in rows]
        lines.insert(1, "| " + " | ".join(["---"]*len(rows[0])) + " |")
        return "\n".join(lines) + "\n"
    return ""

def slugify(name):
    name = name.strip().replace(" ", "-").replace("/","-").replace(":","")
    name = re.sub(r'[<>()"\\|?*]', '', name)
    name = re.sub(r'-+', '-', name).strip('-')
    return name or "untitled"

def get_page_title(blocks):
    for b in blocks:
        if b.get("type") == "page":
            c = b.get("content",[])
            if c: return c[0].get("title","Untitled")
    return "Untitled"

def build_ordered(blocks):
    bm = {b["id"]: b for b in blocks}
    for b in blocks:
        cids = b.get("children",{}).get("ids",[])
        b["_kids"] = []
        for cid in cids:
            if cid in bm: b["_kids"].append(bm[cid])
    for b in blocks:
        if b.get("type") == "page":
            return flatten(b)
    return []

def flatten(node, depth=0):
    r = [(node, depth)]
    for c in node.get("_kids",[]):
        r.extend(flatten(c, depth+1))
    return r

def page_to_md(blocks):
    page_title = get_page_title(blocks)
    ordered = build_ordered(blocks)
    lines = [f"# {page_title}\n"]
    page_id = blocks[0]["id"] if blocks else ""
    for block, depth in ordered:
        if block.get("type") == "page":
            continue  # Skip page markers / sub-page refs
        md = block_to_md(block, depth-1)
        if md and md.strip():
            lines.append(md)
    return "\n".join(lines)

def main():
    import glob
    
    if os.path.exists(EXPORT_DIR):
        shutil.rmtree(EXPORT_DIR)
    
    json_files = sorted(glob.glob("/tmp/blocks_*.json"))
    if not json_files:
        print("No block data files found in /tmp/blocks_*.json")
        print("First save each page's blocks to JSON files")
        return
    
    results = {}
    for jf in json_files:
        with open(jf, "r", encoding="utf-8") as f:
            data = json.load(f)
        page_id = data["page_id"]
        title = data["title"]
        blocks = data["blocks"]
        slug = slugify(title)
        md = page_to_md(blocks)
        results[page_id] = {"slug": slug, "title": title, "md": md, "blocks": blocks}
        print(f"  \u2713 {slug}/{slug}.md ({title})")
    
    # Build root Web.md
    root_id = None
    for pid, data in results.items():
        for b in data["blocks"]:
            if b.get("type") == "page" and b.get("parent_type") == "workspace":
                root_id = pid
                break
    if not root_id:
        print("ERROR: No root page found!")
        return
    
    root_data = results[root_id]
    root_blocks = root_data["blocks"]
    
    # Determine child pages (type="page" under root)  
    child_ids = []
    for b in root_blocks:
        if b.get("type") == "page" and b["id"] != root_id:
            cid = b["id"]
            ctitle = b.get("content",[{}])[0].get("title","?")
            if cid in results:
                child_ids.append((cid, ctitle))
    
    # Write root page
    os.makedirs(EXPORT_DIR, exist_ok=True)
    web_lines = [f"# {root_data['title']}\n", "## 目录\n"]
    for cid, ctitle in child_ids:
        cslug = results[cid]["slug"]
        web_lines.append(f"- [{ctitle}]({cslug}/{cslug}.md \"{ctitle}\")")
    
    web_lines.append("")
    ordered = build_ordered(root_blocks)
    for block, depth in ordered:
        if block.get("type") == "page": continue
        md = block_to_md(block, 0)
        if md and md.strip():
            web_lines.append(md)
    
    with open(os.path.join(EXPORT_DIR, f"{root_data['slug']}.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(web_lines))
    
    # Write each sub-page
    for cid, ctitle in child_ids:
        data = results[cid]
        slug = data["slug"]
        sub_dir = os.path.join(EXPORT_DIR, slug)
        os.makedirs(sub_dir, exist_ok=True)
        with open(os.path.join(sub_dir, f"{slug}.md"), "w", encoding="utf-8") as f:
            f.write(data["md"])
    
    print(f"\n\u2705 Export complete: {len(child_ids)+1} pages \u2192 {EXPORT_DIR}")

if __name__ == "__main__":
    main()
