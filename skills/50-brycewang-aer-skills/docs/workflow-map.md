# Workflow Map

The intended journey through the AER-skills stack.

## Linear Default

```
┌─────────────────────┐
│  aer-topic-selection│   Topic + venue routing (AER / Insights / AEJ)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  aer-identification │   Design-based identification, modern estimators
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   aer-robustness    │   Heterogeneity, mechanism, placebo, anticipation
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  aer-introduction   │   Five-paragraph intro + 100-word abstract
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ aer-tables-figures  │   Booktabs, regression tables, figure notes
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   aer-replication   │   AEA Data and Code Availability deposit
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   aer-submission    │   Format preflight, cover letter, conflicts
└──────────┬──────────┘
           │
           ▼ (after decision)
┌─────────────────────┐
│    aer-rebuttal     │   R&R response letter + aligned manuscript edits
└─────────────────────┘
```

## When to Loop

- **Identification rebuild** triggered by an R&R targeting the design → loop back to `aer-identification` then forward
- **Format-only revisions** → skip back only to `aer-tables-figures` or `aer-submission`
- **Venue change** after rejection → `aer-topic-selection` again, then `aer-introduction` for re-framing

## The Router

`aer-workflow` is the entry point when the user is unsure where they are. It does not perform work — it picks the next skill.
