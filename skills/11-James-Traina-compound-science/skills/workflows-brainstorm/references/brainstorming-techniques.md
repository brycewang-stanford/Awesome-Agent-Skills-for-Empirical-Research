# Brainstorming Techniques

Detailed process knowledge for effective brainstorming sessions that clarify **WHAT** to estimate/test/prove before diving into **HOW** to implement it.

## When to Use Brainstorming

Brainstorming is valuable when:
- The identification strategy is unclear or has multiple viable approaches
- Multiple estimation methods could address the research question
- Methodological trade-offs need to be explored with the user
- The user hasn't fully articulated the target parameter or estimand
- The research scope needs refinement (which variation to exploit, which margin to study)

Brainstorming can be skipped when:
- The estimation approach is explicitly specified (e.g., "run 2SLS with these instruments")
- The user knows exactly what method and specification to implement
- The task is a straightforward bug fix or well-defined code change

## Core Process

### Phase 0: Assess Requirement Clarity

Before diving into questions, assess whether brainstorming is needed.

**Signals that requirements are clear:**
- User specified the estimand, identification strategy, and estimation method
- User referenced an existing paper's approach to replicate
- User described exact model specification and data requirements
- Scope is constrained and well-defined (e.g., "add clustered standard errors at the state level")

**Signals that brainstorming is needed:**
- User used vague terms ("estimate the effect of X on Y", "figure out what's driving this")
- Multiple reasonable identification strategies exist
- Trade-offs between methods haven't been discussed
- User seems unsure about which variation to exploit or which assumptions to impose

If requirements are clear, suggest: "Your requirements seem clear. Consider proceeding directly to planning or implementation."

### Phase 1: Understand the Idea

Ask questions **one at a time** to understand the user's research intent. Avoid overwhelming with multiple questions.

**Question Techniques:**

1. **Prefer multiple choice when natural options exist**
   - Good: "For identification, should we use: (a) an instrumental variable, (b) a regression discontinuity, or (c) a difference-in-differences design?"
   - Avoid: "How should we identify the causal effect?"

2. **Start broad, then narrow**
   - First: What is the economic question or target parameter?
   - Then: What data and variation are available?
   - Finally: What assumptions are you willing to impose?

3. **Validate assumptions explicitly**
   - "I'm assuming the treatment timing is exogenous. Is that defensible here?"

4. **Ask about success criteria early**
   - "What would a convincing result look like? What would make a referee skeptical?"

**Key Topics to Explore:**

| Topic | Example Questions |
|-------|-------------------|
| Research Question | What causal effect or structural parameter are we trying to recover? |
| Data | What variation exists? Panel, cross-section, RD running variable? |
| Identification | What's the source of exogenous variation? What exclusion restrictions hold? |
| Assumptions | Which assumptions are we comfortable with? Parametric vs nonparametric? |
| Robustness | What would falsify this approach? What placebo tests make sense? |
| Literature | Are there similar empirical strategies in the literature to follow? |

**Exit Condition:** Continue until the research approach is clear OR user says "proceed" or "let's move on"

### Phase 2: Explore Approaches

After understanding the research question, propose 2-3 concrete methodological approaches.

**Structure for Each Approach:**

```markdown
### Approach A: [Name]

[2-3 sentence description of the estimation strategy]

**Pros:**
- [Benefit 1 -- e.g., minimal parametric assumptions]
- [Benefit 2 -- e.g., transparent identification]

**Cons:**
- [Drawback 1 -- e.g., requires large sample for power]
- [Drawback 2 -- e.g., local treatment effect only]

**Best when:** [Circumstances where this approach shines -- e.g., sharp discontinuity in assignment]
```

**Guidelines:**
- Lead with a recommendation and explain why
- Be honest about trade-offs (bias vs variance, internal vs external validity)
- Consider parsimony -- simpler identification is usually more credible
- Reference canonical implementations when relevant (e.g., "following Angrist & Pischke's setup")

### Phase 3: Capture the Design

Summarize key methodological decisions in a structured format.

**Design Doc Structure:**

```markdown
---
date: YYYY-MM-DD
topic: <kebab-case-topic>
---

# <Topic Title>

## What We're Estimating
[Concise description of the target parameter and estimand -- 1-2 paragraphs max]

## Why This Approach
[Brief explanation of approaches considered and why this identification strategy was chosen]

## Key Decisions
- [Decision 1 -- e.g., IV over OLS]: [Rationale -- endogeneity concern with X]
- [Decision 2 -- e.g., cluster at county level]: [Rationale -- treatment varies at county]

## Open Questions
- [Any unresolved questions for the planning phase -- e.g., which instrument specification to prefer]

## Next Steps
-> `/workflows:plan` for implementation details
```

**Output Location:** `docs/brainstorms/YYYY-MM-DD-<topic>-brainstorm.md`

### Phase 4: Handoff

Present clear options for what to do next:

1. **Proceed to planning** -> Run `/workflows:plan`
2. **Refine further** -> Continue exploring the methodology
3. **Done for now** -> User will return later

## YAGNI Principles

During brainstorming, actively resist complexity:

- **Don't design for hypothetical robustness checks before the main specification works**
- **Choose the simplest identification strategy that answers the question**
- **Prefer transparent, well-understood methods over clever novel approaches**
- **Ask "Do we really need this assumption?" when model complexity grows**
- **Defer decisions that don't need to be made now** (e.g., exact bandwidth choice, bootstrap replications)

## Incremental Validation

Keep sections short -- 200-300 words maximum. After each section of output, pause to validate understanding:

- "Does this match the research question you had in mind?"
- "Any adjustments to the identification strategy before we continue?"
- "Is this the methodological direction you want to go?"

This prevents wasted effort on misaligned designs.

## Anti-Patterns to Avoid

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| Asking 5 questions at once | Ask one at a time |
| Jumping to code or estimation details | Stay focused on WHAT to estimate, not HOW to code it |
| Proposing overly complex structural models | Start with reduced-form evidence, add structure only if needed |
| Ignoring existing literature approaches | Research what methods have been used for similar questions |
| Making assumptions without validating | State identification assumptions explicitly and confirm plausibility |
| Creating lengthy methodology writeups | Keep it concise -- technical details go in the plan |

## Integration with Planning

Brainstorming answers **WHAT** to estimate/test/prove:
- Target parameter and estimand
- Chosen identification strategy and rationale
- Key assumptions and trade-offs

Planning answers **HOW** to implement it:
- Data cleaning and variable construction steps
- Estimation code and specification choices
- Testing strategy and robustness checks

When brainstorm output exists, `/workflows:plan` should detect it and use it as input, skipping its own idea refinement phase.

During brainstorming, the `methods-explorer` agent can provide detailed estimator comparisons and the `literature-scout` agent can survey related work to inform the choice of approach.

## Pre-Planning Readiness Gate

Before transitioning to `/workflows:plan`, partition remaining questions:

**Resolve Before Planning** (blocking):
- Identification strategy not yet chosen -> must decide before planning
- Key data source not yet identified -> must confirm availability
- Estimation method not yet selected -> must compare options

**Deferred to Planning** (non-blocking):
- Specific variable construction details
- Exact specification of controls
- Software implementation choices

**Readiness test:** Ask "What would `/workflows:plan` still have to invent?" If the answer includes the identification strategy, the estimator choice, or the data source -- the brainstorm is not done.
