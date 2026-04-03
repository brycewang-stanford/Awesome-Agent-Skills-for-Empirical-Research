# Source Priority

Use this file to rank sources and build searches.

## Search Order

1. Recent arXiv streams for speed:
   - `eess.SY`
   - `cs.AI`
   - `cs.RO`
   - `cs.LG`
2. Top IEEE and automation venues:
   - T-ASE
   - CASE
   - ICRA
   - IROS
   - RA-L
   - T-RO
3. Adjacent industrial and control venues from `venue-map.md`

## Ranking Logic

Use this ranking logic when filtering sources:

| Tier | Definition | Default treatment |
|---|---|---|
| Tier 1 | Top venue paper directly aligned with the Industrial AI topic | prefer by default |
| Tier 2 | Strong adjacent venue or highly relevant recent preprint | include when it adds coverage |
| Tier 3 | General AI paper with indirect industrial relevance | include only with clear transfer value |
| Tier 4 | Generic articles, unverified commentary, marketing pages | exclude |

## Recency Policy

- Default window: last 3 years.
- Use last 12 months when the user explicitly wants the latest wave.
- Use last 5 years when the field is sparse or adoption cycles are slow.
- Allow older seminal papers only when they define the problem or benchmark lineage.

## Verification Rules

- Confirm year, venue, and publication type before citing a paper as evidence.
- Distinguish preprints from peer-reviewed papers.
- Remove duplicates between arXiv and conference or journal versions when possible.
- Prefer official pages and publisher metadata over scraped summaries.

## Topic-Specific Heuristics

### Predictive maintenance

- Heavily weight deployment setting, sensor modality, and maintenance outcome.
- Do not over-index on general anomaly detection papers with no industrial asset context.

### Intelligent scheduling

- Weight papers that expose constraints, real system assumptions, or shop-floor context.
- Treat generic RL scheduling papers as secondary unless they show industrial realism.

### Industrial anomaly detection

- Weight papers with fault type definitions, industrial datasets, or production constraints.
- Flag work that is image-only or benchmark-only with no industrial deployment link.

### Smart manufacturing and CPS

- Weight papers that tie learning to control, optimization, or operations outcomes.
- Prefer papers with explicit industrial process assumptions over generic AI optimization papers.
