---
name: open-library-api
description: "Search and access book metadata via the Open Library API"
metadata:
  openclaw:
    emoji: "📕"
    category: "literature"
    subcategory: "search"
    keywords: ["Open Library", "book search", "ISBN lookup", "Internet Archive", "book metadata", "digital library"]
    source: "https://openlibrary.org/"
---

# Open Library API

## Overview

Open Library (by the Internet Archive) catalogs every book ever published — 40M+ editions, 20M+ unique works. The API provides book search, ISBN/OCLC lookup, cover images, and reading access for 2M+ borrowable ebooks. Particularly useful for monograph discovery, edition tracking, and bibliographic verification. Free, no authentication required.

## API Endpoints

### Search Books

```bash
# Full-text search
curl "https://openlibrary.org/search.json?q=machine+learning&limit=20"

# Search by title
curl "https://openlibrary.org/search.json?title=deep+learning&limit=10"

# Search by author
curl "https://openlibrary.org/search.json?author=goodfellow&title=deep+learning"

# Filter by subject
curl "https://openlibrary.org/search.json?q=statistics&subject=data+analysis"

# Filter by publication year
curl "https://openlibrary.org/search.json?q=artificial+intelligence&first_publish_year=2020"

# Sort by edition count
curl "https://openlibrary.org/search.json?q=calculus&sort=editions"
```

### Book Details

```bash
# Get work (canonical book entity)
curl "https://openlibrary.org/works/OL45804W.json"

# Get edition
curl "https://openlibrary.org/books/OL7353617M.json"

# Get by ISBN
curl "https://openlibrary.org/isbn/9780262035613.json"

# Bibliographic data via Books API
curl "https://openlibrary.org/api/books?bibkeys=ISBN:9780262035613&format=json&jscmd=data"
```

### Cover Images

```bash
# By ISBN (S/M/L sizes)
https://covers.openlibrary.org/b/isbn/9780262035613-M.jpg

# By OLID
https://covers.openlibrary.org/b/olid/OL7353617M-L.jpg
```

### Author Data

```bash
# Get author
curl "https://openlibrary.org/authors/OL34184A.json"

# Search authors
curl "https://openlibrary.org/search/authors.json?q=hinton"

# Author's works
curl "https://openlibrary.org/authors/OL34184A/works.json?limit=20"
```

### Search Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `q` | General search | `q=neural+networks` |
| `title` | Title search | `title=deep+learning` |
| `author` | Author search | `author=bengio` |
| `subject` | Subject filter | `subject=computer+science` |
| `isbn` | ISBN lookup | `isbn=9780262035613` |
| `first_publish_year` | Publication year | `first_publish_year=2020` |
| `limit` | Results (max 100) | `limit=50` |
| `offset` | Pagination | `offset=50` |
| `sort` | Sort order | `new`, `editions`, `old` |
| `fields` | Return fields | `key,title,author_name` |

## Response Structure (Search)

```json
{
  "numFound": 1250,
  "docs": [
    {
      "key": "/works/OL45804W",
      "title": "Deep Learning",
      "author_name": ["Ian Goodfellow", "Yoshua Bengio", "Aaron Courville"],
      "first_publish_year": 2016,
      "isbn": ["9780262035613"],
      "publisher": ["MIT Press"],
      "subject": ["Machine learning", "Neural networks"],
      "edition_count": 8,
      "cover_i": 8739161,
      "ebook_access": "borrowable"
    }
  ]
}
```

## Python Usage

```python
import requests

BASE_URL = "https://openlibrary.org"


def search_books(query: str, limit: int = 20,
                 subject: str = None) -> list:
    """Search Open Library for books."""
    params = {"q": query, "limit": limit}
    if subject:
        params["subject"] = subject

    resp = requests.get(f"{BASE_URL}/search.json", params=params)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for doc in data.get("docs", []):
        results.append({
            "key": doc.get("key"),
            "title": doc.get("title"),
            "authors": doc.get("author_name", []),
            "year": doc.get("first_publish_year"),
            "publisher": doc.get("publisher", [None])[0],
            "isbn": doc.get("isbn", [None])[0],
            "editions": doc.get("edition_count", 0),
            "subjects": doc.get("subject", [])[:5],
            "ebook": doc.get("ebook_access"),
        })
    return results


def get_by_isbn(isbn: str) -> dict:
    """Look up a book by ISBN."""
    resp = requests.get(
        f"{BASE_URL}/api/books",
        params={
            "bibkeys": f"ISBN:{isbn}",
            "format": "json",
            "jscmd": "data",
        },
    )
    resp.raise_for_status()
    data = resp.json()
    return data.get(f"ISBN:{isbn}", {})


def get_author_works(author_key: str, limit: int = 20) -> list:
    """Get works by an author."""
    resp = requests.get(
        f"{BASE_URL}/authors/{author_key}/works.json",
        params={"limit": limit},
    )
    resp.raise_for_status()
    return resp.json().get("entries", [])


# Example: search CS textbooks
books = search_books("algorithms data structures",
                     subject="computer science")
for b in books[:5]:
    print(f"[{b['year']}] {b['title']} — {', '.join(b['authors'][:2])}")
    print(f"  Publisher: {b['publisher']} | Editions: {b['editions']}")

# Example: ISBN lookup
info = get_by_isbn("9780262035613")
print(f"Title: {info.get('title')}")
print(f"URL: {info.get('url')}")
```

## References

- [Open Library](https://openlibrary.org/)
- [Open Library API](https://openlibrary.org/developers/api)
- [Open Library Data Dumps](https://openlibrary.org/developers/dumps)
