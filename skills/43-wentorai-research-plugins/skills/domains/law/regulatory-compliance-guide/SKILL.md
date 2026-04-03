---
name: regulatory-compliance-guide
description: "Regulatory text mining, compliance research, and policy analysis tools"
metadata:
  openclaw:
    emoji: "📜"
    category: "domains"
    subcategory: "law"
    keywords: ["regulation", "compliance", "policy-analysis", "text-mining", "federal-register", "rulemaking"]
    source: "wentor"
---

# Regulatory Compliance Guide

A skill for mining regulatory texts, tracking regulatory changes, and conducting compliance research. Covers accessing regulatory databases, parsing regulatory language, change detection in regulations, compliance gap analysis, and computational policy analysis.

## Regulatory Data Sources

### US Federal Regulatory Data

| Source | Content | Format | Access |
|--------|---------|--------|--------|
| Federal Register API | Proposed and final rules | JSON API | Free (federalregister.gov) |
| eCFR (Electronic CFR) | Current Code of Federal Regulations | XML + API | Free (ecfr.gov) |
| Regulations.gov | Public comments on rulemakings | JSON API | Free |
| Congress.gov | Bills and legislative history | API + bulk | Free |
| SEC EDGAR | Securities filings and no-action letters | Full-text search + API | Free |

### Accessing Federal Register Data

```python
import requests
from datetime import date, timedelta

class FederalRegisterClient:
    """Client for the Federal Register API."""

    BASE_URL = "https://www.federalregister.gov/api/v1"

    def search_rules(self, query: str, agency: str = None,
                     date_from: str = None, per_page: int = 20) -> dict:
        """
        Search for rules and proposed rules in the Federal Register.
        """
        params = {
            "conditions[term]": query,
            "conditions[type][]": ["RULE", "PRORULE"],
            "per_page": per_page,
            "order": "newest",
        }
        if agency:
            params["conditions[agencies][]"] = agency
        if date_from:
            params["conditions[publication_date][gte]"] = date_from

        resp = requests.get(f"{self.BASE_URL}/documents", params=params)
        data = resp.json()
        return {
            "count": data.get("count", 0),
            "results": [
                {
                    "title": r["title"],
                    "document_number": r["document_number"],
                    "publication_date": r["publication_date"],
                    "agency_names": r.get("agency_names", []),
                    "type": r["type"],
                    "abstract": r.get("abstract", ""),
                    "html_url": r["html_url"],
                }
                for r in data.get("results", [])
            ],
        }

    def get_document(self, document_number: str) -> dict:
        """Retrieve full document details by document number."""
        resp = requests.get(
            f"{self.BASE_URL}/documents/{document_number}.json"
        )
        return resp.json()
```

## Regulatory Text Parsing

### Identifying Regulatory Obligations

Regulatory language follows predictable patterns that indicate obligation strength:

```python
import re
from enum import Enum

class ObligationLevel(Enum):
    MANDATORY = "mandatory"       # shall, must, required
    PROHIBITIVE = "prohibitive"   # shall not, must not, prohibited
    PERMISSIVE = "permissive"     # may, is permitted
    RECOMMENDED = "recommended"   # should, is recommended
    INFORMATIVE = "informative"   # for information, note

OBLIGATION_PATTERNS = {
    ObligationLevel.MANDATORY: [
        r"\bshall\b(?!\s+not)", r"\bmust\b(?!\s+not)",
        r"\bis required to\b", r"\bare required to\b",
    ],
    ObligationLevel.PROHIBITIVE: [
        r"\bshall not\b", r"\bmust not\b",
        r"\bis prohibited\b", r"\bmay not\b",
    ],
    ObligationLevel.PERMISSIVE: [
        r"\bmay\b(?!\s+not)", r"\bis permitted\b",
        r"\bis authorized\b",
    ],
    ObligationLevel.RECOMMENDED: [
        r"\bshould\b(?!\s+not)", r"\bis recommended\b",
        r"\bit is advisable\b",
    ],
}

def classify_obligations(text: str) -> list[dict]:
    """
    Extract and classify regulatory obligations from text.
    Returns sentences tagged with their obligation level.
    """
    sentences = re.split(r'(?<=[.!?])\s+', text)
    results = []
    for sent in sentences:
        level = ObligationLevel.INFORMATIVE
        for obl_level, patterns in OBLIGATION_PATTERNS.items():
            if any(re.search(p, sent, re.IGNORECASE) for p in patterns):
                level = obl_level
                break
        results.append({"sentence": sent.strip(), "obligation": level.value})
    return results
```

### CFR Section Parsing

