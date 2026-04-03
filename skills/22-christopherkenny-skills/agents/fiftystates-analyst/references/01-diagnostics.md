# Interpreting Internal Diagnostic Plots

## Plan Weights

SMC resampling weights, standardized to sum to 1. Formally defined in Algorithm 2 of the [SMC paper](https://arxiv.org/pdf/2008.06131.pdf); computed in [`redist-smc.R`](https://github.com/alarm-redist/redist/blob/e0521998ebc4b362ce7b95a683a896ea07d038bd/R/redist-smc.R#L128-L133).

**Check for**: No small number of plans with disproportionately large weights. Weights should vary by no more than 1–2 orders of magnitude. A long right tail means a few plans dominate the ensemble and effective sample size is low.

## Plan Diversity (VI Distance)

Variation of Information measures how different sampled plans are from one another. Higher = more diverse sample. See the [SMC paper](https://arxiv.org/pdf/2008.06131.pdf) for formal definition.

**Check for**: Ideally concentrated in the 0.5–1 range. A spike at 0 means all plans are identical — a serious problem. Values < 0.3 may be tolerable in complicated settings if weights look OK. No large spikes.

## Population Deviation

Maximum percent deviation from target district population (total pop / number of districts).

**Check for**: The enacted plan's deviation should be reasonable. Slightly inflated if the state splits precincts. Substantially higher deviation suggests the enacted plan was not added to `redist_map` correctly.

## Compactness

SMC nudges compactness via the exponent of log spanning tree compactness, which is highly correlated with Fraction of Edges Kept and fairly well correlated with Polsby-Popper. This is why all three metrics tend to move together.

### Polsby-Popper (PP)

Area / perimeter²; ranges 0–1 (1 = circle). Ordered boxplots: district 1 = least compact.

**Check for**: Consistent discrepancy between enacted plan and simulations, especially if enacted is *more* compact. Tight boxes (small y-range) indicate low plan diversity.

### Fraction of Edges Kept (FK)

Proportion of precinct boundary edges not cut by district lines. Lower = less compact. More robust to map resolution than PP.

**Check for**: Same as PP.

### Bounding Box Reock (BBR)

Area / minimum bounding box area; ranges 0–1 (1 = rectangle). Ordered boxplots.

**Check for**: Same as PP.

## Administrative Unit Splits

**County/municipal splits**: Number of units not wholly contained in one district.

**Total splits**: Sum of (unit-district pairs − 1) across all units. A county split across 3 districts contributes 2.

**Check for**: Enacted plan splits within the simulated range or near the lower tail. Far more splits than simulations suggests a constraint or data problem.

## Minority VAP Share

**Check for**:
- **Cracking**: All districts have low minority VAP — avoid.
- **Packing**: One district has absurdly high minority VAP — avoid.
- States with existing majority-minority districts: simulations should have (1) at least as many majority-minority districts and (2) that those districts perform.

## Example Plans

Visual maps of sampled plans.

**Check for**: Discontiguities, bizarre shapes, or implausible plans. Use to sanity-check the adjacency graph and constraint setup.

## Partisan Metrics

Not checked internally. Do not include partisan metrics in the PR.
