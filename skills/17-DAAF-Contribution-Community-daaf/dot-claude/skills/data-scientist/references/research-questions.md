# Research Questions

Framing analytical questions, balancing rigor with usefulness, and communicating with stakeholders.

## Contents

- [Question Formulation](#question-formulation)
- [Rigor vs. Practicality](#rigor-vs-practicality)
- [Stakeholder Check-In Points](#stakeholder-check-in-points)
- [Communicating Results](#communicating-results)
- [Documenting Decisions](#documenting-decisions)

## Question Formulation

### From Business Question to Analytical Question

Business questions are often vague. Your job is to translate them into precise, answerable analytical questions.

| Business Question | Issues | Analytical Translation |
|-------------------|--------|------------------------|
| "How are sales doing?" | Vague time frame, no comparison | "What was total revenue in Q4 2024 compared to Q4 2023?" |
| "Why are customers churning?" | Multiple possible answers | "What customer attributes predict churn in the next 90 days?" |
| "Is the new feature working?" | No success metric defined | "Did feature X increase user engagement (sessions/week) by >10%?" |

### Translation Framework

1. **Specify the metric**: What exactly are we measuring?
2. **Define the population**: Who/what are we measuring?
3. **Set the time frame**: What period are we examining?
4. **Establish comparison**: Compared to what baseline?
5. **Determine threshold**: What constitutes a meaningful difference?

### Questions to Ask the Stakeholder

Before starting analysis, clarify:

```markdown
## Analysis Scoping Questions

1. **Decision**: What decision will this analysis inform?
2. **Action**: What will you do differently based on the results?
3. **Success**: What would a "good" answer look like?
4. **Timing**: When do you need this? What's the cost of waiting?
5. **Precision**: How precise does the answer need to be?
6. **Confidence**: How certain do you need to be?
7. **History**: Has this been analyzed before? What was learned?
```

### Avoiding Scope Creep

As you work, questions tend to expand. Guard against this:

```markdown
## Scope Definition

**In scope:**
- [Explicitly list what will be analyzed]

**Out of scope:**
- [Explicitly list what will NOT be analyzed]
- [Common adjacent questions that might come up]

**Assumptions:**
- [List assumptions we're making]

**Dependencies:**
- [Data, access, expertise needed]
```

## Rigor vs. Practicality

Different situations require different levels of rigor.

### Decision Matrix

| Scenario | Rigor Level | Rationale |
|----------|-------------|-----------|
| Exploratory / directional | Lower | Just need to know if worth investigating |
| Operational decision | Medium | Need confidence but speed matters |
| Strategic / high-stakes | Higher | Consequences of being wrong are significant |
| Publication / regulatory | Highest | External scrutiny requires defensibility |

### When to Simplify

**Simplify when:**
- Speed matters more than precision
- The decision would be the same regardless of exact numbers
- Data quality limits achievable precision anyway
- Stakeholders can't interpret complex methods
- It's an early iteration / prototype
- Resources (time, compute) are constrained

**Be rigorous when:**
- Stakes are high (major investment, policy change)
- Results will be scrutinized externally
- Unusual findings need validation
- Building foundation for future work
- Regulatory or legal requirements exist
- Small differences matter

### Communication Template

When proposing an approach, use this template:

```markdown
## Proposed Approach: [Analysis Name]

### Question
[Precise analytical question]

### Approach
[High-level methodology]

### Why This Approach
[Justification - why this vs. alternatives]

### Tradeoffs
- **Pros**: [Benefits of this approach]
- **Cons**: [Limitations, what we're giving up]
- **Alternatives not taken**: [Other options and why not]

### Required Rigor Level
[Low/Medium/High] because [justification]

### Deliverable
[What exactly will be delivered]

### Timeline
[When it will be ready]

### Decision Needed
[If stakeholder approval required for methodology]
```

## Stakeholder Check-In Points

### Critical Checkpoints

Check in with stakeholders at these points:

| Phase | Checkpoint | What to Clarify |
|-------|------------|-----------------|
| **Scoping** | Problem definition | "Is this the right question?" |
| **Scoping** | Success criteria | "How will we know if this is useful?" |
| **Scoping** | Rigor requirements | "What confidence level do you need?" |
| **Data** | Data selection | "These are the data sources and their limitations - acceptable?" |
| **Data** | Key definitions | "Here's how I'm defining [term] - correct?" |
| **Analysis** | Methodology | "I'm choosing approach X because Y - okay to proceed?" |
| **Analysis** | Surprising findings | "I found something unexpected - does this make sense?" |
| **Analysis** | Scope changes | "Answering this requires expanding scope - should we?" |
| **Results** | Draft findings | "Here's what I'm seeing - aligns with your understanding?" |
| **Results** | Limitations | "These are the caveats - are there others?" |

### How to Frame Check-Ins

**Good pattern:**
> "I've reached a decision point. I could do [A] which gives us [benefit] but [tradeoff], or [B] which gives us [different benefit] but [different tradeoff]. My recommendation is [X] because [rationale]. Does that align with your priorities?"

**Avoid:**
- Dumping technical details without framing decisions
- Asking open-ended "what should I do?" without options
- Proceeding on major assumptions without documenting them
- Waiting until the end to reveal limitations

### Signals to Check In

You SHOULD check in when:
- Multiple valid methodologies exist with different tradeoffs
- You're making assumptions that affect conclusions
- Findings contradict expectations
- Scope is expanding beyond original request
- You're uncertain whether analysis answers the actual question
- Results depend heavily on methodological choices
- You've discovered significant data quality issues

## Communicating Results

### Causal vs. Correlational Language

**Default to correlational language** unless you have experimental data:

| Causal (Avoid Unless Justified) | Correlational (Safer) |
|--------------------------------|----------------------|
| X causes Y | X is associated with Y |
| X increases Y | Higher X corresponds to higher Y |
| X impacts Y | X and Y are correlated |
| X drives Y | X predicts Y |
| X leads to Y | X tends to co-occur with Y |

**Only use causal language when:**
- Data comes from a randomized experiment
- You've controlled for confounders (and can defend this)
- Domain knowledge strongly supports causal mechanism
- Stakeholder explicitly requests causal claims (with caveats documented)

### Presenting Uncertainty

Always communicate uncertainty:

```markdown
## Key Finding

**Point estimate**: Customer churn rate is 15%

**Uncertainty**: 
- 95% confidence interval: 13% - 17%
- Based on sample of 10,000 customers
- Assumes sample is representative of all customers

**Caveats**:
- Excludes customers acquired in last 30 days
- Definition of "churn" = no activity in 90 days
- May differ by customer segment (not analyzed)
```

### Limitation Documentation

Every analysis should document limitations:

```markdown
## Limitations

### Data Limitations
- [What data was unavailable or excluded]
- [Known quality issues in the data]
- [Time period restrictions]

### Methodological Limitations
- [Assumptions made]
- [Approaches not taken and why]
- [Known weaknesses of chosen method]

### Generalizability Limitations
- [Who/what does this apply to]
- [Who/what does this NOT apply to]
- [Conditions under which findings may not hold]

### What This Analysis Cannot Answer
- [Adjacent questions this doesn't address]
- [Causal claims we cannot make]
```

## Documenting Decisions

### Decision Log Template

Keep a running log of methodological decisions:

```markdown
## Decision Log

### Decision 1: [Date]
**Question**: [What needed to be decided]
**Options considered**:
1. [Option A]: [Pros/cons]
2. [Option B]: [Pros/cons]
**Decision**: [What was chosen]
**Rationale**: [Why]
**Stakeholder input**: [Who approved, if applicable]

### Decision 2: [Date]
...
```

### Assumption Register

Track assumptions explicitly:

```markdown
## Assumptions Register

| ID | Assumption | Justification | Risk if Wrong | Validated |
|----|------------|---------------|---------------|-----------|
| A1 | Customer IDs are unique | DW documentation states this | High - duplicates would inflate counts | Yes - checked |
| A2 | Missing values are MCAR | No pattern observed in missingness | Medium - could bias results | Partially - visual inspection |
| A3 | Definitions consistent over time | Confirmed with data owner | High - trend analysis would be invalid | Yes - confirmed |
```

### Analysis Handoff Checklist

When completing an analysis, ensure you've documented:

- [ ] **Question**: Precise analytical question answered
- [ ] **Data**: Sources, limitations, quality issues
- [ ] **Methodology**: Approach taken and why
- [ ] **Decisions**: All methodological choices and rationale
- [ ] **Assumptions**: All assumptions made
- [ ] **Results**: Findings with uncertainty quantified
- [ ] **Limitations**: What this analysis cannot answer
- [ ] **Reproducibility**: How to re-run the analysis
- [ ] **Next steps**: Recommended follow-up (if any)

### Example: Complete Analysis Summary

```markdown
# Analysis Summary: Customer Churn Prediction

## Question
What customer attributes best predict churn (no activity in 90+ days) 
within the next quarter?

## Data
- Source: Customer360 data warehouse
- Period: Jan 2023 - Dec 2024
- Records: 150,000 customers with 6+ months history
- Excluded: New customers (<6 months), B2B accounts

## Methodology
- Logistic regression with L1 regularization
- Features: demographics, behavioral, transactional
- Train/test split: 80/20, stratified by churn
- Chosen over random forest for interpretability

## Key Findings
1. Days since last purchase (OR: 1.05 per day)
2. Support ticket count (OR: 1.3 per ticket)
3. Product category diversity (OR: 0.85 per category)

Model AUC: 0.78 (95% CI: 0.76-0.80)

## Limitations
- Correlational only - cannot claim causation
- Limited to customers with 6+ month history
- Does not account for seasonality
- B2B patterns may differ

## Assumptions
- "Churn" definition (90 days) appropriate for business
- Historical patterns will persist
- Feature availability at prediction time

## Decisions Made
- Used 90-day vs 60-day churn window (stakeholder preference)
- Excluded B2B (different dynamics, <5% of base)
- Chose interpretable model over black box

## Stakeholder Approvals
- Churn definition: [Name], [Date]
- Methodology: [Name], [Date]
- Draft findings reviewed: [Name], [Date]

## Reproducibility
- Code: `/analyses/churn_prediction/`
- Data snapshot: `s3://bucket/snapshots/20241215/`
- Environment: `requirements.txt` in repo
```
