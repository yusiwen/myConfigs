#!/usr/bin/env python3
"""Extract wolai block data from MCP's doubly-escaped JSON temp files.

Usage:
    python3 extract_blocks.py <input_file> <output_file> <page_id> <title>

Input file format (from MCP saved output):
    {"result": "{\n  \"status\": \"success\",\n  \"data\": {\n    \"data\": [...blocks...]\n  }\n}"}

Output file:
    {"page_id": "...", "title": "...", "blocks": [...]}
"""
import json, sys

def main():
    if len(sys.argv) != 5:
        print(f"Usage: {sys.argv[0]} <infile> <outfile> <page_id> <title>")
        sys.exit(1)
    
    infile, outfile, page_id, title = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
    
    with open(infile) as f:
        raw = f.read()
    
    # Parse the doubly-encoded JSON
    wrapper = json.loads(raw)
    inner = json.loads(wrapper["result"])
    blocks = inner["data"]["data"]
    
    with open(outfile, "w", encoding="utf-8") as f:
        json.dump({"page_id": page_id, "title": title, "blocks": blocks}, f, ensure_ascii=False)
    
    print(f"{title}: {len(blocks)} blocks saved")

if __name__ == "__main__":
    main()
