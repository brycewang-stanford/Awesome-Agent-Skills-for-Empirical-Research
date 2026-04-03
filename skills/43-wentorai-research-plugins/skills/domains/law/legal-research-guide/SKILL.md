---
name: legal-research-guide
description: "Legal research methods, case law analysis, and compliance tools"
metadata:
  openclaw:
    emoji: "⚖️"
    category: "domains"
    subcategory: "law"
    keywords: ["law", "jurisprudence", "case law", "compliance analysis"]
    source: "wentor-research-plugins"
---

# Legal Research Guide

Conduct systematic legal research across jurisdictions, analyze case law, navigate statutory frameworks, and use computational legal tools for academic and practice-oriented research.

## Legal Research Frameworks

### IRAC Method

The standard analytical framework for legal reasoning:

| Step | Description | Example |
|------|-------------|---------|
| **Issue** | Identify the legal question | "Does web scraping of public data constitute a CFAA violation?" |
| **Rule** | State the applicable legal rule | "The CFAA prohibits accessing a computer 'without authorization' or 'exceeding authorized access'" |
| **Application** | Apply the rule to the facts | "In hiQ v. LinkedIn, the 9th Circuit held that scraping publicly available data does not violate the CFAA..." |
| **Conclusion** | State the legal conclusion | "Therefore, scraping publicly available academic data likely does not violate the CFAA, though terms-of-service issues remain." |

### CREAC Method (For Academic Legal Writing)

```
C - Conclusion (state your thesis)
R - Rule (present the legal rule with authority)
E - Explanation (analyze how courts have interpreted the rule)
A - Application (apply the rule to your specific scenario)
C - Conclusion (restate and refine conclusion)
```

## Legal Research Databases

### Primary Sources

| Database | Coverage | Cost | Best For |
|----------|----------|------|----------|
| Westlaw (Thomson Reuters) | US, UK, EU, international | Subscription | Comprehensive case law, KeyCite citator |
| LexisNexis | US, UK, international | Subscription | News integration, Shepard's citator |
| Google Scholar (Case Law) | US federal and state courts | Free | Quick case lookup, citation tracking |
| Casetext / CoCounsel | US courts | Subscription | AI-powered legal research |
| CourtListener | US federal courts | Free | PACER alternative, bulk data |
| EUR-Lex | EU law | Free | EU legislation, CJEU case law |
| BAILII | UK, Ireland | Free | UK case law and legislation |
| Justia | US law | Free | US case law, statutes, regulations |
| HeinOnline | Historical legal materials | Subscription | Law journals, treaties, legislative history |

### Secondary Sources

| Source | Content | Use |
|--------|---------|-----|
| Law reviews / journals | Scholarly analysis | Academic research, policy arguments |
| Restatements | ALI compilations of common law | Authoritative secondary source |
| Treatises | Comprehensive subject coverage | Deep dive into specific areas |
| Legal encyclopedias (AmJur, CJS) | Broad legal summaries | Starting point for unfamiliar areas |
| Practice guides | Practical how-to | Practitioner-oriented research |

## Citation Systems

### Bluebook (US Standard)

```
# Case citation
Marbury v. Madison, 5 U.S. (1 Cranch) 137 (1803).
Brown v. Board of Education, 347 U.S. 483, 495 (1954).

# Statute citation
42 U.S.C. Section 1983 (2018).
Cal. Civ. Code Section 1798.100 (West 2020).  # California statute

# Law review article
Jane Smith, The Future of AI Regulation, 120 Harv. L. Rev. 456 (2024).

# Book
Richard Posner, Economic Analysis of Law 25 (9th ed. 2014).

# Short form citations (after first full citation)
Brown, 347 U.S. at 495.
Smith, supra note 12, at 460.
Id. at 462.  # Same source as immediately preceding citation
```

### OSCOLA (UK/Oxford Standard)

```
# Case citation
Donoghue v Stevenson [1932] AC 562 (HL).
R v Brown [1994] 1 AC 212, 237 (HL).

# Statute citation
Human Rights Act 1998, s 3.
Data Protection Act 2018, s 170(1).

# Journal article
Jane Smith, 'The Future of AI Regulation' (2024) 120 Modern Law Review 456.

# Book
Richard Posner, Economic Analysis of Law (9th edn, Aspen 2014) 25.
```

## Computational Legal Research

### Case Law Analysis with Python

