---
name: google-scholar-scraper
description: "Ethical Google Scholar data collection techniques and best practices"
metadata:
  openclaw:
    emoji: "🔍"
    category: "tools"
    subcategory: "scraping"
    keywords: ["Google Scholar", "web scraping", "bibliometrics", "citation data", "scholarly search", "rate limiting"]
    source: "wentor-research-plugins"
---

# Google Scholar Scraper

A skill for ethically collecting bibliometric data from Google Scholar, including search results, citation counts, author profiles, and related articles. Covers rate limiting, CAPTCHA avoidance, alternative APIs, legal considerations, data parsing, and practical workflows that balance data needs with responsible access.

## Legal and Ethical Considerations

### Before You Scrape

Google Scholar does not offer an official API, and its Terms of Service restrict automated access. Researchers must weigh their data needs against legal and ethical constraints.

```
Legal landscape:

Terms of Service:
  - Google's ToS prohibit automated queries
  - Violation can result in IP blocking (temporary or permanent)
  - Institutional IPs can be blocked, affecting all campus users
  - In some jurisdictions, ToS violations are not legally binding
    for non-commercial academic research, but this is debated

Ethical guidelines:
  - Minimize load: respect the server, use delays between requests
  - Cache aggressively: never request the same page twice
  - Use official alternatives first (see below)
  - Do not redistribute raw scraped data
  - Cite Google Scholar as your data source in publications
  - Consider whether your research question truly requires
    Google Scholar data, or if Web of Science, Scopus, or
    OpenAlex could answer it instead

Official and semi-official alternatives:
  - OpenAlex API: free, no key required, excellent coverage
  - OpenAlex API: free, comprehensive, well-documented
  - Crossref API: free, DOI-based metadata and citation counts
  - CORE API: free, full-text open access content
  - Google Scholar Alerts: manual but ToS-compliant monitoring
  - Publish or Perish (software): uses Google Scholar with built-in
    rate limiting, commonly used in bibliometric research
```

## Data Collection Approaches

### Using Scholarly (Python Library)

The `scholarly` Python library wraps Google Scholar access with built-in rate limiting and proxy support. It is the most commonly used tool for academic Google Scholar scraping.

```python
from scholarly import scholarly, ProxyGenerator

def setup_scholarly_with_proxy():
    """
    Configure scholarly with a free proxy to reduce blocking risk.
    For heavy usage, consider ScraperAPI or similar paid services.
    """
    pg = ProxyGenerator()
    # Free proxy (less reliable, suitable for small jobs)
    pg.FreeProxies()
    scholarly.use_proxy(pg)


def search_scholar(query, max_results=20):
    """
    Search Google Scholar and collect structured results.

    IMPORTANT: Add delays between queries to avoid blocking.
    Recommended: 10-30 seconds between searches.
    """
    import time

    results = []
    search_query = scholarly.search_pubs(query)

    for i in range(max_results):
        try:
            result = next(search_query)
            parsed = {
                "title": result["bib"].get("title", ""),
                "author": result["bib"].get("author", []),
                "year": result["bib"].get("pub_year", ""),
                "venue": result["bib"].get("venue", ""),
                "abstract": result["bib"].get("abstract", ""),
                "citations": result.get("num_citations", 0),
                "url": result.get("pub_url", ""),
            }
            results.append(parsed)

            # Rate limiting: wait between result fetches
            time.sleep(2)

        except StopIteration:
            break

    return results


def get_author_profile(author_name):
    """
    Retrieve an author's Google Scholar profile.
    Includes h-index, i10-index, and publication list.
    """
    search_query = scholarly.search_author(author_name)
    author = next(search_query)
    author = scholarly.fill(author)

    profile = {
        "name": author.get("name", ""),
        "affiliation": author.get("affiliation", ""),
        "h_index": author.get("hindex", 0),
        "i10_index": author.get("i10index", 0),
        "cited_by": author.get("citedby", 0),
        "interests": author.get("interests", []),
        "publications": len(author.get("publications", [])),
    }

    return profile
```

