---
name: zotero-scholar-guide
description: "Save papers with metadata to Zotero via its API programmatically"
metadata:
  openclaw:
    emoji: "📚"
    category: "writing"
    subcategory: "citation"
    keywords: ["zotero", "reference manager", "citation management", "API", "metadata", "bibliography", "paper organization"]
    source: "https://github.com/zotero/zotero"
---

# Zotero Scholar Guide

## Overview

Zotero is the most widely used open-source reference manager in academia, offering a powerful combination of local storage, cloud sync, browser integration, and a comprehensive API. While most researchers use Zotero through its desktop application and browser connector, the Zotero API enables programmatic access that is essential for automated research workflows—saving papers from scripts, batch-importing search results, organizing libraries algorithmically, and integrating reference management into custom research pipelines.

This skill covers using the Zotero Web API to create, read, update, and organize library items programmatically. It is designed for researchers who want to automate parts of their reference management workflow: importing papers from arXiv or OpenAlex searches directly into Zotero, auto-tagging papers based on content analysis, organizing collections programmatically, and exporting citations in various formats.

The skill complements the existing `zotero-api` skill by focusing specifically on practical scholar workflows—the common patterns a researcher uses when integrating Zotero into their daily literature management.

## Authentication and Setup

### Obtaining API Credentials

