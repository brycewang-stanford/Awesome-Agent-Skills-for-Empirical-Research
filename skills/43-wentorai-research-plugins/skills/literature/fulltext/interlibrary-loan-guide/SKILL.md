---
name: interlibrary-loan-guide
description: "Access papers through interlibrary loan and document delivery services"
metadata:
  openclaw:
    emoji: "📚"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["interlibrary loan", "ILL", "document delivery", "full text access", "library services"]
    source: "wentor-research-plugins"
---

# Interlibrary Loan Guide

A skill for accessing research papers and books through interlibrary loan (ILL) and document delivery services when your institution does not have a subscription. Covers ILL workflows, alternative free access methods, and strategies for rapid document retrieval.

## Understanding Interlibrary Loan

### What Is ILL?

Interlibrary loan is a service where your library borrows materials from another library on your behalf. Most academic libraries offer ILL free of charge to their students, faculty, and staff. Turnaround time is typically 1-7 business days for articles and 1-3 weeks for books.

### Types of Requests

```
Article/Chapter Request:
  - You receive a digital scan (PDF) of the article
  - Usually delivered to your email or ILL portal
  - Turnaround: 1-5 business days
  - Typically free

Book Loan:
  - Physical book is shipped from another library
  - Must be returned by a due date (usually 3-6 weeks)
  - Turnaround: 5-15 business days
  - May have a small shipping fee

Thesis/Dissertation:
  - Some are available digitally via ProQuest or institutional repositories
  - Others must be requested as physical loans or scans
  - Turnaround varies widely
```

## Step-by-Step ILL Process

### Submitting a Request

```python
def prepare_ill_request(item_type: str, metadata: dict) -> dict:
    """
    Prepare an interlibrary loan request with required information.

    Args:
        item_type: 'article', 'book', or 'chapter'
        metadata: Bibliographic information about the item
    """
    required_fields = {
        "article": [
            "article_title", "journal_title", "author",
            "year", "volume", "issue", "pages", "doi"
        ],
        "book": [
            "title", "author", "publisher", "year",
            "isbn", "edition"
        ],
        "chapter": [
            "chapter_title", "book_title", "author",
            "editor", "publisher", "year", "pages", "isbn"
        ]
    }

    request = {"type": item_type}
    fields = required_fields.get(item_type, [])

    for field in fields:
        value = metadata.get(field, "")
        request[field] = value
        if not value:
            request.setdefault("missing_fields", []).append(field)

    if request.get("missing_fields"):
        request["note"] = (
            "Provide as many fields as possible. "
            "DOI or PMID alone is often sufficient for articles."
        )

    return request
```

### Typical Workflow

```
1. Verify your library does not have access
   - Check library catalog and database A-Z list
   - Try off-campus access via VPN or proxy

2. Gather bibliographic details
   - Title, author, journal/book, year, DOI or ISBN
   - The more detail you provide, the faster the request is filled

3. Submit request through your library's ILL system
   - Common systems: ILLiad, Tipasa, OCLC WorldShare
   - Usually accessible from your library's website under "Interlibrary Loan"

4. Wait for delivery
   - Articles: PDF delivered to your email or ILL portal
   - Books: Pick up at the library circulation desk

5. Return books by the due date
```

## Free Alternatives Before Requesting ILL

### Check These Sources First

```
1. Open Access repositories:
   - PubMed Central (PMC) for NIH-funded biomedical research
   - arXiv, bioRxiv, medRxiv for preprints
   - SSRN for social science and economics working papers
   - Institutional repositories (search via BASE or OpenDOAR)

2. Author contact:
   - Email the corresponding author requesting a copy
   - Check the author's personal or lab website for PDFs
   - ResearchGate: request full text from the author

3. Legal free access tools:
   - Unpaywall browser extension (finds legal OA copies)
   - CORE.ac.uk (aggregates open access research)
   - Google Scholar: click "PDF" links on the right side

4. Your institution:
   - Try different databases (your library may have access via
     a different provider)
   - Ask a librarian: they know about access paths you may miss
```

## Document Delivery Services

### Commercial Alternatives

When ILL is too slow or unavailable, commercial document delivery services can provide articles within hours:

| Service | Turnaround | Typical Cost |
|---------|-----------|-------------|
| British Library Document Supply | 1-2 days | Varies by country |
| Reprints Desk | Same day to 48 hours | Per-article fee |
| Copyright Clearance Center (Get It Now) | Minutes to hours | Per-article fee |
| DeepDyve | Instant (rental model) | Monthly subscription |

### When to Use Document Delivery vs. ILL

- Use ILL for non-urgent requests (1+ week lead time is acceptable)
- Use document delivery when you need the article within 24 hours
- Use document delivery when your institution has no ILL service (e.g., independent researchers)

## Tips for Efficient Access

- Keep a reference manager (Zotero, Mendeley) to avoid requesting the same paper twice
- Batch ILL requests: submit several at once during literature review phases
- Build relationships with your subject librarian -- they can often expedite requests or suggest alternative access routes
- For systematic reviews, inform your library early about the volume of ILL requests you will need