## Rate Limiting and Anti-Blocking

### Best Practices

```
Rate limiting strategy:

1. Request delays:
   - Between search queries: 15-30 seconds minimum
   - Between profile lookups: 10-20 seconds
   - Between citation fetches: 5-10 seconds
   - Add random jitter: delay + random(0, 5) seconds

2. Session management:
   - Rotate user agents (maintain a list of 10+ real browser UAs)
   - Clear cookies periodically
   - Use residential proxies for large jobs (paid)
   - Limit sessions to 100-200 requests before rotating proxy

3. Caching:
   - Cache every response to disk (shelve, sqlite, or JSON)
   - Check cache before making any request
   - Set cache expiry (7-30 days for citation counts)

4. Batch scheduling:
   - Spread collection over days, not hours
   - Run during off-peak hours (late night UTC)
   - Process in batches of 50-100 queries per session
```

### Handling CAPTCHAs and Blocks

```python
import time
import random

def resilient_search(query, max_retries=3):
    """
    Search with exponential backoff on failures.
    When blocked, wait and retry with increasing delays.
    """
    for attempt in range(max_retries):
        try:
            results = search_scholar(query, max_results=10)
            return results
        except Exception as e:
            if "CAPTCHA" in str(e) or "429" in str(e):
                wait_time = (2 ** attempt) * 60 + random.randint(0, 30)
                print(f"Blocked. Waiting {wait_time}s before retry "
                      f"(attempt {attempt + 1}/{max_retries})")
                time.sleep(wait_time)
            else:
                raise e

    print("Max retries exceeded. Consider using a different proxy "
          "or waiting 24 hours before resuming.")
    return []
```

## Data Processing and Storage

### Structuring Collected Data

```python
import pandas as pd
import json
from datetime import datetime

def save_results(results, output_dir, query_name):
    """
    Save scraped results in multiple formats with metadata.
    """
    # Add collection metadata
    metadata = {
        "query": query_name,
        "collected_at": datetime.now().isoformat(),
        "n_results": len(results),
        "source": "google_scholar",
    }

    # Save as JSON (preserves all structure)
    with open(f"{output_dir}/{query_name}_results.json", "w") as f:
        json.dump({"metadata": metadata, "results": results}, f, indent=2)

    # Save as CSV (for spreadsheet analysis)
    df = pd.DataFrame(results)
    df.to_csv(f"{output_dir}/{query_name}_results.csv", index=False)

    return f"Saved {len(results)} results for query: {query_name}"
```

## Recommended Alternatives to Scraping

### When Not to Scrape Google Scholar

```
Use these free APIs instead when possible:

OpenAlex (openalex.org):
  - Coverage: 250M+ works
  - API: REST, no key needed (polite pool with email)
  - Rate limit: 10 requests/sec (polite pool), 100K/day
  - Data: titles, abstracts, citations, authors, institutions
  - Best for: large-scale bibliometric analysis

OpenAlex (openalex.org):
  - Coverage: 250M+ works, all disciplines
  - API: REST, no key required
  - Rate limit: ~10 requests/sec polite
  - Data: titles, abstracts, citations, concepts, author profiles
  - Best for: cross-disciplinary analysis, open data research

Crossref (crossref.org):
  - Coverage: 130M+ DOIs
  - API: REST, no key needed (polite pool with email)
  - Data: metadata, reference lists, citation counts
  - Best for: DOI resolution, reference matching

Use Google Scholar scraping ONLY when:
  - You need Google Scholar-specific metrics (h-index by GS)
  - Your target papers are not indexed elsewhere
  - You need Google Scholar's ranking/relevance ordering
  - Small-scale collection (< 500 results)
```

Responsible data collection from Google Scholar requires balancing research needs with ethical obligations to shared infrastructure. When possible, prefer official APIs that are designed for programmatic access. When scraping is necessary, implement aggressive rate limiting, cache results, and keep total request volumes as low as your research question permits.
