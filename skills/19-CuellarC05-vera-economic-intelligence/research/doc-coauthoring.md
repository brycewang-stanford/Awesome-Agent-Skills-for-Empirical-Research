
---
name: doc-coauthoring
description: Structured workflow for collaboratively creating high‑quality documents such as proposals, technical specifications, decision documents, research papers and policy briefs. It ensures full context transfer, iterative drafting and reader validation so that the final document is clear and usable.
category: writing
trigger:
  - "write a document"
  - "draft a proposal"
  - "create a spec"
  - "design doc"
  - "policy brief"
  - "research paper"
  - "decision doc"
output:
  - structured_document
  - draft_sections
success_criteria:
  - document structure is clear and complete
  - content meets the needs of the audience
  - readers can understand the document without external context
---

# Document Co‑Authoring Workflow

This skill provides a guided collaboration framework for producing clear, structured and reader‑ready documents.  It is designed for long‑form writing tasks ranging from technical specifications to research reports and policy briefs.  The workflow consists of three adaptive stages: **Context Alignment**, **Iterative Drafting**, and **Reader Validation**.  You can invoke this skill when you need to lead or assist with document creation.

## Stage 1 — Context Alignment

**Goal:** Close the knowledge gap between the user and the assistant so that the assistant can provide intelligent guidance.  Ask the user to provide meta‑context and background information before any drafting begins.

### Document Metadata
Prompt the user for high‑level details:
- What type of document is it? (e.g. proposal, technical spec, research paper)
- Who is the primary audience?
- What is the desired impact or decision the document should support?
- Are there templates, styles or formatting requirements to follow?
- Are there length, tone or timeline constraints?

Encourage shorthand answers.

### Context Transfer
Invite the user to share relevant background material.  This may include:
- Project or policy background, including economic context, labor market issues or childcare policy details.
- Notes from meetings, team discussions or previous documents.
- Technical architecture, data sources or methodological constraints.
- Stakeholder concerns, organizational politics or timeline pressures.

Encourage free‑form information dumping.  Explain that you will help organize the information later.  If connectors are available (e.g. Slack, Google Drive, SharePoint), offer to fetch shared documents or threads.

### Clarifying Questions
Once the user has provided initial context, generate 5–10 targeted questions to identify missing information.  Focus on objectives, assumptions, trade‑offs, scope boundaries and stakeholder expectations.  Once the assistant can accurately describe the problem space and the purpose of the document, proceed to the drafting stage.

## Stage 2 — Iterative Drafting

**Goal:** Build the document section by section in collaboration with the user.

### Determine Document Structure
If the user has a template, follow it.  Otherwise, propose a structure appropriate to the document type.  For example:
- Research paper: Introduction, Literature Review, Data and Methods, Results, Discussion, Conclusion.
- Policy brief: Executive Summary, Problem Statement, Policy Options, Recommended Actions, Implementation Plan, Conclusion.
Confirm the structure with the user before proceeding.

### Create a Draft Scaffold
Generate a document skeleton with section headers and placeholder text.  This provides a shared starting point.  If artifact tools are available, create a file that both you and the user can edit; otherwise, draft the scaffold in plain text.

### Section Development Loop
For each section:
1. **Clarify:** Ask 3–6 questions tailored to the section’s purpose.
2. **Brainstorm:** Generate 5–15 ideas or points that might belong in the section, drawing from the user’s context and economic expertise.
3. **Curate:** Ask the user which points to keep, remove, merge or modify.
4. **Draft:** Write a draft of the section using the selected points.
5. **Refine:** Iterate based on user feedback, making surgical edits rather than rewriting the whole document.

Repeat until the user approves the section.  After several iterations with no major changes, suggest moving on.

### Quality Check
After most sections are drafted, review the entire document for logical flow, redundancy, contradictions and filler language.  Suggest improvements and clean up any unclear phrasing.

## Stage 3 — Reader Validation

**Goal:** Ensure that the document works for readers who lack the author’s context.  This catches hidden assumptions and ambiguities.

1. **Simulate Reader Questions:** Generate realistic questions a reader might ask.  Examples include: What problem does this document solve?  What decision is required?  What data support the argument?  What alternatives were considered?
2. **Comprehension Test:** Evaluate whether the document clearly answers those questions.  Identify ambiguous sections, missing context or unsupported assumptions.
3. **Fix Gaps:** Update the document to address any issues.  Repeat the validation steps if needed.

## Completion Criteria

The document is considered complete when the structure is clear, the intended audience can understand the content without additional explanations, and all critical questions are answered.  Encourage the user to perform a final read‑through, verify facts and links, and confirm that the document achieves its purpose before submission.
