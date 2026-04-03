---
name: citation-style-guide
description: "APA, MLA, Chicago citation format guide with CSL configuration"
metadata:
  openclaw:
    emoji: "📖"
    category: "writing"
    subcategory: "citation"
    keywords: ["citation formatting", "CSL", "citation style", "reference management"]
    source: "wentor-research-plugins"
---

# Citation Style Guide

Master the major citation styles (APA, MLA, Chicago, IEEE, Vancouver) with examples, reference manager configuration, and CSL customization.

## Citation Style Overview

| Style | Primary Discipline | In-Text Format | Reference List Name |
|-------|-------------------|----------------|-------------------|
| APA 7th | Psychology, social sciences, education | (Author, Year) | References |
| MLA 9th | Humanities, literature, languages | (Author Page) | Works Cited |
| Chicago (Author-Date) | Social sciences, natural sciences | (Author Year) | References |
| Chicago (Notes-Bib) | History, arts, humanities | Footnotes/endnotes | Bibliography |
| IEEE | Engineering, computer science | [1] numbered | References |
| Vancouver | Medicine, biomedical sciences | (1) numbered | References |
| Harvard | General, UK/Australia universities | (Author Year) | Reference List |
| Nature | Multidisciplinary sciences | Superscript numbered | References |

## APA 7th Edition

### In-Text Citations

```
One author:     (Smith, 2023)     or   Smith (2023) found that...
Two authors:    (Smith & Jones, 2023)
3+ authors:     (Smith et al., 2023)
Direct quote:   (Smith, 2023, p. 45)
Multiple works: (Jones, 2021; Smith, 2023)
Same author, same year: (Smith, 2023a, 2023b)
Organization:   (World Health Organization [WHO], 2023)
                then subsequent: (WHO, 2023)
```

### Reference List Examples

```
# Journal article
Smith, J. A., & Jones, B. C. (2023). Title of the article in sentence
    case. Journal Name in Title Case, 45(2), 123-145.
    https://doi.org/10.1234/example

# Book
Williams, R. T. (2022). Title of the book in sentence case (3rd ed.).
    Publisher Name. https://doi.org/10.1234/example

# Chapter in edited book
Chen, L. (2023). Chapter title. In A. Editor & B. Editor (Eds.),
    Book title (pp. 50-75). Publisher. https://doi.org/10.1234/example

# Conference paper
Lee, S., & Park, J. (2023). Paper title. In Proceedings of the 2023
    Conference Name (pp. 100-110). Publisher.
    https://doi.org/10.1234/example

# Webpage
National Institutes of Health. (2023, March 15). Page title.
    https://www.nih.gov/example

# Preprint
Garcia, M. (2023). Title of preprint. arXiv.
    https://doi.org/10.48550/arXiv.2301.12345

# Dataset
Johnson, K. (2023). Dataset title (Version 2.0) [Data set]. Repository.
    https://doi.org/10.1234/example
```

## MLA 9th Edition

### In-Text Citations

```
One author:     (Smith 45)         or   Smith argues that "..." (45).
Two authors:    (Smith and Jones 45)
3+ authors:     (Smith et al. 45)
No page number: (Smith)
Multiple works: (Smith 45; Jones 67)
```

### Works Cited Examples

```
# Journal article
Smith, John A., and Beth C. Jones. "Article Title in Title Case."
    Journal Name, vol. 45, no. 2, 2023, pp. 123-45.
    https://doi.org/10.1234/example.

# Book
Williams, Rose T. Title of Book in Italics. 3rd ed., Publisher, 2022.

# Chapter in edited book
Chen, Li. "Chapter Title." Book Title, edited by Amy Editor and
    Bob Editor, Publisher, 2023, pp. 50-75.

# Website
"Page Title." Site Name, Organization, 15 Mar. 2023,
    www.example.com/page.
```

## IEEE Style

### In-Text Citations

IEEE uses numbered references in square brackets, in order of first appearance:

