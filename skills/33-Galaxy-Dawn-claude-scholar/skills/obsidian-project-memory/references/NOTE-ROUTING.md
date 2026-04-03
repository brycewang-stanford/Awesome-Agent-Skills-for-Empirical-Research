# Note Routing

## First decide: durable note or raw material

### Durable note

Treat content as a durable note when it is:
- likely to be referenced again after days or weeks,
- about a clearly bounded object,
- already stable enough to stand on its own,
- suitable to become the canonical note for that object.

### Raw material

Treat content as raw material when it is:
- a short-lived intermediate artifact,
- a draft, memo, scratch note, or meeting fragment,
- an unverified analysis dump,
- incomplete support for a note that already exists.

Default rule: **raw material should be summarized before promotion**.

## Route by knowledge type

### Knowledge

Write to `Knowledge/` when the content is stable and explanatory:
- project background
- research questions
- dataset protocol
- method landscape
- source inventory
- codebase overview

Do not put these here by default:
- temporary ideas,
- unverified hypotheses with no stable framing,
- daily execution logs.

### Papers

Write to `Papers/` when the content is primarily literature-facing:
- single paper notes
- related-work summaries
- paper-to-project relevance notes
- reading notes and literature synthesis

Do not put these here by default:
- project-only summaries with no literature object,
- raw meeting notes about papers,
- unrelated implementation notes.

### Experiments

Write to `Experiments/` when the content is about what was run or will be run:
- experiment design
- runbook
- ablation
- baseline comparison setup
- freezing / transfer / screening study

Do not put these here by default:
- raw metric dumps with no interpretation,
- broad project framing,
- final cross-experiment claims that belong in `Results/`.

### Results

Write to `Results/` when the content captures a durable finding:
- final comparison
- mechanism conclusion
- collapse diagnosis
- figure and csv index
- cross-experiment interpretation
- stable canonical claim that should survive beyond one report

Do not put these here by default:
- unprocessed analysis output,
- notes that merely restate the experiment setup,
- temporary result speculation that still belongs in `Daily/`.

### Results Reports

Write to `Results/Reports/` when the content is a **complete internal experiment summary report**:
- one experiment round retrospective,
- one batch report for a coherent experiment line,
- one decision-oriented wrap-up note backed by analysis artifacts.

These notes should use the naming contract:
- `YYYY-MM-DD--{experiment-line}--r{round}--{purpose}.md`

Do not put these here by default:
- manuscript-facing draft text,
- raw metric dumps,
- vague summaries without one date / line / round / purpose.

### Writing

Write to `Writing/` when the content is meant for external output:
- paper draft fragments
- slide narrative
- rebuttal notes
- proposal text

Internal experiment reports do **not** belong here unless they are already external-facing writing artifacts.

### Daily

Write to `Daily/` when the content is transient or process-oriented:
- what happened today
- short sync queue
- quick scratch ideas
- temporary planning fragments
- lightweight meeting notes

Do not let `Daily/` become the long-term home for canonical project knowledge. Promote durable content later.

## Main routing rule

If a note will still matter after several days or weeks, prefer `Knowledge/`, `Experiments/`, `Results/`, `Results/Reports/`, `Papers/`, or `Writing/`.

If the note is mainly about today's progress or temporary organization, prefer `Daily/`.

## Cross-folder promotion defaults

Treat these folders as a research pipeline, not as independent buckets:

- `Papers/` should usually answer: what should we test, compare, or borrow?
- `Experiments/` should usually answer: what exactly are we running, and what finding would matter?
- `Results/` should usually answer: what do we now believe, with evidence?
- `Results/Reports/` should usually answer: what happened in this round or batch, and what decision does it imply?
- `Writing/` should usually answer: what should be said externally because of those results?

Default promotion path:
- paper insight -> experiment note
- stable experiment finding -> result note
- coherent round/batch retrospective -> results report note
- durable result claim -> writing note

If a turn reaches only one stage, keep it there. But when the next stage is already clear, prefer updating the next canonical note instead of leaving the chain broken.
