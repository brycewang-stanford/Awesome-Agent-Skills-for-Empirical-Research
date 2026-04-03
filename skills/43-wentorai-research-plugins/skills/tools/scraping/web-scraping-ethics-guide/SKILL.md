---
name: web-scraping-ethics-guide
description: "Scrape web data ethically and legally for research purposes"
metadata:
  openclaw:
    emoji: "🌐"
    category: "tools"
    subcategory: "scraping"
    keywords: ["web scraping", "ethical scraping", "robots.txt", "rate limiting", "research data collection", "crawling"]
    source: "wentor-research-plugins"
---

# Ethical Web Scraping for Research

A skill for collecting web data ethically and legally for research purposes. Covers robots.txt compliance, rate limiting, legal frameworks, data privacy considerations, and practical scraping techniques that respect website operators and comply with institutional review requirements.

## Ethical Framework

### Principles of Ethical Scraping

```
1. Respect robots.txt and Terms of Service
   - Check robots.txt before scraping any site
   - Review the site's ToS for explicit prohibitions
   - When in doubt, contact the site operator

2. Minimize server impact
   - Use rate limiting (1-2 requests per second maximum)
   - Scrape during off-peak hours when possible
   - Cache responses to avoid redundant requests
   - Use conditional requests (If-Modified-Since headers)

3. Collect only what you need
   - Define your data requirements before scraping
   - Do not scrape personal data without ethical justification
   - Anonymize or pseudonymize personal information

4. Attribution and transparency
   - Set a descriptive User-Agent header with contact info
   - Be prepared to identify yourself if contacted
   - Credit data sources in publications

5. Institutional compliance
   - Check if your IRB/ethics board requires approval for web data
   - Follow your institution's acceptable use policy
   - Consider data protection regulations (GDPR, CCPA)
```

## Checking robots.txt

### Parsing Robots.txt

```python
import urllib.request
import urllib.robotparser


def check_robots_txt(base_url: str, target_path: str,
                     user_agent: str = "*") -> dict:
    """
    Check if a URL is allowed by robots.txt.

    Args:
        base_url: The website's base URL (e.g., 'https://example.com')
        target_path: The path you want to scrape (e.g., '/data/papers')
        user_agent: Your bot's user agent string
    """
    robots_url = f"{base_url}/robots.txt"

    rp = urllib.robotparser.RobotFileParser()
    rp.set_url(robots_url)

    try:
        rp.read()
    except Exception as e:
        return {
            "robots_txt_found": False,
            "error": str(e),
            "recommendation": "Proceed with caution; use conservative rate limiting"
        }

    full_url = f"{base_url}{target_path}"
    allowed = rp.can_fetch(user_agent, full_url)
    crawl_delay = rp.crawl_delay(user_agent)

    return {
        "robots_txt_found": True,
        "url_checked": full_url,
        "allowed": allowed,
        "crawl_delay": crawl_delay or "Not specified (use 1-2 seconds)",
        "recommendation": (
            "Proceed with specified crawl delay"
            if allowed
            else "Do NOT scrape this path -- it is disallowed"
        )
    }
```

## Rate-Limited Scraping

### Respectful Request Pattern

```python
import time
import urllib.request


def scrape_with_rate_limit(urls: list[str],
                            delay: float = 1.0,
                            user_agent: str = None) -> list[dict]:
    """
    Scrape a list of URLs with rate limiting and proper headers.

    Args:
        urls: List of URLs to fetch
        delay: Seconds to wait between requests
        user_agent: Custom user agent string
    """
    if user_agent is None:
        user_agent = (
            "ResearchBot/1.0 (Academic research; "
            "contact: researcher@university.edu)"
        )

    results = []

    for i, url in enumerate(urls):
        try:
            req = urllib.request.Request(url, headers={
                "User-Agent": user_agent,
                "Accept": "text/html",
            })

            response = urllib.request.urlopen(req, timeout=30)
            content = response.read().decode("utf-8", errors="replace")

            results.append({
                "url": url,
                "status": response.status,
                "content_length": len(content),
                "success": True
            })

        except Exception as e:
            results.append({
                "url": url,
                "error": str(e),
                "success": False
            })

        # Rate limiting
        if i < len(urls) - 1:
            time.sleep(delay)

    return results
```

## Legal Considerations

### Key Legal Frameworks

```
United States:
  - CFAA (Computer Fraud and Abuse Act): Unauthorized access is illegal
  - hiQ v. LinkedIn (2022): Scraping public data is generally permissible
  - Key question: Is the data publicly accessible without authentication?

European Union:
  - GDPR: Personal data requires legal basis for processing
  - Database Directive: Protects substantial investment in databases
  - Text and Data Mining exception (DSM Directive, Art. 3-4):
    Research organizations can mine lawfully accessible content

General guidance:
  - Public data is more defensible than data behind login walls
  - Scraping that circumvents technical measures is riskier
  - Academic fair use / research exceptions vary by jurisdiction
  - When in doubt, consult your institution's legal counsel
```

## Research-Specific Considerations

### IRB and Ethics Approval

```python
def assess_irb_requirements(data_type: str,
                             contains_pii: bool) -> dict:
    """
    Assess whether web scraping requires IRB review.

    Args:
        data_type: Type of data being collected
        contains_pii: Whether data includes personally identifiable information
    """
    if contains_pii:
        return {
            "irb_required": "Likely yes",
            "rationale": (
                "Data that identifies or can re-identify individuals "
                "generally requires ethics review, even if publicly posted."
            ),
            "steps": [
                "Submit IRB protocol describing data collection",
                "Justify why PII is necessary for the research",
                "Describe de-identification procedures",
                "Explain data storage and security measures",
                "Plan for data destruction after the study"
            ]
        }

    return {
        "irb_required": "Possibly exempt, but check with your IRB",
        "rationale": (
            "Non-human-subjects data (e.g., product prices, publication "
            "metadata) typically does not require IRB review, but policies "
            "vary by institution."
        ),
        "recommendation": "Submit an exemption request to be safe"
    }
```

## Best Practices Summary

### Scraping Checklist for Researchers

```
Before scraping:
  [ ] Check robots.txt
  [ ] Review Terms of Service
  [ ] Consider whether an API exists (prefer API over scraping)
  [ ] Assess IRB requirements
  [ ] Define minimal data needed

During scraping:
  [ ] Set descriptive User-Agent with contact email
  [ ] Implement rate limiting (min 1 second between requests)
  [ ] Handle errors gracefully (do not retry aggressively)
  [ ] Log all requests for reproducibility
  [ ] Cache responses to avoid re-fetching

After scraping:
  [ ] Anonymize personal data if present
  [ ] Store data securely
  [ ] Document the scraping methodology for your paper
  [ ] Credit the data source
  [ ] Consider whether the scraped data can be shared
      (check copyright and ToS)
```

Whenever a public API is available (e.g., Twitter/X API, Reddit API, CrossRef API), use the API instead of scraping HTML. APIs provide structured data, respect rate limits by design, and demonstrate good faith in your research methodology.
