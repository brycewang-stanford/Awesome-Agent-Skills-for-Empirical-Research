# Testing and Iteration

Skills improve through observation and refinement. This document covers how to test skills effectively and iterate based on real behavior.

## Core Philosophy

**Iterate on a single task first.** The most effective skill creators work through one challenging task until Claude succeeds, then extract the winning approach into the skill. This provides faster signal than broad testing. Once you have a working foundation, expand to multiple test cases for coverage.

## Creating Test Prompts

After writing a skill draft, create 2-3 realistic test prompts — the kind of thing a real user would actually say.

### Good Test Prompts

Realistic, specific, with natural language variation:

```
"ok so my boss just sent me this xlsx file (its in my downloads,
called something like 'Q4 sales final FINAL v2.xlsx') and she
wants me to add a column that shows the profit margin"

"I need to analyze the CCD enrollment data for Title I schools
in California from 2019-2022"

"can you help me set up a new data source skill for this dataset
I just downloaded from Census?"
```

### Bad Test Prompts

Too generic or obviously relevant — they don't test edge cases:

```
"Format this data"
"Extract text from PDF"
"Create a chart"
```

## Triggering Tests

Test both positive and negative triggering to ensure the skill activates at the right times.

### Should-Trigger Queries (aim for 8-10)

Different phrasings of the same intent:

- Some formal, some casual
- Cases where the user doesn't explicitly name the skill but clearly needs it
- Uncommon use cases
- Cases where this skill competes with another but should win

### Should-Not-Trigger Queries (aim for 8-10)

Focus on **near-misses** — queries sharing keywords or concepts but needing something different:

- Adjacent domains
- Ambiguous phrasing where naive keyword match would trigger but shouldn't
- Queries that touch the skill's domain but in a different context

Avoid obviously irrelevant queries ("Write a fibonacci function" as a negative test for a PDF skill tests nothing useful).

### Triggering Diagnosis

If the skill isn't triggering correctly, ask Claude directly:

> "When would you use the [skill name] skill?"

Claude will quote the description back. Compare what Claude says with what you intended, and adjust the description to close any gaps.

## Multi-Model Testing

Skills act as additions to models, so effectiveness varies by model. Test with all models you plan to use:

| Model | Testing Focus |
|-------|--------------|
| **Claude Haiku** (fast, economical) | Does the skill provide enough guidance? May need more explicit instructions |
| **Claude Sonnet** (balanced) | Is the skill clear and efficient? Good baseline test |
| **Claude Opus** (powerful reasoning) | Does the skill avoid over-explaining? May work with less detail |

What works perfectly for Opus might need more detail for Haiku. If targeting multiple models, aim for instructions that work well across all of them.

## The Iteration Loop

### Claude A / Claude B Model

The most effective iteration uses two Claude instances:

- **Claude A** (the designer): Helps you design and refine the skill's instructions
- **Claude B** (the tester): Uses the skill in real tasks with a fresh context

**Workflow:**

1. **Work through a task without a skill** with Claude A. Notice what context you repeatedly provide — table names, field definitions, filtering rules, naming conventions
2. **Ask Claude A to create/improve the skill** based on what you learned
3. **Review for conciseness** — check that Claude A hasn't added unnecessary explanations. Ask: "Remove the explanation about what X means — Claude already knows that"
4. **Test with Claude B** (a fresh instance with the skill loaded) on related use cases
5. **Observe Claude B's behavior** — where does it struggle, succeed, or make unexpected choices?
6. **Return to Claude A** with specifics: "When Claude B used this skill, it forgot to do X. How should we adjust?"
7. **Repeat** until satisfied

### What to Observe

Pay attention to how Claude actually navigates and uses skills:

| Observation | What It Means | Action |
|-------------|---------------|--------|
| Unexpected file reading order | Structure isn't intuitive | Reorganize references or add clearer pointers |
| Missed references | Links aren't prominent enough | Make references more explicit in SKILL.md |
| Repeatedly reads same file | Content should be promoted | Move frequently-needed content into SKILL.md |
| Never accesses a bundled file | File may be unnecessary | Consider removing or better signaling it |
| Skips validation steps | Instructions not clear enough | Add feedback loops or checklists |
| Generates code a bundled script already does | Script not mentioned clearly | Add explicit "Run `scripts/X.py`" instruction |

### When to Stop Iterating

Stop when:

- Feedback is empty (everything looks good)
- The skill handles your test cases reliably
- You're not making meaningful progress between iterations
- Edge cases are documented rather than engineered around

## Evaluation-Driven Development

For more rigorous skill development, create evaluations **before** writing extensive documentation:

1. **Identify gaps:** Run Claude on representative tasks without a skill. Document specific failures or missing context
2. **Create evaluations:** Build 3 scenarios that test these gaps
3. **Establish baseline:** Measure Claude's performance without the skill
4. **Write minimal instructions:** Create just enough content to address the gaps
5. **Iterate:** Run evaluations, compare against baseline, refine

This ensures you're solving actual problems rather than documenting imagined requirements.

## Gathering Feedback

If the skill will be used by others:

1. Share with teammates and observe their usage
2. Ask: Does the skill activate when expected? Are instructions clear? What's missing?
3. Incorporate feedback to address blind spots in your own usage patterns

Different users encounter different edge cases — team feedback catches scenarios you may not anticipate.

## Quick Reference

| Activity | Key Guidance |
|----------|-------------|
| First test | Iterate on one challenging task, then broaden |
| Test prompts | 2-3 realistic, specific, natural language |
| Triggering | Test 8-10 should-trigger + 8-10 should-not-trigger |
| Multi-model | Test with all target models; adjust detail level |
| Iteration | Use Claude A (design) / Claude B (test) pattern |
| Observation | Watch file access patterns, missed references, skipped steps |
| Stopping | Stop when feedback is empty or progress plateaus |
