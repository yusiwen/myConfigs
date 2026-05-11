# Web Research Fallback Techniques

When `web_search` and browser tools are unavailable, use these curl+Python patterns to search and fetch web content. Verified working on macOS with curl installed.

## Search Engine Access

### Bing (most reliable for curl-based search)

Bing returns clean HTML results that are easily parsed. It's the most curl-friendly major search engine:

```python
import subprocess, re

result = subprocess.run([
    "curl", "-sL",
    f"https://www.bing.com/search?q={query.replace(' ', '+')}",
    "-H", "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
], capture_output=True, text=True, timeout=15)

# Extract result URLs
urls = re.findall(r'<a[^>]*href="(https?://[^"]+)"[^>]*>', result.stdout)
relevant = [u for u in urls if 'bing' not in u and 'microsoft' not in u and 'beian' not in u]
```

### Google (often serves captcha to curl)

Google frequently blocks curl requests with captcha, but sometimes returns parseable results:

```python
result = subprocess.run([
    "curl", "-sL",
    f"https://www.google.com/search?q={query.replace(' ', '+')}",
    "-H", "User-Agent: Mozilla/5.0"
], capture_output=True, text=True, timeout=15)
urls = re.findall(r'<a href="/url\?q=([^"&]+)', result.stdout)
```

### DuckDuckGo Lite (may return empty)

```python
result = subprocess.run([
    "curl", "-sL",
    f"https://lite.duckduckgo.com/lite/?q={urllib.parse.quote(query)}",
    "-H", "User-Agent: Mozilla/5.0"
], capture_output=True, text=True, timeout=15)
```

**Pitfall:** DuckDuckGo Lite often returns empty or error pages when accessed from non-browser clients. Don't rely on it as primary fallback.

## GitHub API Search

The GitHub API is the most reliable way to search issues, code, and discussion within a specific repo. No captcha, structured JSON output.

### Search Issues

```python
result = subprocess.run([
    "curl", "-sL",
    f"https://api.github.com/search/issues?q=repo:{owner}/{repo}+{urllib.parse.quote(keywords)}&per_page=10",
    "-H", "User-Agent: Mozilla/5.0",
    "-H", "Accept: application/vnd.github.v3+json"
], capture_output=True, text=True, timeout=15)

import json
data = json.loads(result.stdout)
for item in data.get("items", []):
    print(f"#{item['number']} [{item['state']}] {item['title']}")
    print(f"  URL: {item['html_url']}")
```

### Search Code

```python
result = subprocess.run([
    "curl", "-sL",
    f"https://api.github.com/search/code?q=repo:{owner}/{repo}+path:{path}+filename:{glob}&per_page=10",
    "-H", "User-Agent: Mozilla/5.0",
    "-H", "Accept: application/vnd.github.v3+json"
], capture_output=True, text=True, timeout=15)
```

### Fetch Issue Comments

```python
result = subprocess.run([
    "curl", "-sL",
    f"https://api.github.com/repos/{owner}/{repo}/issues/{number}/comments?per_page=30",
    "-H", "User-Agent: Mozilla/5.0",
    "-H", "Accept: application/vnd.github.v3+json"
], capture_output=True, text=True, timeout=15)
comments = json.loads(result.stdout)
```

### Useful Query Patterns

| Goal | Query |
|------|-------|
| All FIPS issues in golang/go | `repo:golang/go+FIPS+in:title` |
| Issues matching keywords in body | `repo:golang/go+fips+size+in:body` |
| Open issues by label | `repo:golang/go+label:Proposal+state:open` |
| Closed issue with specific phrase | `repo:golang/go+"all Linux binaries will be FIPS-capable"` |

## Direct Source Fetching

When you know the URL, fetch directly — more reliable than searching.

### Go Official Docs

```python
result = subprocess.run(["curl", "-sL", "https://go.dev/doc/security/fips140",
    "-H", "User-Agent: Mozilla/5.0"], capture_output=True, text=True, timeout=15)

# Strip HTML to readable text
content = re.sub(r'<script[^>]*>.*?</script>', '', result.stdout, flags=re.DOTALL)
content = re.sub(r'<[^>]+>', '\n', content)
content = re.sub(r'[ \t]+', ' ', content)
content = re.sub(r'\n{3,}', '\n\n', content)
```

### GitHub Raw Files

```python
url = f"https://raw.githubusercontent.com/{owner}/{repo}/refs/heads/{branch}/path/to/file"
result = subprocess.run(["curl", "-sL", url, "-H", "User-Agent: Mozilla/5.0"],
    capture_output=True, text=True, timeout=15)
if "404" in result.stdout[:10]:
    # Try different branch
    url = f"https://raw.githubusercontent.com/{owner}/{repo}/master/path/to/file"
    result = subprocess.run(["curl", "-sL", url, ...])
```

## Content Extraction Tips

1. **Always set a browser User-Agent** — many sites return different content to curl's default UA
2. **Strip HTML**: `re.sub(r'<[^>]+>', '\n', content)` followed by `re.sub(r'\n{3,}', '\n\n', content)`
3. **Strip scripts/styles**: `re.sub(r'<script[^>]*>.*?</script>', '', content, flags=re.DOTALL)`
4. **HTML entities**: decode `&amp;` `&lt;` `&gt;` `&#39;` `&quot;` after stripping tags
5. **Timeouts**: set `timeout=15` for simple pages, `timeout=30` for large content
6. **404 detection**: check `"404" in result.stdout[:10]` or check `result.returncode`

## Pitfalls

- **Google captcha**: Google frequently blocks curl. When that happens, try Bing instead.
- **DuckDuckGo Lite**: Returns empty for many queries. Not a reliable fallback.
- **GitHub API rate limits**: Unauthenticated requests limited to 60/hour. Be selective about what you fetch.
- **JavaScript-rendered pages**: curl can't execute JS. For SPAs, try the API endpoint directly.
- **Redirects**: `curl -sL` follows redirects automatically. If redirected to a login page, you get that.
- **macOS `grep`**: Doesn't support `-P` (Perl regex). Use Python's `re` module instead.
- **Bing filter**: Chinese-language results dominate when querying from a Chinese IP. Use English queries with `&setlang=en` parameter if needed.
