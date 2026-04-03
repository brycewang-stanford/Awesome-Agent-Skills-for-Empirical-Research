---
name: science-communication
description: >-
  Translating technical findings for non-technical audiences. Narrative frameworks (Pyramid Principle, SCQA), plain-language translation, executive summaries, policy briefs, causal language. Use when presenting to stakeholders or reviewing deliverables
metadata:
  audience: research-writers
  domain: research-communication
---

# Science Communication

Translating technical data science findings for non-technical audiences. Covers audience analysis, narrative frameworks (Pyramid Principle, SCQA, AIDA), plain-language translation, executive summaries, policy briefs, causal language guidance, hedging and uncertainty communication, and accessibility standards. Complements data-scientist visualization references — handles what story to tell and to whom, not how to build charts. Use when presenting findings to stakeholders, writing executive summaries or policy briefs, communicating statistical results to non-statisticians, or reviewing a draft deliverable for clarity and audience fit.

Guidance for translating rigorous data science work into clear, compelling communication for non-technical audiences. This skill is **additive** to data-scientist's visualization references — it covers *what story the chart tells and to whom*, not *how to build the chart*.

**Boundary with data-scientist:** The data-scientist skill handles chart construction, encoding, color palettes, and export standards. This skill handles audience adaptation, narrative structure, plain-language translation, deliverable formatting, and communication quality review.

## How to Use This Skill

### Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `audience-analysis.md` | Five audience types with strategy tables | Identifying who you're writing for |
| `narrative-frameworks.md` | Six narrative structures with selection guide | Choosing how to structure your story |
| `plain-language.md` | Jargon translation, hedging, uncertainty, causal language | Writing findings in accessible language |
| `deliverable-templates.md` | Executive summary, policy brief, presentation, talking points | Formatting a specific deliverable type |
| `communication-review.md` | 10-point checklist, common pitfalls, seven deadly sins | Reviewing a deliverable before finalization |
| `accessibility-equity.md` | WCAG standards, people-first language, equity-aware framing | Ensuring inclusive, accessible communication |

### Reading Order

1. **Writing a report or brief?** Start with `audience-analysis.md`, then `narrative-frameworks.md`, then `deliverable-templates.md`
2. **Translating technical findings?** Read `plain-language.md` first
3. **Reviewing a draft?** Go straight to `communication-review.md`
4. **Concerned about equity or accessibility?** Read `accessibility-equity.md`

## Quick Decision Trees

### "Who am I writing for?"

```
Identifying your audience?
├─ Academic researchers or peer reviewers
│   └─ ./references/audience-analysis.md (Academic section)
├─ Policymakers or legislative staff
│   └─ ./references/audience-analysis.md (Policy section)
├─ Executives or board members
│   └─ ./references/audience-analysis.md (Executive section)
├─ General public or community members
│   └─ ./references/audience-analysis.md (Public section)
├─ Journalists or media
│   └─ ./references/audience-analysis.md (Media section)
└─ Mixed or unclear audience
    └─ ./references/audience-analysis.md (Assessment checklist)
```

### "How should I structure this?"

```
Choosing a narrative structure?
├─ Need to deliver a recommendation quickly
│   └─ Pyramid Principle → ./references/narrative-frameworks.md
├─ Framing a problem that needs solving
│   └─ SCQA → ./references/narrative-frameworks.md
├─ Walking through a discovery journey
│   └─ Three-Act Data Story → ./references/narrative-frameworks.md
├─ Translating findings into action
│   └─ "So What?" Framework → ./references/narrative-frameworks.md
├─ Presenting data with narrative and visuals together
│   └─ Data-Narrative-Visual Triad → ./references/narrative-frameworks.md
├─ Persuading stakeholders to act
│   └─ AIDA → ./references/narrative-frameworks.md
└─ Not sure which to use
    └─ Selection guide table → ./references/narrative-frameworks.md
```

### "How do I say this in plain language?"

```
Translating technical language?
├─ Statistical jargon (p-value, confidence interval, etc.)
│   └─ Jargon translation table → ./references/plain-language.md
├─ Expressing how certain you are
│   └─ Hedging language scale → ./references/plain-language.md
├─ Using calibrated uncertainty terms
│   └─ IPCC uncertainty framework → ./references/plain-language.md
├─ Describing causal vs correlational findings
│   └─ Causal language guide → ./references/plain-language.md
├─ General readability improvement
│   └─ Reading level guidance → ./references/plain-language.md
└─ Replacing formal/bureaucratic words
    └─ Word replacement list → ./references/plain-language.md
```

### "What format should this take?"

```
Choosing a deliverable format?
├─ One-page summary for decision makers
│   └─ Executive summary → ./references/deliverable-templates.md
├─ Informing policy decisions
│   └─ Policy brief → ./references/deliverable-templates.md
├─ Presenting to a room
│   └─ Stakeholder presentation → ./references/deliverable-templates.md
├─ Talking to a journalist
│   └─ Media talking points → ./references/deliverable-templates.md
└─ Full research report
    └─ (Use REPORT_TEMPLATE.md from agent_reference/)
```

### "Is this ready to share?"

```
Reviewing before finalization?
├─ Comprehensive quality check
│   └─ 10-point checklist → ./references/communication-review.md
├─ Statistical interpretation errors
│   └─ Seven deadly sins → ./references/communication-review.md
├─ Common communication pitfalls
│   └─ Pitfall catalog → ./references/communication-review.md
├─ Accessibility compliance
│   └─ WCAG checklist → ./references/accessibility-equity.md
└─ Equity and framing review
    └─ Do No Harm checklist → ./references/accessibility-equity.md
```

