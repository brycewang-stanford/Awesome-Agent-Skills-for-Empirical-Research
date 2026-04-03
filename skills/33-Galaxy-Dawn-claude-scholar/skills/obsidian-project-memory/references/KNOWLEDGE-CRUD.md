# Knowledge CRUD

Use these rules when maintaining a research-project knowledge base.

## Core defaults

- **One canonical note per durable object**
- **Prefer updating over duplicating**
- **Raw material is not durable knowledge**
- **Archive by default; purge only on explicit request**
- **Query narrowly first, synthesize second**


## Default research progression

When a research turn is substantive, prefer moving durable knowledge forward along this path:

```
Papers -> Experiments -> Results -> Writing
```

Interpretation:
- a paper note should often end with a testable takeaway, not only a summary,
- an experiment note should clarify what evidence would justify a result note,
- a result note should usually clarify what writing object should absorb the claim next.

This progression does not mean every turn must touch all four folders. It means the next durable handoff should be made explicit whenever it is already clear.

## Create

When new knowledge appears, answer two questions first:

1. Which type is it?
   - `knowledge`
   - `paper`
   - `experiment`
   - `result`
   - `writing`
   - `daily`
2. Is it a **durable note** or **raw material**?

Default policy: **summarize first, then route**.

Promote directly only when the content is already:
- self-contained,
- stable,
- clearly bounded,
- likely to be referenced later.

Otherwise:
- merge it into the existing canonical note for the same object, or
- stage it in `Daily/` if it is not stable enough yet.

Never:
- map new files one-to-one into new durable notes by path alone,
- create a new canonical note for the same experiment/result/paper without a real distinction,
- turn every discovered Markdown file into a formal vault object.

## Read

Use the smallest sufficient read set first.

### Query presets

- broad project question -> `00-Hub.md` + `Knowledge/Project-Overview.md` + `Knowledge/Research-Questions.md`
- next step / active work -> `01-Plan.md` + today's `Daily/` + project memory
- specific experiment -> matching note in `Experiments/`
- specific result -> matching note in `Results/`
- literature question -> matching note in `Papers/`

### Query order

1. canonical note
2. neighboring durable notes
3. daily or scratch context
4. repo source docs or outputs
5. agent synthesis

Do not start by scanning the entire vault or repo when a canonical note already exists.

## Update

When new material overlaps an existing durable object:
- update the canonical note,
- do not create a sibling note by default.

Update style by folder:
- `Knowledge/` -> rewrite stable conclusions; avoid timestamp noise
- `Experiments/` -> preserve experiment identity; add updates, findings, next steps
- `Results/` -> update headline, evidence, interpretation
- `Writing/` -> continue draft evolution or split by output object when necessary
- `Daily/` -> append freely; later promote durable parts

Merge and split rules:
- merge several small notes when they are clearly about one durable object,
- split a note when it has grown into multiple durable objects with different lifecycles.

## Delete

Interpret deletion intent carefully:
- “remove / delete / stop using / no longer needed” -> archive
- “keep history but stop using” -> archive
- “permanently delete / purge” -> purge

### Archive

Default action:
- move the target note into `Archive/`,
- repair direct links in `00-Hub.md`, `01-Plan.md`, and explicit index notes,
- avoid leaving the main working surface with broken links.

### Purge

Only on explicit permanent-delete intent:
- delete the target note,
- clean direct links in `00-Hub.md`, `01-Plan.md`, and explicit index notes,
- ensure the deleted note was not the only canonical carrier of still-needed knowledge.

### Rename or move

Treat rename or move as:
- update of the same durable object, plus
- link repair

Do not treat rename as delete-plus-create unless the object meaning actually changed.
