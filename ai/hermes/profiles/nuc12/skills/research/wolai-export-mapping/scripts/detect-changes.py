#!/usr/bin/env python3
"""Two-tier change detection between Wolai.app and local exports.
See SKILL.md for workflow details."""
import re, json, argparse
from datetime import datetime, timezone
from pathlib import Path

MAPPING_DIR = Path(__file__).parent.parent.resolve()
SNAPSHOT_FILE = MAPPING_DIR / "_snapshot.json"

def log(msg, level="INFO"):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] [{level}] {msg}")

def load_snapshot():
    if SNAPSHOT_FILE.exists():
        with open(SNAPSHOT_FILE) as f:
            return json.load(f)
    return {"version": 1, "created_at": None, "updated_at": None, "pages": {}}

def save_snapshot(snapshot):
    snapshot["updated_at"] = datetime.now(timezone.utc).isoformat()
    with open(SNAPSHOT_FILE, "w") as f:
        json.dump(snapshot, f, indent=2, ensure_ascii=False)
    log(f"Snapshot saved ({len(snapshot['pages'])} pages)")

def extract_all_page_ids(text, export_name):
    pages = {}
    for pat in [r'\(([A-Za-z0-9]{13,})\)', r'\[([A-Za-z0-9]{13,})\]', r'`([A-Za-z0-9]{13,})`']:
        for m in re.finditer(pat, text):
            pid = m.group(1)
            if pid not in pages:
                pages[pid] = {"title": "?", "local_path": None, "export": export_name, "edited_at": None}
    return pages

def extract_pages_from_table_format(text, export_name):
    pages = {}
    for m in re.finditer(r'\|\s*\d+\s*\|\s*`([A-Za-z0-9]{13,})`\s*\|\s*([^|]+?)\s*\|\s*`([^`]+)`\s*\|', text):
        pages[m.group(1)] = {"title": m.group(2).strip(), "local_path": f"raw/{export_name}/{m.group(3).strip()}", "export": export_name, "edited_at": None}
    return pages

def build_snapshot():
    snap = {"version": 1, "created_at": datetime.now(timezone.utc).isoformat(), "updated_at": None, "pages": {}}
    for mf in sorted(MAPPING_DIR.glob("*-export.md")):
        name = mf.stem
        text = mf.read_text(encoding="utf-8")
        pages = extract_pages_from_table_format(text, name)
        # try bracket tree
        if not pages:
            for line in text.split('\n'):
                for m in re.finditer(r'\[([A-Za-z0-9]{13,})\]', line):
                    pid = m.group(1)
                    before = re.sub(r'^[│├└─★\s]+', '', line[:m.start()].strip()).strip()
                    before = re.sub(r'\s*\([^)]*\)\s*$', '', before).strip()
                    if before and pid not in pages:
                        pages[pid] = {"title": before, "local_path": None, "export": name, "edited_at": None}
        catchall = extract_all_page_ids(text, name)
        for pid, info in catchall.items():
            if pid not in pages:
                pages[pid] = info
        log(f"  {name}: {len(pages)} pages")
        for pid, info in pages.items():
            if pid not in snap["pages"]:
                snap["pages"][pid] = info
    log(f"Total: {len(snap['pages'])} pages")
    return snap

def prepare_scan_plan(snapshot, full=False):
    if full:
        return list(snapshot["pages"].keys())
    return [pid for pid, info in snapshot["pages"].items()
            if info.get("edited_at") is None or
            (info.get("local_path") and len(info["local_path"].split("/")) <= 4)]

def print_report(changed, new_p, del_p):
    print("\n" + "="*80 + "\n  CHANGE DETECTION REPORT\n" + "="*80)
    if not changed and not new_p and not del_p:
        print("\n  ✅ No changes.\n"); return
    if changed:
        print(f"\n  📝 EDITED ({len(changed)}):")
        for pid, info in sorted(changed, key=lambda x: x[1].get('export','')):
            print(f"    {pid} — {info.get('title','?')} ({info.get('export','?')})")
    if new_p:
        print(f"\n  🆕 NEW ({len(new_p)}):")
        for pid, info in sorted(new_p, key=lambda x: x[1].get('export','')):
            print(f"    {pid} — {info.get('title','?')} ({info.get('export','?')})")
    if del_p:
        print(f"\n  🗑️ DELETED ({len(del_p)}):")
        for pid, info in sorted(del_p, key=lambda x: x[1].get('export','')):
            print(f"    {pid} — {info.get('title','?')} (was {info.get('export','?')})")
    print()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--full", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--build-snapshot", action="store_true")
    ap.add_argument("--scan-list", action="store_true")
    args = ap.parse_args()
    if args.build_snapshot or not SNAPSHOT_FILE.exists():
        save_snapshot(build_snapshot())
        if args.build_snapshot:
            return
    snap = load_snapshot()
    scan_ids = prepare_scan_plan(snap, args.full)
    if args.dry_run or args.scan_list:
        by_exp = {}
        for pid in scan_ids:
            by_exp.setdefault(snap["pages"][pid].get("export","?"), []).append(pid)
        print(f"\n  SCAN PLAN ({'FULL' if args.full else 'QUICK'}): {len(scan_ids)} pages")
        for e in sorted(by_exp):
            print(f"    {e}: {len(by_exp[e])}")
        if args.scan_list:
            print(json.dumps(scan_ids))
        return
    print(f"\n  [AGENT] Scan {len(scan_ids)} pages ({'FULL' if args.full else 'QUICK'})")

if __name__ == "__main__":
    main()