```python
import requests
import json

# Using the CourtListener API (free, open-source)
BASE_URL = "https://www.courtlistener.com/api/rest/v3"

def search_opinions(query, court="scotus", page_size=20):
    """Search case opinions via CourtListener API."""
    response = requests.get(
        f"{BASE_URL}/search/",
        params={
            "q": query,
            "type": "o",  # opinions
            "court": court,
            "page_size": page_size,
            "order_by": "score desc"
        },
        headers={"Authorization": "Token YOUR_API_TOKEN"}
    )
    results = response.json()
    for case in results.get("results", []):
        print(f"[{case.get('dateFiled', 'N/A')}] {case.get('caseName', 'N/A')}")
        print(f"  Court: {case.get('court', 'N/A')}")
        print(f"  Citation: {case.get('citation', ['N/A'])[0] if case.get('citation') else 'N/A'}")
        print(f"  URL: https://www.courtlistener.com{case.get('absolute_url', '')}")
    return results

# Search for AI-related Supreme Court cases
results = search_opinions("artificial intelligence", court="scotus")
```

### Citation Network Analysis

```python
import networkx as nx

def build_citation_network(seed_case_ids, depth=2):
    """Build a citation network starting from seed cases."""
    G = nx.DiGraph()
    visited = set()
    queue = [(cid, 0) for cid in seed_case_ids]

    while queue:
        case_id, level = queue.pop(0)
        if case_id in visited or level > depth:
            continue
        visited.add(case_id)

        # Get case metadata and citations
        resp = requests.get(f"{BASE_URL}/opinions/{case_id}/",
                           headers={"Authorization": "Token YOUR_API_TOKEN"})
        if resp.status_code != 200:
            continue

        case = resp.json()
        case_name = case.get("case_name", f"Case {case_id}")
        G.add_node(case_id, name=case_name, date=case.get("date_filed"))

        # Get citing opinions (who cites this case)
        for cited_id in case.get("opinions_cited", []):
            G.add_edge(case_id, cited_id)
            if level < depth:
                queue.append((cited_id, level + 1))

    return G

# Analyze: which cases are most cited (highest in-degree)?
# These are the most authoritative precedents
```

### Statutory Text Analysis

```python
# Analyzing legislative text complexity
import re
from textstat import textstat

def analyze_statute(text):
    """Compute readability metrics for statutory text."""
    return {
        "flesch_reading_ease": textstat.flesch_reading_ease(text),
        "flesch_kincaid_grade": textstat.flesch_kincaid_grade(text),
        "gunning_fog": textstat.gunning_fog(text),
        "word_count": textstat.lexicon_count(text),
        "sentence_count": textstat.sentence_count(text),
        "avg_sentence_length": textstat.avg_sentence_length(text),
        "defined_terms": len(re.findall(r'"[A-Z][^"]*"', text)),
        "cross_references": len(re.findall(r'[Ss]ection \d+', text))
    }

# Example: Analyze a section of the GDPR
gdpr_article_5 = """
Personal data shall be processed lawfully, fairly and in a transparent
manner in relation to the data subject; collected for specified, explicit
and legitimate purposes and not further processed in a manner that is
incompatible with those purposes; adequate, relevant and limited to what
is necessary in relation to the purposes for which they are processed.
"""
print(analyze_statute(gdpr_article_5))
```

## Research Areas in Law

| Area | Key Topics | Interdisciplinary Connections |
|------|-----------|------------------------------|
| **AI & Law** | Algorithmic fairness, liability for autonomous systems, AI regulation | CS, philosophy |
| **IP Law** | Patent, copyright, trade secret, open source licensing | Engineering, business |
| **Privacy Law** | GDPR, CCPA, surveillance, data protection | CS, political science |
| **Law & Economics** | Efficiency analysis of legal rules, behavioral law & economics | Economics |
| **Comparative Law** | Cross-jurisdictional analysis, legal transplants | Political science |
| **International Law** | Treaties, humanitarian law, trade law | International relations |
| **Environmental Law** | Climate litigation, ESG regulation, environmental justice | Environmental science |
| **Health Law** | Clinical trial regulation, health data, bioethics | Medicine, public health |

## Practical Research Workflow

1. **Frame the legal question** using IRAC or CREAC structure
2. **Search secondary sources** first (treatises, law reviews) for background
3. **Identify governing law** (federal vs. state, statutory vs. common law)
4. **Find controlling authority** (binding precedent in your jurisdiction)
5. **Shepardize / KeyCite** every case to ensure it is still good law
6. **Analyze and synthesize** cases by extracting rules, holdings, and reasoning
7. **Consider policy arguments** drawing on law and economics, empirical legal studies, or comparative law perspectives
8. **Update regularly** as law changes frequently (set up alerts on Westlaw/Lexis)

## Top Academic Venues

| Journal | Rank | Focus |
|---------|------|-------|
| Harvard Law Review | T1 | General |
| Yale Law Journal | T1 | General |
| Stanford Law Review | T1 | General, tech law |
| Columbia Law Review | T1 | General |
| Journal of Legal Studies | T1 | Law & economics |
| Journal of Empirical Legal Studies | T1 | Empirical methods |
| Computer Law & Security Review | Field | Technology law |
| Berkeley Technology Law Journal | Field | Tech, IP |
