# HTML-to-Text Extraction via curl + Python

When research requires reading web documentation but the browser tool fails (Chrome sandbox issues in headless/container/VM environments), use `curl | python3` to extract text content from HTML pages.

## Core Pattern

```bash
curl -sL "$URL" 2>/dev/null | python3 -c "
import sys, re
data = sys.stdin.read()
# Strip scripts and styles first
content = re.sub(r'<script[^>]*>.*?</script>', '', data, flags=re.DOTALL)
content = re.sub(r'<style[^>]*>.*?</style>', '', content, flags=re.DOTALL)
# Strip all remaining HTML tags
content = re.sub(r'<[^>]+>', '\n', content)
# Collapse multiple newlines
content = re.sub(r'\n{3,}', '\n\n', content)
# Print non-blank lines
lines = [l.strip() for l in content.split('\n') if l.strip()]
for l in lines:
    print(l)
"
```

## Slicing by Section

When the page is long, slice output by focusing on a specific section:

```bash
curl -sL "$URL" 2>/dev/null | python3 -c "
import sys, re
data = sys.stdin.read()
content = re.sub(r'<script[^>]*>.*?</script>', '', data, flags=re.DOTALL)
content = re.sub(r'<style[^>]*>.*?</style>', '', content, flags=re.DOTALL)
content = re.sub(r'<[^>]+>', '\n', content)
content = re.sub(r'\n{3,}', '\n\n', content)
lines = [l.strip() for l in content.split('\n') if l.strip()]
# Print lines between a start and end marker
started = False
for l in lines:
    if 'Introduction' in l:
        started = True
    if started:
        print(l)
    if 'Further reading' in l:
        break
" | head -150
```

## When to Use

- Browser tool fails with Chrome sandbox errors (common in headless server VMs)
- Target is a plain static docs page, not a SPA with JS-rendered content
- You need quick text extraction without the full browser stack overhead

## Pitfalls

- **SPA sites won't work** — the Python script gets the raw HTML before JS executes. If the page loads content via JavaScript, use `pandoc` or `lynx -dump` via terminal instead.
- **Rate limiting** — some sites block curl. Add `-H 'User-Agent: Mozilla/5.0'` if needed.
- **Encoding issues** — pages with non-UTF-8 encoding need `chardet` detection. Add `| iconv -f latin1 -t utf-8` before python3 if garbage text appears.
- **No link extraction** — this strips `<a>` tags entirely. If you need URLs, grep for `href=` before stripping.