```
As shown in [1], deep learning has achieved...
Several studies [2]-[5] have demonstrated...
Smith et al. [6] proposed...
```

### Reference List Examples

```
# Journal article
[1] J. A. Smith and B. C. Jones, "Article title in sentence case,"
    J. Name Abbreviated, vol. 45, no. 2, pp. 123-145, Feb. 2023,
    doi: 10.1234/example.

# Conference paper
[2] S. Lee and J. Park, "Paper title," in Proc. Conf. Name,
    City, Country, 2023, pp. 100-110.

# Book
[3] R. T. Williams, Book Title in Italics, 3rd ed. City, Country:
    Publisher, 2022.

# Online source
[4] Author, "Page title," Website, date. [Online]. Available:
    https://www.example.com
```

## Using CSL (Citation Style Language)

CSL is the standard format used by Zotero, Mendeley, and other reference managers to define citation styles. Over 10,000 CSL styles are available at github.com/citation-style-language/styles.

### Installing a CSL Style in Zotero

1. Visit the Zotero Style Repository: zotero.org/styles
2. Search for your target journal or style (e.g., "Nature", "APA 7th")
3. Click to install directly into Zotero
4. In Zotero, go to Settings > Cite > Styles to manage installed styles

### CSL Style Structure

```xml
<?xml version="1.0" encoding="utf-8"?>
<style xmlns="http://purl.org/net/xbiblio/csl" class="in-text" version="1.0">
  <info>
    <title>Custom Style</title>
    <id>http://www.example.com/custom-style</id>
  </info>

  <!-- How in-text citations appear -->
  <citation>
    <sort>
      <key variable="author"/>
      <key variable="issued"/>
    </sort>
    <layout prefix="(" suffix=")" delimiter="; ">
      <group delimiter=", ">
        <names variable="author">
          <name form="short" and="symbol"/>
        </names>
        <date variable="issued" form="text" date-parts="year"/>
      </group>
    </layout>
  </citation>

  <!-- How the bibliography/reference list appears -->
  <bibliography>
    <sort>
      <key variable="author"/>
      <key variable="issued"/>
    </sort>
    <layout>
      <!-- Define reference formatting here -->
    </layout>
  </bibliography>
</style>
```

## BibTeX Entry Types

For LaTeX users, correct entry types ensure proper formatting:

```bibtex
@article{smith2023,
  author  = {Smith, John A. and Jones, Beth C.},
  title   = {Article Title},
  journal = {Journal Name},
  year    = {2023},
  volume  = {45},
  number  = {2},
  pages   = {123--145},
  doi     = {10.1234/example}
}

@inproceedings{lee2023,
  author    = {Lee, Sam and Park, Jin},
  title     = {Paper Title},
  booktitle = {Proceedings of the 2023 Conference},
  year      = {2023},
  pages     = {100--110},
  doi       = {10.1234/example}
}

@book{williams2022,
  author    = {Williams, Rose T.},
  title     = {Book Title},
  edition   = {3rd},
  publisher = {Publisher Name},
  year      = {2022}
}

@misc{garcia2023preprint,
  author = {Garcia, Maria},
  title  = {Title of Preprint},
  year   = {2023},
  eprint = {2301.12345},
  archiveprefix = {arXiv},
  primaryclass  = {cs.CL}
}
```

## Quick Decision Guide

| If your field is... | Use this style | LaTeX bibliography style |
|--------------------|---------------|------------------------|
| Psychology, education | APA 7th | `apacite` or `biblatex-apa` |
| Literature, languages | MLA 9th | `biblatex-mla` |
| History, arts | Chicago Notes | `chicago-authordate` |
| Engineering, CS (IEEE venues) | IEEE | `IEEEtran` |
| Medicine, clinical | Vancouver | `vancouver` |
| Natural sciences (Nature group) | Nature | `naturemag` |
| Economics | Chicago Author-Date | `chicago-authordate` |
| Check specific journal | Journal's author guidelines | See journal website |
