---
name: academic-web-scraping
description: "Ethical web scraping and API-based data collection for research"
metadata:
  openclaw:
    emoji: "🌐"
    category: "tools"
    subcategory: "scraping"
    keywords: ["web scraping", "API data collection", "web search strategies", "data extraction"]
    source: "N/A"
---

# Academic Web Scraping Guide

## Overview

Research often requires collecting data from the web -- whether it is bibliographic metadata from academic databases, experimental datasets from public repositories, social media posts for computational social science, or economic indicators from government portals. Web scraping and API-based data collection are essential skills for modern researchers across disciplines.

This guide covers both approaches: structured API access for platforms that provide one, and web scraping for when no API exists. It emphasizes ethical data collection practices, including respecting robots.txt, rate limiting, terms of service compliance, and IRB considerations for human-subject data. The goal is to collect research data reliably and responsibly.

Whether you are building a dataset for a machine learning paper, collecting metadata for a systematic review, or gathering public data for policy research, these patterns help you do it correctly and efficiently.

## API-Based Data Collection

APIs are always preferable to scraping when available. They provide structured data, are officially supported, and have clear usage terms.

### Academic APIs

| API | Data | Rate Limit | Auth |
|-----|------|-----------|------|
| OpenAlex | Papers, authors, venues, concepts | 100K req/day | Email in header |
| Crossref | DOI metadata | 50 req/sec (polite pool) | Email in header |
| PubMed (Entrez) | Biomedical literature | 10 req/sec (with key) | API key (free) |
| arXiv | Preprints | 1 req/3sec | None |
| CORE | Open access papers | 10 req/sec | API key (free) |

### Example: Collecting Papers from OpenAlex

```python
import requests
import time

class OpenAlexClient:
    BASE_URL = "https://api.openalex.org"

    def __init__(self, email):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': f'ResearchBot/1.0 (mailto:{email})'
        })

    def search_works(self, query, filters=None, per_page=25, max_results=100):
        """Search for works with optional filters."""
        results = []
        page = 1

        while len(results) < max_results:
            params = {
                'search': query,
                'per_page': min(per_page, max_results - len(results)),
                'page': page,
            }
            if filters:
                params['filter'] = ','.join(f'{k}:{v}' for k, v in filters.items())

            resp = self.session.get(f'{self.BASE_URL}/works', params=params)
            resp.raise_for_status()
            data = resp.json()

            works = data.get('results', [])
            if not works:
                break

            results.extend(works)
            page += 1
            time.sleep(0.1)  # Polite rate limiting

        return results[:max_results]

    def get_work(self, openalex_id):
        """Get a single work by OpenAlex ID."""
        resp = self.session.get(f'{self.BASE_URL}/works/{openalex_id}')
        resp.raise_for_status()
        return resp.json()

# Usage
client = OpenAlexClient(email="researcher@university.edu")
papers = client.search_works(
    "transformer attention mechanism",
    filters={
        'publication_year': '2023-2024',
        'type': 'journal-article',
        'open_access.is_oa': 'true'
    },
    max_results=200
)

for paper in papers[:5]:
    print(f"- {paper['title']} ({paper['publication_year']})")
    print(f"  DOI: {paper['doi']}")
    print(f"  Citations: {paper['cited_by_count']}")
```

### Example: PubMed Entrez API

```python
from Bio import Entrez

Entrez.email = "researcher@university.edu"
Entrez.api_key = os.environ.get("NCBI_API_KEY")  # optional

def search_pubmed(query, max_results=100):
    """Search PubMed and retrieve article details."""
    # Search
    handle = Entrez.esearch(db="pubmed", term=query,
                            retmax=max_results, sort="relevance")
    search_results = Entrez.read(handle)
    id_list = search_results["IdList"]

    if not id_list:
        return []

    # Fetch details
    handle = Entrez.efetch(db="pubmed", id=id_list,
                           rettype="xml", retmode="xml")
    records = Entrez.read(handle)

    articles = []
    for article in records['PubmedArticle']:
        medline = article['MedlineCitation']
        art_info = medline['Article']
        articles.append({
            'pmid': str(medline['PMID']),
            'title': art_info.get('ArticleTitle', ''),
            'abstract': art_info.get('Abstract', {}).get(
                'AbstractText', [''])[0] if 'Abstract' in art_info else '',
            'journal': art_info['Journal']['Title'],
            'year': art_info['Journal']['JournalIssue'].get(
                'PubDate', {}).get('Year', ''),
        })

    return articles
```

## Web Scraping Fundamentals

When no API exists, scraping becomes necessary. Always check for an API first.

### Tools Comparison

| Tool | Type | JavaScript Support | Speed | Learning Curve |
|------|------|-------------------|-------|---------------|
| requests + BeautifulSoup | HTTP + parsing | No | Fast | Low |
| Scrapy | Framework | No (without middleware) | Very fast | Medium |
| Selenium | Browser automation | Yes | Slow | Medium |
| Playwright | Browser automation | Yes | Medium | Medium |
| httpx | Async HTTP | No | Very fast | Low |

### Basic Scraping with BeautifulSoup