```python
def parse_cfr_section(xml_text: str) -> dict:
    """
    Parse an eCFR XML section into structured components.
    Extracts the section number, heading, paragraphs, and cross-references.
    """
    root = ET.fromstring(xml_text)
    section = {
        "number": root.findtext(".//SECTNO", ""),
        "heading": root.findtext(".//SUBJECT", ""),
        "paragraphs": [],
        "cross_references": [],
    }

    for para in root.iter("P"):
        text = "".join(para.itertext()).strip()
        if text:
            section["paragraphs"].append(text)
            # Extract cross-references to other CFR sections
            xrefs = re.findall(r"\d+\s+CFR\s+[\d.]+(?:\([a-z]\))?", text)
            section["cross_references"].extend(xrefs)

    return section
```

## Regulatory Change Detection

### Tracking Amendments Over Time

```python
from difflib import SequenceMatcher, unified_diff

def compare_regulation_versions(old_text: str, new_text: str,
                                  section_id: str) -> dict:
    """
    Compare two versions of a regulation section to identify changes.
    Returns a structured diff with change classification.
    """
    old_lines = old_text.splitlines(keepends=True)
    new_lines = new_text.splitlines(keepends=True)

    diff = list(unified_diff(old_lines, new_lines,
                              fromfile=f"{section_id} (old)",
                              tofile=f"{section_id} (new)"))

    additions = sum(1 for l in diff if l.startswith("+") and not l.startswith("+++"))
    deletions = sum(1 for l in diff if l.startswith("-") and not l.startswith("---"))

    similarity = SequenceMatcher(None, old_text, new_text).ratio()

    return {
        "section": section_id,
        "similarity": round(similarity, 4),
        "lines_added": additions,
        "lines_removed": deletions,
        "change_magnitude": "major" if similarity < 0.8 else
                           "minor" if similarity < 0.95 else "trivial",
        "diff": "".join(diff),
    }
```

## Compliance Gap Analysis

### Mapping Requirements to Controls

```python
def compliance_gap_analysis(requirements: list[dict],
                             controls: list[dict]) -> pd.DataFrame:
    """
    Map regulatory requirements to organizational controls.
    Identify gaps where requirements lack corresponding controls.

    requirements: [{id, text, obligation_level, cfr_section}]
    controls: [{id, description, implemented, evidence}]
    """
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.metrics.pairwise import cosine_similarity

    req_texts = [r["text"] for r in requirements]
    ctrl_texts = [c["description"] for c in controls]

    vectorizer = TfidfVectorizer(stop_words="english", max_features=5000)
    all_texts = req_texts + ctrl_texts
    tfidf = vectorizer.fit_transform(all_texts)

    req_vecs = tfidf[:len(req_texts)]
    ctrl_vecs = tfidf[len(req_texts):]

    similarity_matrix = cosine_similarity(req_vecs, ctrl_vecs)

    gaps = []
    for i, req in enumerate(requirements):
        best_match_idx = similarity_matrix[i].argmax()
        best_score = similarity_matrix[i][best_match_idx]
        matched_ctrl = controls[best_match_idx] if best_score > 0.3 else None

        gaps.append({
            "requirement_id": req["id"],
            "cfr_section": req["cfr_section"],
            "obligation": req["obligation_level"],
            "matched_control": matched_ctrl["id"] if matched_ctrl else "NONE",
            "match_score": round(best_score, 3),
            "status": "covered" if matched_ctrl and matched_ctrl["implemented"]
                      else "gap" if not matched_ctrl
                      else "planned",
        })

    return pd.DataFrame(gaps)
```

## Regulatory Domains

Key regulated sectors with their primary frameworks:

| Sector | Primary Regulator | Key Regulations |
|--------|------------------|----------------|
| Financial services | SEC, CFTC, FINRA | Dodd-Frank, SOX, MiFID II |
| Healthcare | FDA, HHS | HIPAA, 21 CFR Parts 210-211 |
| Environment | EPA | Clean Air Act, RCRA, CERCLA |
| Data privacy | FTC, state AGs | CCPA, GDPR, COPPA |
| Telecommunications | FCC | Communications Act, net neutrality rules |
| Energy | FERC, NRC | Federal Power Act, 10 CFR 50 |

## Tools and Resources

- **RegInfo.gov**: Unified Agenda of regulatory actions
- **Regulations.gov API**: Public comments on proposed rules
- **GovInfo.gov**: Official publications of all branches of government
- **LexisNexis / Westlaw**: Commercial legal research platforms
- **RegTech tools**: Ascent, Compliance.ai, Clausematch
- **spaCy + custom pipelines**: NLP for regulatory text extraction