## The Communication Gap

Research findings fail to reach their audience not because they lack rigor, but because they lack translation. The core challenge is bridging two worlds:

| Researcher Instinct | Audience Need |
|---------------------|---------------|
| Lead with methodology | Lead with the finding |
| Hedge everything | State what you know, clearly |
| Use precise technical language | Use familiar words |
| Present all caveats upfront | Present the insight, then appropriate caveats |
| Show comprehensive data | Show the data that answers the question |
| Write for peer reviewers | Write for the person making a decision |

The AAAS communication framework captures this as **Goal → Audience → Message**: define your purpose first, identify who can act on it, then craft language for that specific reader. This inverts the typical scientific structure where content comes first and audience comes last.

## Core Principles

1. **Audience determines everything.** The same finding requires different structure, vocabulary, detail level, and uncertainty communication for each audience type. Always identify your audience before drafting.

2. **Lead with the "so what."** In scientific communication, conclusions come last. In stakeholder communication, the bottom line comes first. The reader's time and attention are scarce — earn continued reading with immediate relevance.

3. **Translate, don't simplify.** Plain language is not dumbing down. It is precise communication calibrated to the reader's vocabulary. A well-translated finding preserves its meaning while making it accessible.

4. **Show uncertainty honestly.** Hedging is not weakness — it is intellectual honesty. But hedge appropriately: too much hedging obscures the finding; too little overstates the evidence. Match your language to your inferential capacity.

5. **Every deliverable gets reviewed.** Use the 10-point communication checklist before sharing anything. Communication errors — jargon leakage, causal overclaiming, missing the "so what" — are as consequential as analytical errors.

6. **Equity is not optional.** How you frame data about people reflects values. People-first language, equity-aware color choices, inclusive framing, and accessible design are baseline requirements, not enhancements.

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Academic audience strategy | `./references/audience-analysis.md` |
| Policy audience strategy | `./references/audience-analysis.md` |
| Executive audience strategy | `./references/audience-analysis.md` |
| Public audience strategy | `./references/audience-analysis.md` |
| Media audience strategy | `./references/audience-analysis.md` |
| Audience assessment checklist | `./references/audience-analysis.md` |
| Pyramid Principle | `./references/narrative-frameworks.md` |
| SCQA framework | `./references/narrative-frameworks.md` |
| Three-Act Data Story | `./references/narrative-frameworks.md` |
| "So What?" framework | `./references/narrative-frameworks.md` |
| Data-Narrative-Visual Triad | `./references/narrative-frameworks.md` |
| AIDA framework | `./references/narrative-frameworks.md` |
| Framework selection guide | `./references/narrative-frameworks.md` |
| Jargon translation table | `./references/plain-language.md` |
| Reading level guidance | `./references/plain-language.md` |
| Hedging language scale | `./references/plain-language.md` |
| IPCC calibrated uncertainty | `./references/plain-language.md` |
| Causal vs correlational language | `./references/plain-language.md` |
| Word replacement list | `./references/plain-language.md` |
| Executive summary template | `./references/deliverable-templates.md` |
| Policy brief template | `./references/deliverable-templates.md` |
| Stakeholder presentation template | `./references/deliverable-templates.md` |
| Media talking points template | `./references/deliverable-templates.md` |
| 10-point communication checklist | `./references/communication-review.md` |
| Seven deadly sins of statistics | `./references/communication-review.md` |
| Communication pitfall catalog | `./references/communication-review.md` |
| WCAG data communication standards | `./references/accessibility-equity.md` |
| People-first language | `./references/accessibility-equity.md` |
| Do No Harm principles | `./references/accessibility-equity.md` |
| Alt text guidance | `./references/accessibility-equity.md` |
| Colorblind-safe communication | `./references/accessibility-equity.md` |
| Multi-format presentation | `./references/accessibility-equity.md` |
| Mixed audience strategies | `./references/audience-analysis.md` |
| Cross-audience comparison table | `./references/audience-analysis.md` |
| Tone and register by audience | `./references/audience-analysis.md` |
| Combining frameworks | `./references/narrative-frameworks.md` |
| Framework-to-deliverable matching | `./references/narrative-frameworks.md` |
| Hedging anti-patterns | `./references/plain-language.md` |
| Number formatting standards | `./references/plain-language.md` |
| Domain-specific jargon guidance | `./references/plain-language.md` |
| How to distill long reports | `./references/deliverable-templates.md` |
| Cross-deliverable consistency | `./references/deliverable-templates.md` |
| Pre-release review protocol | `./references/communication-review.md` |
| Comprehensive accessibility checklist | `./references/accessibility-equity.md` |
| Stereotype-aware color choices | `./references/accessibility-equity.md` |
| Evolving terminology guidance | `./references/accessibility-equity.md` |
| Identity-first vs people-first language | `./references/accessibility-equity.md` |

## Citation Responsibility

When reporting standards or communication frameworks from this skill shape how findings
are presented in a DAAF report (causal language guidelines, uncertainty frameworks,
equity-sensitive visualization principles), the report-writer includes the relevant
citation in the report's Reporting Standards references section.

Each citation must include a brief rationale explaining why it is included.

For the master citation index and inclusion thresholds, consult
`agent_reference/CITATION_REFERENCE.md`.
