#!/usr/bin/env python3
"""
Scan wiki content files for sensitive data before ingesting them.

Usage:
    python3 scan-sensitive-data.py <path> [<path> ...]

    <path> can be a file or directory. Directories are walked recursively.

Output: JSON list of hits, one per match, with 'file', 'type', 'match' (redacted),
and 'line' fields. Exits 0 if no hits, 1 if hits found.

Integration:
    Import scan_files() from other scripts to integrate into ingest workflows.

Sensitive Data Convention (llm-wiki SKILL.md):
    Before adding any new information to the wiki — raw sources, wiki pages,
    or any content — check for sensitive data first. If found, report to user
    and let them decide how to handle (redact/skip/abort). Never decide unilaterally.
"""

import os
import re
import sys
import json

SENSITIVE_PATTERNS = [
    # API keys and tokens
    (r'(?i)(api[_-]?key|api[_-]?secret|access[_-]?key|secret[_-]?key)["\s:=]+["\']?[A-Za-z0-9_\-]{16,}', "API key / secret"),
    (r'(?i)(bearer|auth[_-]?token|token)["\s:=]+["\']?[A-Za-z0-9_\-]{20,}', "Bearer token / auth token"),
    (r'(?i)(sk-[A-Za-z0-9]{20,}|pk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{4,})', "OpenAI / GitHub token"),
    (r'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}', "JWT token (potentially real)"),
    (r'SWMTKN-[A-Za-z0-9-]{40,}', "Docker Swarm join token"),

    # Passwords
    (r'(?i)(password|passwd|pwd)["\s:=]+["\']?[A-Za-z0-9!@#$%^&*()_+\-={}\[\]|;:,.<>?]{8,}', "Password (>=8 chars)"),

    # Private keys and certs
    (r'-----BEGIN.*PRIVATE KEY-----', "Private key"),
    (r'-----BEGIN CERTIFICATE-----', "Certificate"),
    (r'(?i)(ssh-rsa|ssh-ed25519|ecdsa-sha2) AAAA[0-9A-Za-z+/]+[=]{0,3}', "SSH public key"),

    # Database connection strings with embedded credentials
    (r'(?i)(mongodb|postgresql|mysql|redis|jdbc|amqp|rabbitmq)://[^:\s]+:[^@\s]+@', "DB connection string with password"),
]

KNOWN_CLEAN_EXTS = {'.md'}
CONFIG_EXTS = {'.yaml', '.yml', '.ini', '.cfg', '.conf', '.toml', '.properties', '.env', '.json', '.py'}


def redact(text):
    """Shorten for safe display — show enough to identify, not enough to use."""
    if len(text) > 25:
        return text[:20] + "..."
    return text


def should_scan(filename):
    """Return True if filename extension matches a risky config file type."""
    _, ext = os.path.splitext(filename)
    if ext.lower() in CONFIG_EXTS:
        return True
    if ext.lower() in KNOWN_CLEAN_EXTS:
        # .md files: scan only if they look like config dumps (contain [section] headers, = values)
        return True  # Safe to scan all; false positives are filtered.
    return False


def is_placeholder(text):
    """Return True if the value looks like a placeholder, not a real secret."""
    placeholders = {
        'xxxx', '****', 'xxx', 'your-password', 'your-api-key', 'your_token',
        'placeholder', '<placeholder>', 'your_secure_password', 'default_secret_key',
        'yourAuthenticationToken', 'myAuthenticationToken',
        '<vpn_server>', '<vpn_account>', '<vpn_password>',
    }
    cleaned = text.strip().strip('"').strip("'").lower()
    # Detect shell variable interpolation: ${VAR} or $VAR
    if cleaned.startswith('${') or cleaned.startswith('$'):
        return True
    # Detect template syntax: {{ VAR }}
    if '{{' in cleaned:
        return True
    if cleaned in placeholders:
        return True
    return False


def scan_file(filepath):
    """Scan a single file for sensitive data patterns. Return list of hit dicts."""
    hits = []
    try:
        with open(filepath, 'r', errors='replace') as f:
            lines = f.readlines()
    except (PermissionError, IsADirectoryError, FileNotFoundError):
        return hits

    for lineno, line in enumerate(lines, 1):
        stripped = line.strip()
        for pattern, label in SENSITIVE_PATTERNS:
            for match in re.finditer(pattern, stripped):
                # Check if it's a known placeholder
                if is_placeholder(match.group(0)):
                    continue
                hits.append({
                    "file": filepath,
                    "type": label,
                    "match": redact(match.group(0)),
                    "line": lineno,
                })
    return hits


def scan_files(paths):
    """Scan files or directories. Return list of all hit dicts."""
    all_hits = []
    for path in paths:
        if os.path.isfile(path):
            all_hits.extend(scan_file(path))
        elif os.path.isdir(path):
            for root, dirs, files in os.walk(path):
                # Skip hidden dirs (like .git, __MACOSX)
                dirs[:] = [d for d in dirs if not d.startswith('.')]
                for fname in files:
                    if should_scan(fname):
                        fp = os.path.join(root, fname)
                        all_hits.extend(scan_file(fp))
    return all_hits


def format_report(hits):
    """Format hit list as a human-readable report string."""
    if not hits:
        return "✅ No sensitive data detected."

    lines = []
    lines.append(f"⚠️  {len(hits)} sensitive data hit(s) detected:\n")

    # Group by file
    by_file = {}
    for h in hits:
        by_file.setdefault(h["file"], []).append(h)

    for filepath, file_hits in sorted(by_file.items()):
        lines.append(f"  📄 {filepath}")
        for h in file_hits:
            lines.append(f"     • L{h['line']}: [{h['type']}] {h['match']}")
        lines.append("")
    return "\n".join(lines)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 scan-sensitive-data.py <path> [<path> ...]", file=sys.stderr)
        sys.exit(0)

    paths = sys.argv[1:]
    hits = scan_files(paths)

    print(format_report(hits))

    if hits:
        # Write machine-readable output to stderr for programmatic consumption
        print("\n--- MACHINE OUTPUT (parsable) ---", file=sys.stderr)
        json.dump(hits, sys.stderr, indent=2)
        sys.exit(1)
    sys.exit(0)
