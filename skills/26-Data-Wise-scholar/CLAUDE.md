# Scholar Project - Claude Code Instructions

This file contains project-specific instructions for Claude Code when working on the scholar plugin.

---

## Git Workflow & Standards

### 1. Branch Architecture

- **`main`**: Production. **PROTECTED**. No direct commits. Only merges from `dev`.
- **`dev`**: Planning & Integration Hub. All features start here.
- **`feature/*`**: Isolated implementation branches.

### 2. Mandatory Workflow Steps

1. **Plan on `dev`**: Before coding, analyze requirements on `dev`. Summarize the plan and wait for approval.

2. **Isolate via Worktree**: Once approved, create a worktree.
   ```bash
   # Default location: ~/.git-worktrees/
   git worktree add ~/.git-worktrees/<project>-<feature> -b feature/<feature>

   # Example:
   git worktree add ~/.git-worktrees/scholar-teaching-demo -b feature/teaching-demo
   ```
   **Constraint:** Never write feature code on the `dev` branch.

3. **Atomic Development**:
   - Use **Conventional Commits** (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`)
   - Commits must be small and functional

4. **Integration (Feature → dev)**:
   - Run tests/linters in the worktree
   - Rebase `feature/*` onto `dev` for linear history
   - Execute merge to `dev`
   - Cleanup: `git worktree remove <path>` and `git branch -d <branch>`

5. **Release (dev → main)**:
   - Create a PR/Merge request from `dev` to `main`
   - **Never bypass this step**

### 3. Worktree Context Verification

- **Before any operation**, verify you are in the correct worktree: run `git worktree list` and `pwd` to confirm context before edits, commits, or fixes
- **Always verify** current branch/worktree with `git branch --show-current` before commands
- **If about to commit to `main`**: ABORT and redirect to the PR workflow
- When operating on branches with branch guards or protection, check for guard rules BEFORE attempting writes, force pushes, or PR creation. If blocked, ask the user rather than failing repeatedly

---

## Project Context

### Overview
Scholar is a Claude Code plugin for academic workflows with research + teaching capabilities.

### Current State (v2.17.0 released; v2.17.0 in progress on feature/canvas-enhancements)
- **Research:** 14 commands, 17 skills
- **Teaching:** 18 commands (`/teaching:exam`, `/teaching:quiz`, `/teaching:slides`, `/teaching:assignment`, `/teaching:solution`, `/teaching:syllabus`, `/teaching:rubric`, `/teaching:feedback`, `/teaching:demo`, `/teaching:lecture`, `/teaching:validate`, `/teaching:validate-r`, `/teaching:diff`, `/teaching:sync`, `/teaching:migrate`, `/teaching:config`, `/teaching:preflight`, `/teaching:canvas`)
- **Hub:** 1 command (`/scholar:hub` — command discovery and navigation, with flag discovery)
- **Tests:** ~3,302 tests
- **Docs:** MkDocs site on GitHub Pages
- **Integration:** Works with flow-cli for workflow automation
- **Release:** https://github.com/Data-Wise/scholar/releases/tag/v2.17.0

### Key Directories

```
scholar/
├── src/
│   ├── teaching/           # Teaching namespace
│   │   ├── commands/       # Teaching commands (14)
│   │   ├── templates/      # JSON templates
│   │   ├── schemas/        # JSON Schema v2 (lesson-plan, teaching-style, manifest)
│   │   ├── validators/     # Schema validation + coverage
│   │   ├── generators/     # AI generation (lecture-notes, lecture-refiner)
│   │   ├── formatters/     # Output formatters (md/qmd/tex/json)
│   │   ├── config/         # Config-flow integration (manifest-sync, diff-engine, sync-engine)
│   │   ├── demo-templates/ # Demo course scaffolding templates
│   │   ├── utils/          # Utilities (slugify, qmd-parser, preview-launcher)
│   │   └── ai/             # AI provider wrapper + prompt discovery
│   ├── discovery/           # Discovery engine + smart help (hub)
│   └── plugin-api/         # Plugin command definitions (33 commands)
├── docs/                    # User-facing docs (MkDocs site)
├── tests/
│   ├── teaching/           # Teaching command tests (Jest, 2,583)
│   ├── discovery/          # Discovery engine tests (node:test, 130)
│   └── commands/           # Hub command tests (node:test, 7)
├── mkdocs.yml              # Documentation site config
└── .STATUS                 # Project status tracking
```

---

## Implementation Guidelines

### Quality Standards
- **Test Coverage:** Minimum 80% for new code
- **Documentation:** JSDoc comments for all public functions
- **Error Handling:** All AI calls must have retry logic
- **Validation:** 100% schema compliance for generated content

### Dependencies
- **Required:** Node.js >= 20.19.0, Claude API, js-yaml, ajv, ajv-keywords, ajv-formats
- **Optional:** examark (Canvas QTI), quarto, texlive

---

## Testing Strategy

### Unit Tests
- All components in `src/teaching/` must have corresponding tests
- Use fixtures for sample exams, configs, templates
- Mock Claude API responses for deterministic testing

### Integration Tests
- Test command → output pipeline
- Test config discovery (parent directory search)
- Test format conversions (md/qmd/tex/json)

### E2E Tests
- Standalone tests (no flow-cli required)
- Mock `.flow/teach-config.yml` for testing
- Validate generated files compile/render (LaTeX, Quarto)

### Cross-Platform & CI
- Always use POSIX-compatible syntax in shell scripts and test commands. Avoid macOS-specific flags (e.g., `stat -f %Lp`) — ensure scripts work on both macOS and Ubuntu CI runners
- Before committing, run the project's pre-commit hooks or lint checks manually. If a hook fails, fix and re-stage — do not bypass hooks
- **Worktree node:test setup:** Jest finds dependencies via npx's cache, but `node --test` uses strict Node.js resolution and requires `node_modules` locally. When running node:test suites from a worktree (not inside the main repo tree), create a symlink: `ln -s /path/to/main-repo/node_modules ./node_modules`

---

## Configuration

### `.flow/teach-config.yml` Structure
```yaml
scholar:
  course_info:
    level: "undergraduate"  # or "graduate"
    field: "statistics"
    difficulty: "intermediate"  # "beginner", "intermediate", "advanced"

  defaults:
    exam_format: "markdown"      # md, qmd, tex, json
    lecture_format: "quarto"
    question_types:
      - "multiple-choice"
      - "short-answer"
      - "essay"

  style:
    tone: "formal"               # "formal", "conversational"
    notation: "statistical"      # LaTeX math notation style
    examples: true               # Include worked examples
```

---

## Common Tasks

### Create a New Teaching Command
1. Start on `dev` branch
2. Create template in `src/teaching/templates/<command>.json`
3. Create worktree: `git worktree add ~/.git-worktrees/scholar-<command> -b feature/<command>`
4. Implement command in `src/teaching/commands/<command>.js`
5. Add formatters for all formats (md/qmd/tex/json)
6. Write unit tests in `tests/teaching/<command>.test.js`
7. Test manually with real topics
8. Before merging, update all four integration points:
   - `src/discovery/index.js` — add to `TEACHING_SUBCATEGORY_MAP`
   - `tests/discovery/discovery.test.js` — update hardcoded counts
   - `.github/workflows/ci.yml` — update minimum count + add file check
   - `mkdocs.yml` — update `command_count`, `teaching_commands`
9. Delete `src/discovery/cache.json` and re-run `npm run test:discovery`
10. Rebase and merge to `dev`

### Add a New Output Format
1. Create formatter in `src/teaching/formatters/<format>.js`
2. Implement `format(content, template)` method
3. Add format to all command handlers
4. Add conversion tests
5. Update documentation

### Debug AI Generation Issues
1. Enable debug logging: `--debug` flag
2. Check prompt engineering in `src/teaching/ai/prompts.js`
3. Verify template structure matches expected output
4. Check validation errors in `src/teaching/validators/`

---

## References

### v2.9.0 MkDocs Macros + Version Sync
- **What's New:** `docs/WHATS-NEW-v2.9.0.md`
- **Version Sync Guide:** `docs/internal/version-sync.md`
- **Spec:** `docs/specs/SPEC-2026-02-09-mkdocs-macros-version-sync.md`

### v2.8.0 Slide Revision & Validation
- **What's New:** `docs/WHATS-NEW-v2.8.0.md`

### v2.7.0 Scholar Hub
- **What's New:** `docs/WHATS-NEW-v2.7.0.md`

### v2.6.0 Config-Flow Integration
- **What's New:** `docs/WHATS-NEW-v2.6.0.md`

### v2.5.0 Weekly Lecture Production
- **What's New:** `docs/WHATS-NEW-v2.5.0.md`
- **Pipeline Diagrams:** `docs/LECTURE-PIPELINE-DIAGRAMS.md`

### v2.4.0 Prompt Discovery
- **What's New:** `docs/WHATS-NEW-v2.4.0.md`

### Architecture
- **Diagrams:** `docs/ARCHITECTURE-DIAGRAMS.md`
- **API Reference:** `docs/API-REFERENCE.md`

### General
- **Status:** `.STATUS` file (track progress)
- **Changelog:** `CHANGELOG.md`
- **Docs site:** https://Data-Wise.github.io/scholar/

---

## Version Sync & Releases

Scholar uses a two-layer version sync system:

- **MkDocs macros** (`{{ scholar.version }}`) — ~30 doc files, rendered at build time
- **`scripts/version-sync.js`** — 12 files with `render_macros: false` or non-docs files
- **Source of truth:** `package.json` version → synced to `mkdocs.yml extra.scholar.*` → consumed by both layers
- **Usage:** `node scripts/version-sync.js [--version X.Y.Z] [--tests N] [--dry-run]`
- **On release:** update `mkdocs.yml` manual fields first (command counts, suite count), then run sync script
- **After any version bump**, grep the entire codebase for hardcoded version strings, subcommand counts, and test assertion constants that may need updating. Check: VERSION constants, test fixture counts, dogfood test expectations, CLI help text, and `homebrew-release.yml` counts

---

## Documentation Updates

- After completing code changes, always update all related documentation: help pages, changelogs, status docs, tutorials, and test count references. Use `grep -r` to find all files referencing changed functionality
- When running bulk documentation updates across many files, always run the full lint/link-check suite immediately after edits and before committing: `npx markdownlint docs/ && npx markdown-link-check docs/**/*.md`
- Watch for duplicate headings, broken cross-references, and incorrect lint targets (e.g., don't lint YAML config files as markdown)
- Typical doc update scope: ~15 files across `docs/`, `site/`, `README.md`, and man pages

## Canvas & QMD Integration Notes

When working with the Canvas pipeline (`/teaching:canvas`, `CanvasFormatter`, `qmd-exam.js`):

- **Type naming is hyphen-separated:** `multiple-choice`, `true-false`, `short-answer`, `fill-in-blank`, `fill-in-multiple-blanks`, `numerical`, `matching`, `essay`. Never use underscores — these silently fail all type checks.
- **Answers live in `exam.answer_key[q.id]`**, not in `q.options[].isCorrect`. QMD-parsed options are plain strings; `isCorrect` is an AI-generated JSON convention only.
- **`q.id` already contains the `Q` prefix** (e.g. `"Q3"`). Wrapping it in a `Q`-prefixed template literal produces `"QQ3"`.
- **`examark emulate-canvas` is not a pass/fail gate.** It exits non-zero for essay/short-answer questions with no predefined answer — which Canvas handles fine (manual grading). Use `examark verify` (validate) as the reliable structural correctness check; treat emulate as a supplementary hint.
- **Regex tokenizer pattern:** Use `[...input.matchAll(pattern)].map(m => ...)` for quoted-string tokenization. The security hook flags the older `while (match = regex.runMatch(input))` style — `matchAll` is the hook-safe equivalent.

---

## Notes for Claude Code

- **Never commit directly to `main`** - Always use PR workflow
- **Verify branch before commits** - Use `git branch --show-current`
- **Use worktrees for features** - Keep `dev` clean for planning
- **Conventional commits** - Use proper commit message format
- **Test before merge** - Run test suite before integrating to `dev`
