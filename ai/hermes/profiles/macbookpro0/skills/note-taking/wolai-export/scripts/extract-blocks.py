#!/usr/bin/env python3
"""Extract block data from MCP's doubly-escaped JSON temp files.
 
Usage: python3 extract-blocks.py <mcp_temp_file> <output_json> <page_id> <title>

The MCP server returns data wrapped in double JSON encoding:
  {"result": "{\"status\":..., \"data\": {\"data\": [...]}}"}
  
This script unwraps both layers and saves clean block data.
"""
import json, sys

def main():
    if len(sys.argv) < 5:
        print(f"Usage: {sys.argv[0]} <input_file> <output_file> <page_id> <title>")
        sys.exit(1)
    
    infile = sys.argv[1]
    outfile = sys.argv[2]
    page_id = sys.argv[3]
    title = sys.argv[4]
    
    with open(infile) as f:
        raw = f.read()
    
    # Layer 1: outer JSON wrapper
    wrapper = json.loads(raw)
    # Layer 2: inner escaped JSON string
    inner = json.loads(wrapper["result"])
    # Extract blocks array
    blocks = inner["data"]["data"]
    
    with open(outfile, "w", encoding="utf-8") as f:
        json.dump({"page_id": page_id, "title": title, "blocks": blocks}, 
                  f, ensure_ascii=False)
    
    print(f"{title}: {len(blocks)} blocks saved to {outfile}")

if __name__ == "__main__":
    main()
