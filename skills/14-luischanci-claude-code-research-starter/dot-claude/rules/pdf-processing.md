---
paths:
  - "master_supporting_docs/**"
---

# Robust PDF Processing

## The Safe Processing Workflow

**Step 1: Receive PDF Upload**
- User uploads PDF to `master_supporting_docs/supporting_papers/`
- Claude DOES NOT attempt to read it directly if it's very large

**Step 2: Check PDF Properties**
```bash
pdfinfo paper_name.pdf | grep "Pages:"
ls -lh paper_name.pdf
```

**Step 3: For Large PDFs (>20 pages), Split into Chunks**
```bash
mkdir -p paper_name/

# Split into 5-page chunks using Ghostscript or pdftk
gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
   -dFirstPage=1 -dLastPage=5 \
   -sOutputFile="paper_name/paper_name_p001-005.pdf" \
   paper_name.pdf 2>/dev/null
```

**Step 4: Process Chunks Intelligently**
- Read chunks ONE AT A TIME using the Read tool
- Extract key information from each chunk
- Build understanding progressively

**Step 5: Selective Deep Reading**
- After scanning all chunks, identify the most relevant sections
- Only read those sections in detail
- Skip appendices, references, or less relevant sections unless needed

## Error Handling Protocol

**If a chunk fails to process:**
1. Note the problematic chunk
2. Try splitting into 1-2 page pieces
3. If still failing, skip and document the gap

**If splitting fails:**
1. Check if Ghostscript is installed: `gs --version`
2. Try alternative: `pdftk paper.pdf burst output paper_%03d.pdf`
3. If all else fails, ask user to upload specific page ranges manually
