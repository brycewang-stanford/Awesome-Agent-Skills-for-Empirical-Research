---
name: paper-reading-assistant
description: "AI-assisted paper reading, PDF Q&A, and summarization workflows"
metadata:
  openclaw:
    emoji: "📖"
    category: "research"
    subcategory: "paper-review"
    keywords: ["paper reading assistant", "PDF Q&A", "document understanding", "paper summarization"]
    source: "wentor-research-plugins"
---

# Paper Reading Assistant

Systematic workflows for reading, annotating, and extracting insights from academic papers, including AI-assisted summarization and critical analysis techniques.

## The Three-Pass Reading Method

Srinivasan Keshav's three-pass approach provides a structured way to read papers at increasing depth:

### Pass 1: Survey (5-10 minutes)

Read only:
1. Title, abstract, and keywords
2. Introduction (first and last paragraph only)
3. Section headings (all of them)
4. Conclusion
5. Glance at figures and tables (read captions)
6. Check the reference list for familiar papers

After Pass 1, you should know:
- **Category**: Is this an empirical study, theoretical contribution, system paper, survey?
- **Context**: What related work does it build on?
- **Correctness**: Do the assumptions and claims seem reasonable?
- **Contributions**: What are the main claimed contributions?
- **Clarity**: Is the paper well-written?

**Decision**: Stop here if the paper is not relevant, or continue to Pass 2.

### Pass 2: Comprehension (30-60 minutes)

Read the full paper, but skip proofs and complex derivations:
1. Examine figures and tables carefully
2. Mark unread references for later
3. Annotate key claims, methods, and results
4. Try to summarize each section in one sentence

After Pass 2, you should be able to:
- Summarize the paper's main contribution to someone else
- Identify the key evidence supporting the claims
- List the paper's strengths and weaknesses

### Pass 3: Recreation (1-4 hours)

For papers you need to deeply understand:
1. Try to mentally re-derive the key results
2. Challenge every assumption
3. Identify implicit assumptions not stated
4. Think about how you would improve the work
5. Compare the approach to alternatives

## Structured Note-Taking Template

Use a consistent template for every paper you read:

```markdown
# Paper Notes: [Short Title]

## Metadata
- **Title**: Full title
- **Authors**: First Author et al. (Year)
- **Venue**: Conference/Journal
- **DOI/URL**: link
- **Date read**: YYYY-MM-DD

## Summary (2-3 sentences)
What does this paper do, and what are the main findings?

## Problem
What problem does this paper address? Why is it important?

## Method
How do they approach the problem? Key technical details.

## Key Results
- Result 1: ...
- Result 2: ...
- Result 3: ...

## Strengths
- Strength 1: ...
- Strength 2: ...

## Weaknesses / Limitations
- Weakness 1: ...
- Weakness 2: ...

## Questions / Things I Don't Understand
- Question 1: ...

## Relevance to My Work
How does this connect to my research? What can I use?

## Key References to Follow Up
- [Author, Year] - Why it seems relevant
```

## AI-Assisted Paper Analysis

### Summarization Prompts

Use structured prompts to extract specific information from papers:

```python
# Prompt template for paper summarization
summarize_prompt = """Read the following academic paper and provide:

1. ONE-SENTENCE SUMMARY: The core contribution in a single sentence.

2. KEY FINDINGS (3-5 bullet points):
   - Finding 1 with specific numbers/results
   - Finding 2 ...

3. METHODOLOGY: Describe the approach in 2-3 sentences.

4. LIMITATIONS: List 2-3 limitations acknowledged or unacknowledged.

5. RELEVANCE: How does this relate to [your research topic]?

Paper text:
{paper_text}
"""

# Prompt for critical analysis
critique_prompt = """Analyze the following paper critically:

1. VALIDITY: Are the experimental design and statistical analyses sound?
   Identify any threats to internal/external validity.

2. NOVELTY: What is genuinely new? What is incremental?

3. REPRODUCIBILITY: Could you replicate this study from the description given?
   What information is missing?

4. ALTERNATIVE EXPLANATIONS: Are there alternative interpretations
   of the results that the authors do not consider?

5. FOLLOW-UP QUESTIONS: What would you want to investigate next?

Paper text:
{paper_text}
"""
```

