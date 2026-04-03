# Workflow

## 1. Detect

Run:

```bash
python3 scripts/project_kb.py detect --cwd "$PWD"
```

Use this to decide whether the repo:
- is already bound,
- should be bootstrapped,
- or should be left alone.

## 2. Bootstrap

Bootstrap only when the repository is a strong research-project candidate and no binding exists yet.

```bash
python3 scripts/project_kb.py bootstrap --cwd "$PWD" --vault-path "$OBSIDIAN_VAULT_PATH"
```

Bootstrap should create only the compact schema from `SCHEMA.md`, including `Results/Reports/` for internal experiment reports.

To bootstrap Chinese notes explicitly:

```bash
python3 scripts/project_kb.py bootstrap --cwd "$PWD" --vault-path "$OBSIDIAN_VAULT_PATH" --note-language zh-CN
```

Language priority for generated/synced notes:
1. per-project `note_language` in `.claude/project-memory/registry.yaml`
2. environment variable `OBSIDIAN_NOTE_LANGUAGE`
3. default `en`

Section updates remain compatible with both English and Chinese headings so older notes can still sync safely after switching the configured language.

## 3. Daily or repo-driven sync

Use:

```bash
python3 scripts/project_kb.py sync --cwd "$PWD" --scope auto
```

Use sync for deterministic state maintenance only:
- refresh `00-Hub.md`
- refresh `01-Plan.md`
- refresh project memory
- write daily sync information
- keep source inventory and codebase overview fresh

Do not rely on sync to derive project meaning from raw files.

For read-side assistance or single-note lifecycle operations, use:

```bash
python3 scripts/project_kb.py query-context --cwd "$PWD" --kind broad
python3 scripts/project_kb.py query-context --cwd "$PWD" --kind result --query "syllable-channel"
python3 scripts/project_kb.py find-canonical-note --cwd "$PWD" --kind experiment --query "freezing S7 speaking"
python3 scripts/project_kb.py note-lifecycle --cwd "$PWD" --mode archive --note "Results/Old-Result.md"
```

## 4. Agent-first import or synthesis

When the vault lacks background or context, do not extend the script first.

Instead:
1. ask an agent to read the most informative project sources,
2. synthesize project-level knowledge,
3. write durable notes back into `Knowledge/`, `Experiments/`, `Results/`, `Results/Reports/`, or `Papers/`.

## 5. Advance along the main research path

For substantive research turns, prefer advancing knowledge along this path:

```text
Papers -> Experiments -> Results -> Writing
```

Typical progression:
- new paper understanding -> update `Papers/` and decide whether an experiment note should absorb a new hypothesis, baseline, or evaluation rule
- experiment planning or execution -> update `Experiments/` and decide what evidence would justify a result note
- stable finding -> update `Results/` and decide whether a round or batch retrospective should be written under `Results/Reports/`
- draft or review work -> update `Writing/` and keep links back to supporting results and papers

Do not treat these folders as isolated silos. The default durable workflow is to move knowledge forward across them when the turn supports it.

## 6. Incremental update rule

For most turns, write the minimum durable delta only.

Examples:
- small engineering change -> `Daily/` plus project memory
- new experiment design -> `Experiments/`
- new result interpretation -> `Results/`
- new internal experiment retrospective -> `Results/Reports/`
- new project framing -> `Knowledge/`
- new paper note -> `Papers/`

## 7. Ingest a new Markdown file

When a new `.md` file appears, do not route it by path alone.

Use this sequence:
1. classify it as `knowledge`, `paper`, `experiment`, `result`, `writing`, or `daily`,
2. decide whether it is a **durable note** or **raw material**,
3. choose one of:
   - **promote** into the matching top-level folder,
   - **merge** into an existing canonical note,
   - **stage to Daily** when it is still unstable.

Examples:
- new `plan/new_idea.md` -> usually summarize first, then update `01-Plan.md` or `Knowledge/Research-Questions.md`
- a complete experiment summary -> usually promote to `Results/Reports/`, and update `Results/` if a stable conclusion is now supported
- a scratch meeting memo -> usually stage in `Daily/`

`project_kb.py` may manage state around this process, but it does not decide promote vs merge.

## 8. Update / archive / purge durable notes

For durable notes:
- update the canonical note when the object already exists,
- create a new note only when the object is genuinely distinct,
- archive by default when the user wants to remove something,
- purge only on explicit permanent-delete intent.

When archiving or purging, repair direct links in `00-Hub.md`, `01-Plan.md`, and explicit index notes.

## 9. Lifecycle actions

Default removal behavior is archive:

```bash
python3 scripts/project_kb.py lifecycle --cwd "$PWD" --mode archive
```

Only purge when the user explicitly asks for permanent deletion.
