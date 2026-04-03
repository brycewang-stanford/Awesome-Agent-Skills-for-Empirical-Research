---
name: latex-templates-collection
description: "Collection of LaTeX templates for papers, presentations, and CVs"
version: 1.0.0
author: wentor-community
source: https://github.com/deedydas/latex-templates
metadata:
  openclaw:
    category: "writing"
    subcategory: "latex"
    emoji: "📋"
    keywords:
      - latex-templates
      - paper-templates
      - presentation-templates
      - cv-templates
      - academic-formatting
      - beamer
---

# LaTeX Templates Collection

A skill providing a curated collection of LaTeX templates for academic papers, conference presentations, CVs, cover letters, and other documents commonly needed by researchers. Based on the latex-templates repository (655 stars), this skill helps researchers quickly start professionally formatted documents without spending hours on layout configuration.

## Overview

Researchers spend significant time formatting documents to meet the requirements of different journals, conferences, and institutions. A well-organized template library eliminates this overhead by providing ready-to-use starting points that comply with common formatting standards. This skill catalogs templates by document type and provides guidance on selection, customization, and best practices for each category.

The templates cover the full range of academic document needs: research papers, technical reports, conference slides, academic CVs, cover letters, grant proposals, and poster presentations. Each template is designed for professional quality output with clean typography and proper academic formatting.

## Paper Templates

**Journal Article Templates**
- Two-column format templates for IEEE, ACM, and Elsevier journals
- Single-column format templates for Nature, Science, and PNAS style submissions
- APA-formatted manuscript templates for social science journals
- Generic article templates adaptable to any journal's requirements
- Preprint templates optimized for arXiv and other preprint servers

**Conference Paper Templates**
- NeurIPS, ICML, and ICLR templates for machine learning conferences
- ACL and EMNLP templates for NLP conferences
- CVPR and ICCV templates for computer vision conferences
- CHI and CSCW templates for HCI conferences
- Generic conference templates following common two-column layouts

**Template Structure**
- Each paper template includes: title page configuration, abstract environment, section hierarchy, bibliography setup, and appendix formatting
- Figure and table environments with proper captioning and numbering
- Algorithm and code listing environments for technical papers
- Mathematical theorem, proof, and definition environments
- Author metadata fields (name, affiliation, email, ORCID)

## Presentation Templates

**Beamer Templates**
- Clean, minimal themes suitable for academic talks
- Conference presentation templates with progress indicators
- Lecture slide templates with note support for teaching
- Thesis defense templates with structured slide sequences
- Poster session lightning talk templates

**Presentation Best Practices**
- Use large fonts (minimum 24pt for body text, 32pt for titles)
- Limit content to one main idea per slide
- Use figures and diagrams instead of dense text
- Include slide numbers and total count for audience orientation
- Provide a handout version with multiple slides per page

**Animation and Overlays**
- Use Beamer's overlay specifications for progressive content reveal
- Build complex diagrams step by step across overlay frames
- Highlight key terms or equations when they are first introduced
- Use pause commands for natural presentation flow
- Export animated PDFs for self-running presentations

## CV and Resume Templates

**Academic CV Templates**
- Comprehensive CV format with sections for: education, positions, publications, grants, teaching, service, talks
- Publication list formatting with citation counts and impact metrics
- Grant history with amounts, agencies, and roles
- Teaching portfolio section with course descriptions and evaluations
- Awards and honors with dates and descriptions

**Resume Templates**
- Concise one-page or two-page formats for industry applications
- Skills-focused layouts for technical positions
- Research summary formats for postdoc applications
- Clean, ATS-friendly designs that parse correctly in application systems
- Customizable color accents and section ordering

**Cover Letter Templates**
- Academic job application cover letters with structured paragraphs
- Grant application cover letters with project summary integration
- Journal submission cover letters with editorial board alignment
- Postdoc application letters emphasizing research vision
- Industry transition letters highlighting transferable skills

## Other Academic Templates

**Thesis and Dissertation**
- Chapter-based templates with front matter, back matter, and appendices
- University-specific formatting packages for common institutions
- Proposal templates for thesis committee submissions
- Progress report templates for annual reviews

**Grant Proposals**
- NSF-style proposal templates with required sections
- NIH grant format templates with specific aims structure
- EU Horizon-style templates with work package organization
- Internal funding application templates

**Posters**
- Conference poster templates in A0 and standard sizes
- Multi-column layouts with figures and results sections
- QR code integration for linking to preprints and code
- Print-ready templates with correct DPI and bleed settings

## Customization Guide

**Font Selection**
- Default Computer Modern works for most applications
- Times-like fonts: use `mathptmx` or `newtxtext`/`newtxmath`
- Sans-serif: use `helvet` or `sourcesanspro` for modern appearance
- Monospace: use `inconsolata` for code listings
- Always ensure math fonts are compatible with text fonts

**Color Schemes**
- Define institutional colors in the preamble for consistent branding
- Use `xcolor` package with named colors for maintainability
- Limit the palette to 3-4 colors maximum for professional appearance
- Ensure sufficient contrast for accessibility (WCAG AA minimum)
- Provide grayscale fallbacks for print compatibility

**Page Layout**
- Use `geometry` package for margin and page size configuration
- Set line spacing with `setspace` package (single, 1.5, double)
- Configure header and footer with `fancyhdr` package
- Control paragraph spacing and indentation with `parskip` or manual settings
- Set column separation and rule for multi-column layouts

## Integration with Research-Claw

This skill supports the Research-Claw document preparation workflow:

- Select appropriate templates based on the target venue
- Customize templates to match specific submission requirements
- Pre-populate templates with metadata from the research project
- Connect with writing composition skills for content generation
- Integrate with bibliography skills for reference management

## Best Practices

- Keep a personal template library with your preferred customizations pre-applied
- Version control your templates alongside your documents
- Test template compilation with a minimal document before starting the full manuscript
- Read the target venue's author guidelines even when using their official template
- Update templates before each new submission to catch any guideline changes
- Maintain backward compatibility by not removing custom commands from templates
