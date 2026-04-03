---
name: legal-agent-skills-guide
description: "Agent skills collection for legal research and automation"
metadata:
  openclaw:
    emoji: "⚖️"
    category: "domains"
    subcategory: "law"
    keywords: ["legal AI", "legal automation", "legal research", "agent skills", "contract analysis", "case law"]
    source: "https://github.com/lawvable/awesome-legal-skills"
---

# Legal Agent Skills Guide

## Overview

A curated collection of agent skills for legal research and automation — contract analysis, case law search, regulatory compliance checking, legal document drafting, and citation verification. Each skill provides structured capabilities that AI agents can use to assist with legal workflows. Designed for legal researchers, law firms, and compliance teams.

## Skill Categories

```
Legal Agent Skills
├── Research Skills
│   ├── Case law search (by jurisdiction, topic)
│   ├── Statute lookup (federal, state, international)
│   ├── Legal commentary search
│   └── Regulatory tracking
├── Analysis Skills
│   ├── Contract clause extraction
│   ├── Risk assessment
│   ├── Compliance checking
│   └── Legal argument analysis
├── Drafting Skills
│   ├── Contract drafting
│   ├── Legal memo writing
│   ├── Motion drafting
│   └── Compliance reports
├── Citation Skills
│   ├── Bluebook formatting
│   ├── Citation verification
│   ├── Shepard's-style validation
│   └── Cross-reference linking
└── Practice Management
    ├── Case timeline construction
    ├── Discovery document review
    ├── Deposition summary
    └── Billing narrative generation
```

## Key Skills

### Case Law Research

```python
# Search case law databases
from legal_skills import CaseLawSearch

search = CaseLawSearch(jurisdictions=["federal", "california"])

cases = search.find(
    query="AI liability product defect",
    date_range=("2020-01-01", "2025-12-31"),
    court_level="appellate",
    max_results=20,
)

for case in cases:
    print(f"{case.name} ({case.year})")
    print(f"  Court: {case.court}")
    print(f"  Key holding: {case.holding[:100]}...")
    print(f"  Citation: {case.citation}")
```

### Contract Analysis

```python
from legal_skills import ContractAnalyzer

analyzer = ContractAnalyzer()

# Analyze contract
analysis = analyzer.analyze("contract.pdf")

print("Risk Assessment:")
for risk in analysis.risks:
    print(f"  [{risk.severity}] {risk.clause}: {risk.description}")

print("\nKey Terms:")
for term in analysis.key_terms:
    print(f"  {term.name}: {term.value}")

print("\nMissing Clauses:")
for missing in analysis.missing_clauses:
    print(f"  - {missing}")
```

### Bluebook Citation

```python
from legal_skills import BluebookFormatter

formatter = BluebookFormatter()

# Format citation
citation = formatter.format(
    case_name="Brown v. Board of Education",
    volume=347,
    reporter="U.S.",
    page=483,
    year=1954,
)
print(citation)
# Brown v. Board of Education, 347 U.S. 483 (1954).

# Verify citation
valid = formatter.verify("347 U.S. 483")
print(f"Valid: {valid.is_valid}, Case: {valid.case_name}")
```

## Use Cases

1. **Legal research**: AI-assisted case law and statute search
2. **Contract review**: Automated clause analysis and risk flagging
3. **Compliance**: Regulatory compliance checking
4. **Drafting**: AI-assisted legal document drafting
5. **Citation management**: Bluebook formatting and verification

## References

- [awesome-legal-skills](https://github.com/lawvable/awesome-legal-skills)
- [CourtListener](https://www.courtlistener.com/) — Free case law
- [Caselaw Access Project](https://case.law/)