```python
import requests
from bs4 import BeautifulSoup
import time

def scrape_conference_proceedings(url, delay=2.0):
    """Scrape paper titles and links from a conference page."""
    headers = {
        'User-Agent': 'ResearchBot/1.0 (Academic research; contact@university.edu)'
    }

    response = requests.get(url, headers=headers, timeout=30)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, 'html.parser')

    papers = []
    for item in soup.select('.paper-item, .proceeding-entry'):
        title_el = item.select_one('.title, h3, h4')
        link_el = item.select_one('a[href]')
        authors_el = item.select_one('.authors, .author-list')

        if title_el:
            papers.append({
                'title': title_el.get_text(strip=True),
                'url': link_el['href'] if link_el else None,
                'authors': authors_el.get_text(strip=True) if authors_el else '',
            })

    time.sleep(delay)  # Respect the server
    return papers
```

### Handling JavaScript-Rendered Pages

```python
from playwright.sync_api import sync_playwright

def scrape_dynamic_page(url):
    """Scrape a JavaScript-rendered page using Playwright."""
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        page.goto(url, wait_until='networkidle')

        # Wait for content to load
        page.wait_for_selector('.results-container', timeout=10000)

        # Extract data
        items = page.query_selector_all('.result-item')
        results = []
        for item in items:
            title = item.query_selector('.title')
            results.append({
                'title': title.inner_text() if title else '',
            })

        browser.close()
        return results
```

## Ethical Guidelines

### The Researcher's Scraping Checklist

1. **Check for an API first.** Most academic platforms have one.
2. **Read robots.txt.** `https://example.com/robots.txt` specifies what is allowed.
3. **Review Terms of Service.** Some sites explicitly prohibit scraping.
4. **Rate limit aggressively.** 1 request per 2-5 seconds minimum. Never parallelize without permission.
5. **Identify yourself.** Include your email and institution in the User-Agent header.
6. **Minimize data collection.** Only collect what your research question requires.
7. **Consider IRB requirements.** If collecting data about identifiable humans, consult your IRB.
8. **Store data securely.** Follow your institution's data management policies.
9. **Cite your data sources.** Acknowledge where the data came from in your publications.
10. **Check copyright.** Scraping publicly visible data does not mean you can redistribute it.

### robots.txt Parsing

```python
from urllib.robotparser import RobotFileParser

def can_scrape(url, user_agent='*'):
    """Check if scraping a URL is allowed by robots.txt."""
    from urllib.parse import urlparse
    parsed = urlparse(url)
    robots_url = f"{parsed.scheme}://{parsed.netloc}/robots.txt"

    rp = RobotFileParser()
    rp.set_url(robots_url)
    rp.read()

    allowed = rp.can_fetch(user_agent, url)
    crawl_delay = rp.crawl_delay(user_agent)

    return {
        'allowed': allowed,
        'crawl_delay': crawl_delay or 1.0,
    }
```

## Data Storage and Export

### Saving Results Reliably

```python
import json
import csv
from pathlib import Path
from datetime import datetime

class DataCollector:
    def __init__(self, output_dir='collected_data'):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')

    def save_json(self, data, filename):
        path = self.output_dir / f'{filename}_{self.timestamp}.json'
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"Saved {len(data)} records to {path}")

    def save_csv(self, data, filename, fieldnames=None):
        if not data:
            return
        if fieldnames is None:
            fieldnames = list(data[0].keys())

        path = self.output_dir / f'{filename}_{self.timestamp}.csv'
        with open(path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames,
                                     extrasaction='ignore')
            writer.writeheader()
            writer.writerows(data)
        print(f"Saved {len(data)} records to {path}")

    def save_checkpoint(self, data, filename):
        """Save intermediate results for resumable collection."""
        path = self.output_dir / f'{filename}_checkpoint.json'
        with open(path, 'w', encoding='utf-8') as f:
            json.dump({
                'timestamp': self.timestamp,
                'n_records': len(data),
                'data': data,
            }, f, indent=2, ensure_ascii=False)
```

## Best Practices

- **Always prefer APIs over scraping.** APIs are more reliable, structured, and legally clear.
- **Implement exponential backoff.** If a request fails, wait 1s, then 2s, then 4s before retrying.
- **Save checkpoints.** For large collections, save progress incrementally so you can resume after interruptions.
- **Log everything.** Record which URLs were accessed, when, and what was returned for reproducibility.
- **Test on a small sample first.** Verify your parsing logic on 10 records before running on 10,000.
- **Respect rate limits.** Getting blocked hurts everyone -- other researchers included.
- **Document your collection methodology.** Your paper's Methods section should describe how data was collected, when, and what filters were applied.

## References

- [OpenAlex API Documentation](https://docs.openalex.org/) -- Open bibliographic data API
- [CrossRef API](https://api.crossref.org/) -- DOI resolution and metadata
- [BeautifulSoup Documentation](https://www.crummy.com/software/BeautifulSoup/bs4/doc/) -- HTML parsing
- [Scrapy Documentation](https://docs.scrapy.org/) -- Web scraping framework
- [Playwright Documentation](https://playwright.dev/python/) -- Browser automation
- [Web Scraping Ethics](https://towardsdatascience.com/ethics-in-web-scraping-b96b18136f01) -- Ethical considerations