### PDF Processing Pipeline

```python
import fitz  # PyMuPDF

def extract_paper_text(pdf_path):
    """Extract structured text from an academic paper PDF."""
    doc = fitz.open(pdf_path)
    sections = []
    current_section = {"heading": "Preamble", "text": ""}

    for page_num, page in enumerate(doc):
        blocks = page.get_text("dict")["blocks"]
        for block in blocks:
            if "lines" not in block:
                continue
            for line in block["lines"]:
                text = "".join(span["text"] for span in line["spans"])
                font_size = max(span["size"] for span in line["spans"])
                is_bold = any("Bold" in span.get("font", "") for span in line["spans"])

                # Heuristic: detect section headings
                if is_bold and font_size > 11 and len(text.strip()) < 80:
                    if current_section["text"].strip():
                        sections.append(current_section)
                    current_section = {"heading": text.strip(), "text": ""}
                else:
                    current_section["text"] += text + " "

    if current_section["text"].strip():
        sections.append(current_section)

    doc.close()
    return sections

# Extract and display
sections = extract_paper_text("paper.pdf")
for s in sections:
    print(f"\n## {s['heading']}")
    print(s['text'][:200] + "...")
```

### Batch Paper Processing

```python
import os
import json

def process_paper_batch(pdf_dir, output_file):
    """Process a batch of papers and save structured notes."""
    results = []

    for filename in os.listdir(pdf_dir):
        if not filename.endswith(".pdf"):
            continue

        pdf_path = os.path.join(pdf_dir, filename)
        sections = extract_paper_text(pdf_path)

        # Find title (usually first bold text or first line)
        title = sections[0]["heading"] if sections else filename

        # Find abstract
        abstract = ""
        for s in sections:
            if "abstract" in s["heading"].lower():
                abstract = s["text"].strip()
                break

        results.append({
            "filename": filename,
            "title": title,
            "abstract": abstract,
            "num_sections": len(sections),
            "total_chars": sum(len(s["text"]) for s in sections)
        })

    with open(output_file, "w") as f:
        json.dump(results, f, indent=2)

    return results
```

## Annotation Tools Comparison

| Tool | Platform | Highlights | PDF Annotation | AI Features | Collaboration |
|------|----------|-----------|---------------|-------------|---------------|
| Zotero + ZotFile | All | Reference management + PDF | Yes | No (plugins available) | Group libraries |
| Paperpile | Web/Chrome | Google Docs integration | Yes | No | Shared folders |
| ReadCube Papers | All | Smart citations | Yes | Recommendations | Shared libraries |
| Semantic Reader | Web | AI-augmented reading | Yes | Inline explanations, TLDRs | No |
| Elicit | Web | AI paper search | No | Automated extraction | Tables |
| Scholarcy | Web | Flashcard summaries | Yes | Auto-summarization | No |

## Reading Strategies by Paper Type

| Paper Type | Focus On | Time Budget |
|-----------|----------|-------------|
| **Seminal paper** | Full three-pass reading, understand every detail | 3-4 hours |
| **Survey/review** | Section headings, taxonomy, open questions | 1-2 hours |
| **Methods paper** | Algorithm/procedure sections, pseudocode, evaluation | 1-2 hours |
| **Results paper** | Figures, tables, statistical tests, effect sizes | 30-60 min |
| **Position paper** | Arguments, assumptions, counterarguments | 30-60 min |
| **Related work (peripheral)** | Abstract + conclusion only (Pass 1) | 5-10 min |

## Building a Paper Reading Habit

1. **Set a regular schedule**: Read 2-3 papers per week during dedicated time blocks.
2. **Maintain a reading log**: Track papers read with dates, ratings, and one-line takeaways.
3. **Use a reference manager**: Add papers to your library as you read them, with tags and notes.
4. **Discuss papers**: Join or start a reading group; explaining papers to others deepens understanding.
5. **Connect to your research**: End every reading session by writing one sentence about how the paper relates to your own work.
