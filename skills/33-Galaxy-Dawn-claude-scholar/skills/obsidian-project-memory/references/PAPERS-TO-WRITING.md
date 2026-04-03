# Papers -> Experiments -> Results -> Writing

Use this as the default durable research pipeline inside the project knowledge base.

## Why this pipeline matters

The vault should not treat literature, experiments, results, and writing as isolated folders.

Default expectation:
1. `Papers/` produces hypotheses, reusable methods, baselines, and evaluation criteria.
2. `Experiments/` turns those into actionable test plans or updates an existing experiment line.
3. `Results/` captures the durable findings that survive beyond one run or one day.
4. `Writing/` turns those findings into external-facing synthesis: literature review, proposal text, draft claims, slides, rebuttal notes.

`Daily/` is the staging area for temporary work and chronology, not the final destination for durable research objects.

## Default handoff rules

### Papers -> Experiments

Promote from `Papers/` to `Experiments/` when a paper note yields:
- a testable hypothesis,
- a method variation worth implementing,
- a baseline worth reproducing,
- an ablation worth adding,
- an evaluation protocol or metric worth adopting.

Default action:
- update the existing canonical experiment note if the idea belongs to an existing experiment line,
- otherwise create one new experiment note for the distinct experiment line,
- add a short back-link from the paper note to that experiment note.

Do not stop at “this paper is relevant”; push at least to “what should we test because of it?” when the turn supports that level of specificity.

### Experiments -> Results

Promote from `Experiments/` to `Results/` when an experiment yields:
- a stable comparison,
- a repeatable failure pattern,
- a durable negative result,
- a mechanism insight,
- a decision-changing observation.

Default action:
- keep transient run noise in `Daily/` or inside the experiment note,
- create or update a result note only when the observation is stable enough to cite later,
- link the result note back to the experiment note and vice versa.

Do not create a result note for every run. Create one when the finding survives beyond raw logs.

### Results -> Writing

Promote from `Results/` to `Writing/` when a result yields:
- a claim that belongs in a paper, report, slide, or proposal,
- a useful comparison matrix,
- a project narrative update,
- a conclusion that should appear in a literature review or discussion section.

Default action:
- update an existing writing note when the output object already exists,
- otherwise create one writing note per external object (review, proposal, draft section, slide outline, rebuttal block),
- keep links back to the result notes and key paper notes that support the claim.

Do not let writing drift away from evidence. Every durable writing claim should link back to supporting results, and when useful, to the motivating papers.

## Folder-by-folder default questions

### For a paper note
Ask:
- What is the main reusable idea?
- Does it change what we should test?
- Which existing experiment line should absorb it?
- Does it belong in the active writing narrative yet?

### For an experiment note
Ask:
- Which paper or prior result motivated this experiment?
- What decision would this experiment change?
- What evidence would justify promotion into `Results/`?
- What writing object would benefit if this experiment succeeds or fails?

### For a result note
Ask:
- What is the durable claim?
- What evidence supports it?
- Which experiments and papers does it connect?
- Which writing artifact should absorb this claim next?

### For a writing note
Ask:
- Which result notes support this text?
- Which paper notes provide context or comparison?
- Is this writing object current, or should it be updated from newer results?

## Main anti-patterns

Avoid these weak workflows:
- paper notes that never produce experiment decisions,
- experiment notes that never clarify what finding would count as durable,
- result notes that never feed any writing object,
- writing notes that drift away from linked evidence,
- keeping durable insights in `Daily/` instead of promoting them.

## Default promotion heuristic

When unsure, use this order:
1. update the existing paper note,
2. if it changes what should be tested, update or create the experiment note,
3. if it changes what is now believed, update or create the result note,
4. if it changes what should be said externally, update the writing note.

This is the default durable research path unless the user clearly wants a narrower operation.