1. Log in to your Zotero account at https://www.zotero.org
2. Navigate to Settings > Feeds/API (https://www.zotero.org/settings/keys)
3. Click "Create new private key"
4. Set permissions:
   - Personal Library: Read/Write access
   - Default Group Permissions: Read/Write (if you use group libraries)
   - Allow access to notes (recommended)
5. Save the API key securely

```bash
# Store your credentials as environment variables
export ZOTERO_API_KEY=your-zotero-key   # from zotero.org/settings/keys
export ZOTERO_USER_ID="your_user_id"  # Found on the API keys page
```

### Testing Your Connection

```bash
# Verify API access
curl -H "Zotero-API-Key: $ZOTERO_API_KEY" \
  "https://api.zotero.org/users/$ZOTERO_USER_ID/items?limit=5&format=json" \
  | python3 -m json.tool | head -20
```

If you see your recent library items, authentication is working correctly.

## Saving Papers to Zotero

### Adding a Single Paper by DOI

The simplest way to add a well-cataloged paper is by DOI. Zotero can resolve DOI metadata automatically:

```python
import requests
import os

API_KEY = os.environ["ZOTERO_API_KEY"]
USER_ID = os.environ["ZOTERO_USER_ID"]
BASE_URL = f"https://api.zotero.org/users/{USER_ID}"
HEADERS = {
    "Zotero-API-Key": API_KEY,
    "Content-Type": "application/json"
}

def add_paper_by_doi(doi):
    """Resolve DOI metadata and add to Zotero."""
    # Step 1: Get metadata from DOI via Crossref
    cr_resp = requests.get(
        f"https://api.crossref.org/works/{doi}",
        headers={"User-Agent": "ResearchClaw/1.0 (mailto:you@example.edu)"}
    )
    cr_data = cr_resp.json()["message"]

    # Step 2: Build Zotero item
    item = {
        "itemType": "journalArticle",
        "title": cr_data.get("title", [""])[0],
        "creators": [
            {"creatorType": "author", "firstName": a.get("given", ""),
             "lastName": a.get("family", "")}
            for a in cr_data.get("author", [])
        ],
        "abstractNote": cr_data.get("abstract", ""),
        "DOI": doi,
        "url": f"https://doi.org/{doi}",
        "date": cr_data.get("published-print", {}).get("date-parts", [[""]])[0][0],
        "publicationTitle": cr_data.get("container-title", [""])[0],
        "volume": cr_data.get("volume", ""),
        "issue": cr_data.get("issue", ""),
        "pages": cr_data.get("page", ""),
        "tags": [{"tag": "auto-imported"}]
    }

    # Step 3: POST to Zotero
    resp = requests.post(
        f"{BASE_URL}/items",
        headers=HEADERS,
        json=[item]
    )

    if resp.status_code == 200:
        print(f"Added: {item['title']}")
        return resp.json()
    else:
        print(f"Error: {resp.status_code} - {resp.text}")
        return None

# Usage
add_paper_by_doi("10.1038/s41586-023-06747-5")
```

### Adding arXiv Papers

arXiv papers often lack DOIs. Use the arXiv API to fetch metadata:

```python
import feedparser

def add_arxiv_paper(arxiv_id):
    """Fetch arXiv metadata and add to Zotero."""
    feed = feedparser.parse(
        f"http://export.arxiv.org/api/query?id_list={arxiv_id}"
    )
    entry = feed.entries[0]

    item = {
        "itemType": "preprint",
        "title": entry.title.replace("\n", " "),
        "creators": [
            {"creatorType": "author",
             "firstName": name.rsplit(" ", 1)[0] if " " in name else "",
             "lastName": name.rsplit(" ", 1)[-1]}
            for name in [a.name for a in entry.authors]
        ],
        "abstractNote": entry.summary.replace("\n", " "),
        "url": entry.link,
        "date": entry.published[:10],
        "repository": "arXiv",
        "archiveID": f"arXiv:{arxiv_id}",
        "tags": [
            {"tag": "arxiv"},
            {"tag": entry.arxiv_primary_category["term"]}
        ]
    }

    resp = requests.post(
        f"{BASE_URL}/items",
        headers=HEADERS,
        json=[item]
    )
    if resp.status_code == 200:
        print(f"Added arXiv paper: {item['title'][:80]}")
    return resp

# Usage
add_arxiv_paper("2301.07041")
```

### Batch Import from Search Results

When you run a literature search and want to import all results into Zotero:

```python
def batch_import(papers, collection_key=None):
    """Import a list of paper dicts into Zotero.
    Zotero API accepts up to 50 items per request.
    """
    batch_size = 50
    for i in range(0, len(papers), batch_size):
        batch = papers[i:i + batch_size]
        items = [build_zotero_item(p) for p in batch]

        # Add to specific collection if provided
        if collection_key:
            for item in items:
                item["collections"] = [collection_key]

        resp = requests.post(
            f"{BASE_URL}/items",
            headers=HEADERS,
            json=items
        )
        print(f"Batch {i//batch_size + 1}: {resp.status_code}")
```

## Organizing with Collections and Tags

### Creating Collections Programmatically

```python
def create_collection(name, parent_key=None):
    """Create a new Zotero collection."""
    collection = {
        "name": name,
        "parentCollection": parent_key or False
    }
    resp = requests.post(
        f"{BASE_URL}/collections",
        headers=HEADERS,
        json=[collection]
    )
    if resp.status_code == 200:
        key = resp.json()["successful"]["0"]["key"]
        print(f"Created collection '{name}' with key: {key}")
        return key
    return None

# Create a hierarchical structure
lit_review = create_collection("Literature Review 2026")
methods = create_collection("Methods Papers", parent_key=lit_review)
results = create_collection("Results Papers", parent_key=lit_review)
```

### Auto-Tagging Based on Content

```python
def auto_tag_items(keyword_map):
    """Tag existing items based on abstract content.
    keyword_map: dict of {tag: [keywords]}
    """
    # Fetch all items
    items = requests.get(
        f"{BASE_URL}/items?limit=100&format=json",
        headers=HEADERS
    ).json()

    for item in items:
        abstract = item["data"].get("abstractNote", "").lower()
        new_tags = list(item["data"].get("tags", []))
        existing_tag_names = {t["tag"] for t in new_tags}

        for tag, keywords in keyword_map.items():
            if tag not in existing_tag_names:
                if any(kw.lower() in abstract for kw in keywords):
                    new_tags.append({"tag": tag})

        if len(new_tags) > len(item["data"].get("tags", [])):
            requests.patch(
                f"{BASE_URL}/items/{item['key']}",
                headers={**HEADERS, "If-Unmodified-Since-Version": str(item["version"])},
                json={"tags": new_tags}
            )

# Usage
auto_tag_items({
    "deep-learning": ["deep learning", "neural network", "CNN", "transformer"],
    "nlp": ["natural language", "text classification", "language model"],
    "computer-vision": ["image classification", "object detection", "segmentation"]
})
```

## Exporting Citations

### Export in Various Formats

```bash
# Export entire library as BibTeX
curl -H "Zotero-API-Key: $ZOTERO_API_KEY" \
  "https://api.zotero.org/users/$ZOTERO_USER_ID/items?format=bibtex&limit=100" \
  > library.bib

# Export a specific collection as CSL-JSON
curl -H "Zotero-API-Key: $ZOTERO_API_KEY" \
  "https://api.zotero.org/users/$ZOTERO_USER_ID/collections/ABCD1234/items?format=csljson" \
  > collection.json

# Export as RIS (for import into other tools)
curl -H "Zotero-API-Key: $ZOTERO_API_KEY" \
  "https://api.zotero.org/users/$ZOTERO_USER_ID/items?format=ris&limit=100" \
  > library.ris
```

### Generating a Bibliography

```bash
# Generate formatted bibliography in APA style
curl -H "Zotero-API-Key: $ZOTERO_API_KEY" \
  -H "Content-Type: application/json" \
  "https://api.zotero.org/users/$ZOTERO_USER_ID/items?format=bib&style=apa&limit=50"
```

## References

- Zotero Web API v3 documentation: https://www.zotero.org/support/dev/web_api/v3/start
- Zotero source code: https://github.com/zotero/zotero
- pyzotero (Python library): https://github.com/urschrei/pyzotero
- Crossref API: https://api.crossref.org
- Zotero Better BibTeX plugin: https://retorque.re/zotero-better-bibtex/
