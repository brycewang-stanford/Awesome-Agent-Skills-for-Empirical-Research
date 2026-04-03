# Scholar Plugin

> **Academic workflows for research and teaching** - Literature management, manuscript writing, simulation studies, course material generation, and 17 A-grade research skills

A comprehensive Claude Code plugin for academic workflows combining research and teaching. Features unified Plugin + MCP architecture with 33 slash commands and research skills.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.17.0-blue.svg)](https://github.com/Data-Wise/scholar/releases/tag/v2.17.0)
[![Tests](https://img.shields.io/badge/tests-3340%20passing-brightgreen.svg)](https://github.com/Data-Wise/scholar)

---

## Features

### 📚 31 Slash Commands

**Literature Management (4 commands)**
- `/arxiv <query>` - Search arXiv for papers (top-level command)
- `/doi <doi>` - Look up paper metadata by DOI (top-level command)
- `/bib:search <query>` - Search BibTeX files for entries
- `/bib:add <file>` - Add BibTeX entries to bibliography

**Manuscript Writing (4 commands)**
- `/manuscript:methods` - Write methods sections
- `/manuscript:results` - Write results sections
- `/manuscript:reviewer` - Generate reviewer responses
- `/manuscript:proof` - Review mathematical proofs

**Simulation Studies (2 commands)**
- `/simulation:design` - Design Monte Carlo studies
- `/simulation:analysis` - Analyze simulation results

**Research Planning (4 commands)**
- `/scholar:lit-gap <topic>` - Identify literature gaps
- `/scholar:hypothesis <topic>` - Generate research hypotheses
- `/scholar:analysis-plan` - Create statistical analysis plans
- `/scholar:method-scout <problem>` - Scout statistical methods for research problems

**Teaching (15 commands)**
- `/teaching:quiz <topic>` - Generate quiz questions with answer keys ✅
- `/teaching:exam <type>` - Create comprehensive exams with rubrics ✅
- `/teaching:assignment <topic>` - Create homework assignments with solutions ✅
- `/teaching:solution <file>` - Generate standalone solution keys from assignment files ✅ NEW
- `/teaching:syllabus <course>` - Generate comprehensive course syllabus ✅
- `/teaching:slides <topic>` - Create lecture slides with examples ✅
- `/teaching:rubric <type>` - Generate detailed grading rubrics ✅
- `/teaching:feedback <assignment>` - Generate constructive student feedback ✅
- `/teaching:demo [path]` - Create demo course environment with sample materials ✅
- `/teaching:lecture <topic>` - Generate comprehensive lecture notes ✅
- `/teaching:validate <file>` - Validate YAML configuration files (multi-level) ✅
- `/teaching:diff <file>` - Compare YAML and JSON sync status ✅
- `/teaching:sync [options]` - Synchronize YAML to JSON ✅
- `/teaching:migrate` - Batch migrate YAML configs from v1 to v2 schema ✅
- `/teaching:config <subcommand>` - Manage prompts, config, and provenance ✅ NEW

**Command Discovery (1 command)**
- `/scholar:hub [argument]` - Browse all commands, drill into categories, get usage details ✅ NEW

### 🎯 17 A-Grade Skills

Skills automatically activate when relevant to your work:

**Mathematical (4 skills)**
- `proof-architect` - Rigorous proof construction and validation
- `mathematical-foundations` - Statistical theory foundations
- `identification-theory` - Parameter identifiability analysis
- `asymptotic-theory` - Large-sample theory

**Implementation (5 skills)**
- `simulation-architect` - Monte Carlo study design
- `algorithm-designer` - Statistical algorithm development
- `numerical-methods` - Numerical optimization and computation
- `computational-inference` - Computational statistical inference
- `statistical-software-qa` - Statistical software quality assurance

**Writing (3 skills)**
- `methods-paper-writer` - Statistical methods manuscripts
- `publication-strategist` - Journal selection and positioning
- `methods-communicator` - Clear statistical communication

**Research (5 skills)**
- `literature-gap-finder` - Research gap identification
- `cross-disciplinary-ideation` - Cross-field method transfer
- `method-transfer-engine` - Adapting methods across domains
- `mediation-meta-analyst` - Mediation analysis meta-analysis
- `sensitivity-analyst` - Sensitivity analysis design

### 🔧 Shell API Wrappers

Lightweight shell-based APIs for research tools:
- `arxiv-api.sh` - arXiv paper search and PDF download
- `crossref-api.sh` - DOI lookup and BibTeX retrieval
- `bibtex-utils.sh` - BibTeX file search, add, format

### 🏗️ Architecture

**Unified Plugin + MCP Pattern:**
- `src/core/` - Framework-agnostic business logic
- `src/plugin-api/` - Claude Plugin commands and skills
- `src/mcp-server/` - MCP Protocol tools
- `lib/` - External API wrappers (arXiv, Crossref, BibTeX)

This architecture eliminates IPC overhead by sharing core logic directly between both APIs.

**Phase 0 Foundation + Teaching Commands:**
- `src/teaching/templates/` - Template system (exam, quiz, assignment, syllabus, lecture)
- `src/teaching/generators/` - AI-powered content generation
- `src/teaching/config/` - Configuration management
- `src/teaching/validators/` - Multi-layer validation (Schema + LaTeX + Completeness)
- `src/teaching/ai/` - AI content generation with retry logic
- `tests/teaching/` - 3,340 unit tests (100% passing)

See [Phase 0 Architecture](docs/architecture/PHASE-0-FOUNDATION.md) for detailed documentation.

---

## Installation

Scholar is a **pure plugin** with no MCP server dependencies. It works immediately after installation in both Claude Code CLI and Claude Desktop app.

### Option 1: Homebrew (Recommended - macOS)

```bash
# Add the Data-Wise tap
brew tap data-wise/tap

# Install scholar plugin
brew install scholar

# Or upgrade existing installation
brew upgrade scholar
```

The Homebrew formula automatically:
- Installs the plugin to `~/.claude/plugins/scholar`
- Syncs Claude Code's plugin cache (new features available immediately)
- Makes it available in Claude Code CLI and Claude Desktop
- No additional configuration needed

**Latest version:** v2.17.0 (released 2026-02-09)
- 33 commands (18 teaching + 14 research + 1 hub)
- 3,340 tests with 100% pass rate
- Comprehensive documentation (95% coverage)

### Option 2: Manual Installation (Local Development)

**For Claude Code CLI and Claude Desktop:**

```bash
# Clone the repository
git clone https://github.com/Data-Wise/scholar.git
cd scholar

# Install in development mode (symlink - changes reflected immediately)
./scripts/install.sh --dev

# Or install in production mode (copy - stable)
./scripts/install.sh
```

**Installation locations:**
- Plugin directory: `~/.claude/plugins/scholar`
- Commands: `~/.claude/plugins/scholar/src/plugin-api/commands/`
- Skills: `~/.claude/plugins/scholar/src/plugin-api/skills/`
- Shell APIs: `~/.claude/plugins/scholar/lib/`

### Option 3: npm (Future - Not yet published)

```bash
# When published to npm (future release):
npm install -g @data-wise/scholar
scholar-install  # Installs plugin to ~/.claude/plugins/
```

### Verify Installation

```bash
# Check plugin directory exists
ls -la ~/.claude/plugins/scholar

# Verify plugin.json
cat ~/.claude/plugins/scholar/.claude-plugin/plugin.json

# Run test suite (if installed from source)
cd ~/projects/dev-tools/scholar
./tests/test-plugin-structure.sh
```

**Expected output:**
```
✅ All tests passed (10/10)
- Plugin structure valid
- 33 commands present (18 teaching + 14 research + 1 hub)
- 17 skills present
- No hardcoded paths
- v2.17.0 verified
```

### Using in Claude Code CLI

After installation, commands are immediately available:

```bash
# Start Claude Code in any directory
claude

# Use scholar commands
/arxiv "bootstrap mediation"
/teaching:syllabus "Statistics 101"
/doi "10.1037/met0000165"
```

### Using in Claude Desktop App

Scholar automatically loads when you open Claude Desktop. Commands work the same way:

1. Open Claude Desktop app
2. Start a new conversation
3. Use slash commands: `/arxiv`, `/teaching:syllabus`, etc.

### MCP Server Setup

**Scholar does NOT require any MCP server configuration.**

Unlike plugins like rforge that depend on MCP servers, Scholar uses shell-based API wrappers (`lib/arxiv-api.sh`, `lib/crossref-api.sh`, `lib/bibtex-utils.sh`) for external services.

**Benefits of pure plugin approach:**
- ✅ Faster startup (no IPC overhead)
- ✅ Simpler installation (no server configuration)
- ✅ More portable (works anywhere Claude Code/Desktop runs)
- ✅ Self-contained (all dependencies included)

**Future MCP integration (Phase 2):**
In a future release, Scholar may optionally integrate with an MCP server for advanced features like:
- R execution for statistical analysis
- Zotero library integration
- LaTeX compilation

This will be **optional** - all current commands will continue to work without MCP.

This is planned for a future release.

---

## Quick Start

### Literature Search

```bash
# Search arXiv
/arxiv "bootstrap mediation analysis"

# Look up specific paper
/doi "10.1080/00273171.2014.962683"

# Search your BibTeX files
/bib:search "mediation"
```

### Manuscript Writing

```bash
# Generate methods section
/manuscript:methods

# Write results section with statistical details
/manuscript:results

# Respond to reviewer comments
/manuscript:reviewer
```

### Teaching

```bash
# Create course syllabus
/teaching:syllabus "Introduction to Statistics"

# Generate homework assignment
/teaching:assignment "Linear Regression"

# Create grading rubric
/teaching:rubric "data analysis project"
```

### Research Planning

```bash
# Identify literature gaps
/scholar:lit-gap "causal mediation analysis"

# Generate hypotheses
/scholar:hypothesis "mediation moderation"

# Create analysis plan
/scholar:analysis-plan
```

---

## Command Reference

### Literature Management

#### `/arxiv <query> [limit]`
Search arXiv for papers matching your query.

**Examples:**
```bash
/arxiv "bootstrap mediation"
/arxiv "causal inference" 20
```

**Output:** Title, authors, arXiv ID, publication date, abstract preview

**Follow-up Actions:** Get full details, download PDF, add BibTeX entry

---

#### `/doi <doi>`
Look up paper metadata by DOI using Crossref API.

**Examples:**
```bash
/doi "10.1037/met0000165"
/doi 10.1080/00273171.2014.962683
```

**Output:** Full citation, BibTeX entry, journal information

---

#### `/bib:search <query>`
Search BibTeX files in your project for entries matching keywords.

**Examples:**
```bash
/bib:search "mediation"
/bib:search "Baron Kenny"
```

**Output:** Matching BibTeX entries with citation keys

---

#### `/bib:add <file>`
Add BibTeX entries to your bibliography file.

**Examples:**
```bash
/bib:add references.bib
```

---

### Manuscript Writing

#### `/manuscript:methods`
Generate a methods section for statistical manuscript.

**Includes:**
- Study design description
- Statistical methods with mathematical notation
- Software and implementation details
- Assumptions and diagnostics

---

#### `/manuscript:results`
Write a results section with statistical findings.

**Includes:**
- Descriptive statistics
- Model fit and diagnostics
- Parameter estimates with uncertainty
- Interpretation in context

---

#### `/manuscript:reviewer`
Generate responses to reviewer comments.

**Features:**
- Point-by-point responses
- Additional analyses if requested
- Clarifications and revisions
- Professional academic tone

---

#### `/manuscript:proof`
Review mathematical proofs in manuscript for correctness and clarity.

---

### Simulation Studies

#### `/simulation:design`
Design a Monte Carlo simulation study.

**Includes:**
- Data generation mechanisms
- Estimator implementations
- Performance metrics
- Parallelization strategy

---

#### `/simulation:analysis`
Analyze simulation results and create summary tables.

**Output:**
- Bias, variance, MSE, coverage
- Publication-quality tables
- Convergence diagnostics

---

### Research Planning

#### `/scholar:lit-gap <topic>`
Identify gaps in literature for a research area.

**Output:**
- Current state of literature
- Identified gaps and opportunities
- Potential research questions

---

#### `/scholar:hypothesis <topic>`
Generate testable research hypotheses.

**Output:**
- Theoretical hypotheses
- Statistical hypotheses
- Expected findings

---

#### `/scholar:analysis-plan`
Create a comprehensive statistical analysis plan.

**Includes:**
- Research questions
- Statistical methods
- Sample size justification
- Analysis workflow

---

### Teaching Commands

#### Universal Options (All Teaching Commands)

All teaching commands support the `--config` flag to explicitly specify a configuration file path:

```bash
/teaching:quiz "Linear Regression" --config /path/to/config.yml
/teaching:exam midterm --config .flow/teach-config.yml
```

**When to use `--config`:**
- Integration with automation tools (e.g., flow-cli)
- Using non-standard config locations
- Testing with different configurations
- CI/CD pipelines

**Behavior:**
- **With `--config`:** Loads the specified YAML file directly (skips parent directory search)
- **Without `--config`:** Searches parent directories for `.flow/teach-config.yml` (default)
- **Validation:** Lenient mode (warnings only) to avoid blocking workflow automation
- **Debug:** Use `[scholar:config]` prefix in logs to track config source

**Example workflow integration:**
```bash
# flow-cli passes explicit config path
claude --print "/teaching:exam Midterm --config $(pwd)/.flow/teach-config.yml"
```

---

#### `/teaching:quiz <topic> [options]`
Generate quiz questions with answer keys.

**Examples:**
```bash
/teaching:quiz "Linear Regression"
/teaching:quiz "Hypothesis Testing" --questions 10 --type practice
```

**Options:**
- `--questions N` - Number of questions (default: 5)
- `--type TYPE` - Quiz type: reading, practice, checkpoint, pop, review
- `--duration N` - Duration in minutes (default: 15)
- `--difficulty LEVEL` - beginner, intermediate, advanced

**Output Formats:** markdown, json, canvas (QTI)

---

#### `/teaching:exam <type> [options]`
Create comprehensive exams with rubrics.

**Examples:**
```bash
/teaching:exam midterm --questions 20 --duration 90
/teaching:exam final --topics "regression,ANOVA,hypothesis testing"
```

**Options:**
- `--type TYPE` - midterm, final, practice, comprehensive
- `--questions N` - Number of questions
- `--duration N` - Duration in minutes
- `--topics "t1,t2"` - Specific topics to cover

**Output:** JSON with questions, answer key, grading rubric

---

#### `/teaching:assignment <topic> [options]`
Create homework assignments and problem sets.

**Examples:**
```bash
/teaching:assignment "Linear Regression"
/teaching:assignment homework --problems 5 --difficulty intermediate
/teaching:assignment lab --topic "Bootstrap Methods" --include-code
```

**Options:**
- `--type TYPE` - homework, problem-set, lab, project, worksheet
- `--problems N` - Number of problems (default: 5)
- `--points N` - Total points (default: 100)
- `--include-code` - Include programming problems
- `--language R|Python` - Programming language

**Output:** JSON with problems, solutions, grading rubric

---

#### `/teaching:syllabus <course> [semester]`
Generate a comprehensive course syllabus.

**Examples:**
```bash
/teaching:syllabus "Introduction to Statistics"
/teaching:syllabus "Regression Analysis" "Fall 2026"
```

**Options:**
- `--weeks N` - Number of weeks (default: 16)
- `--level LEVEL` - undergraduate, graduate, doctoral
- `--format FORMAT` - in-person, online, hybrid

**Output Formats:** markdown, json, latex, html

**Includes:**
- Course and instructor information
- Learning objectives (measurable, action verbs)
- Grading policy with scale
- Week-by-week schedule
- Standard policies (academic integrity, accessibility, etc.)

---

#### `/teaching:slides <topic> [duration]`
Create lecture slides with examples.

**Examples:**
```bash
/teaching:slides "Multiple Regression"
/teaching:slides "Hypothesis Testing" 75
/teaching:slides "ANOVA" --format reveal
```

**Options:**
- `--duration N` - Duration in minutes (default: 50)
- `--format FORMAT` - markdown, reveal, beamer, quarto
- `--include-code` - Include code examples
- `--subtopics "t1,t2"` - Specific subtopics

**Slide Count by Duration:**
- 50 min → ~20 slides
- 75 min → ~30 slides
- 90 min → ~36 slides

**Output:** Slides with speaker notes, organized by type (title, objectives, content, example, practice, summary)

---

#### `/teaching:rubric <assignment-type> [points]`
Generate detailed grading rubrics.

**Examples:**
```bash
/teaching:rubric "data analysis project"
/teaching:rubric "research paper" 100
```

**Includes:**
- Clear criteria for each performance level
- Point allocations
- Observable, measurable descriptors

---

#### `/teaching:validate <file> [options]`
Validate YAML configuration files against schema.

**Examples:**
```bash
/teaching:validate .flow/teach-config.yml
/teaching:validate content/lesson-plans/week03.yml
/teaching:validate --all  # Validate all YAML files in project
```

**Options:**
- `--all` - Validate all YAML configs in project
- `--strict` - Strict validation mode (errors on warnings)
- `--quiet` - Suppress warnings, errors only

**Validation Levels:**
1. **YAML Syntax** - Valid YAML structure (indentation, colons, quotes)
2. **JSON Schema** - Conforms to teach-config or lesson-plan schema
3. **LaTeX Validation** - Math notation compiles (`$...$`, `$$...$$`)
4. **Completeness** - Required fields present (course_info, defaults, style)

**Output Format:**
```
IDE-style error messages:
  file:line:col: error message
  file:line:col: warning message

Summary:
  ✅ Validation passed (0 errors, 2 warnings)
  ❌ Validation failed (3 errors, 1 warning)
```

**Use Cases:**
- Pre-commit validation (ensure configs are valid before commit)
- CI/CD pipelines (block deploys with invalid configs)
- Development debugging (find syntax errors quickly)
- Migration testing (validate after schema upgrades)

**Exit Codes:**
- `0` - Validation passed
- `1` - Validation failed (errors found)
- `2` - File not found or YAML parse error

---

#### `/teaching:diff <file> [options]`
Compare YAML and JSON sync status.

**Examples:**
```bash
/teaching:diff teach-config.yml
/teaching:diff content/lesson-plans/week03.yml
/teaching:diff --all  # Check sync status for all configs
```

**Options:**
- `--all` - Check sync status for all YAML/JSON pairs
- `--verbose` - Show detailed diff output
- `--json` - Output sync status as JSON

**Output:**
```json
{
  "file": "teach-config.yml",
  "inSync": true,
  "yamlHash": "a3b2c1d4...",
  "jsonHash": "a3b2c1d4...",
  "lastSync": "2026-01-15T10:30:00Z",
  "cacheAge": "5m 30s"
}
```

**Sync States:**
- ✅ **In Sync** - YAML and JSON match (identical hashes)
- ⚠️ **Out of Sync** - YAML changed, JSON needs update
- ❌ **Missing JSON** - JSON file doesn't exist (run `/teaching:sync`)
- ❌ **Invalid YAML** - YAML has syntax/schema errors

**Use Cases:**
- Verify sync before command execution
- Debug sync issues (stale cache, missing JSON)
- CI/CD validation (ensure configs are synced)
- Pre-deployment checks

**Performance:**
- Hash comparison: ~5ms per file
- Cache lookup: ~2ms per file
- No file parsing (hash-based only)

---

#### `/teaching:sync [file] [options]`
Synchronize YAML to JSON (manual trigger).

**Examples:**
```bash
/teaching:sync                        # Sync all YAML files in project
/teaching:sync teach-config.yml      # Sync specific file
/teaching:sync --force                # Force re-sync (ignore cache)
```

**Options:**
- `--force` - Force re-sync (bypass hash check, rewrite all JSON)
- `--dry-run` - Preview sync without writing files
- `--verbose` - Show detailed sync progress

**Sync Process:**
1. **Find YAML** - Locate all `*.yml` files in `.flow/` and `content/`
2. **Hash Check** - Compare SHA-256 hash with cache (skip if unchanged)
3. **Validate** - 4-level validation (YAML, schema, LaTeX, completeness)
4. **Parse** - Parse YAML to JSON
5. **Write** - Write JSON to same directory as YAML
6. **Cache** - Update `.scholar-cache/sync-status.json` with new hash

**Performance:**
- Unchanged files: ~5ms (hash check only)
- Changed files: ~80ms (parse + validate + write)
- Typical project (10 files): ~150ms total

**Output:**
```
Syncing 10 YAML files...

✅ teach-config.yml → teach-config.json (80ms)
⏭️ week01.yml (unchanged, skipped)
⏭️ week02.yml (unchanged, skipped)
✅ week03.yml → week03.json (75ms)
❌ week04.yml (validation failed, see errors below)

Summary:
  2 synced, 2 skipped, 1 failed
  Total time: 155ms
```

**Automatic Sync Triggers:**
- Pre-command hook (before Scholar commands run)
- Pre-commit hook (before git commits)
- GitHub Actions (on CI/CD push)

**Manual Sync When:**
- Testing config changes before committing
- Debugging sync issues (stale cache, corrupt JSON)
- Forcing full re-sync after cache corruption

**Cache Location:**
```
.scholar-cache/
  sync-status.json    # Hash tracking, sync timestamps
```

**Error Handling:**
- Validation errors block sync (prevents broken JSON)
- Missing YAML files are skipped (warnings only)
- Corrupt cache is auto-rebuilt on next sync

---

#### `/teaching:migrate [options]`
Migrate YAML configuration files from v1 to v2 schema with atomic batch migration.

**Examples:**
```bash
/teaching:migrate --detect              # Find v1 files with complexity
/teaching:migrate --dry-run             # Preview migration changes
/teaching:migrate                       # Apply migration with git commit
/teaching:migrate --file week-01.yml    # Migrate single file
/teaching:migrate --no-git              # Apply without git commit
```

**Modes:**
- `--detect` - Find v1 schema files and show complexity scoring (0-10)
- `--dry-run` - Preview colored diffs without modifying files
- Default mode - Apply migration with git commit automation
- `--file <path>` - Migrate specific file only

**Options:**
- `--no-git` - Skip git commit (still applies migration)
- `--no-git-check` - Skip git safety check (dangerous - may lose uncommitted work)
- `--patterns <glob>` - Custom glob patterns (comma-separated)
- `--debug` - Enable debug logging

**Features:**
- **Atomic semantics** - All-or-nothing migration with rollback
- **Git integration** - Automated commits with descriptive messages
- **Git safety** - Checks for uncommitted changes before migration
- **Complexity scoring** - Helps prioritize migration effort
- **Security hardened** - Uses `execFileNoThrow` (prevents command injection)

**Complexity Categories:**
- Simple (0-3): Few field renames
- Medium (4-6): Multiple renames + type conversions
- Complex (7-10): Many changes + nested structures

**Rollback Guarantee:**
- In-memory backups of all files
- Automatic rollback on any failure
- Restores exact original content

**Output:**
```
Found 12 v1 schema files

Step 1: Detecting v1 schema files...
Step 2: Checking git status...
Step 3: Migrating files...

[1/12] week-01.yml... ✅
[2/12] week-02.yml... ✅
...

✓ Migration complete!
Processed: 12 files
Commit: abc123

Next steps:
  1. Review changes: git show abc123
  2. Validate configs: /teaching:validate
  3. Push to remote: git push
```

---

## Skills Reference

Skills automatically activate based on context. See `src/plugin-api/skills/README.md` for detailed documentation of all 17 A-grade skills.

**When do skills activate?**
- Writing methods → `methods-paper-writer`, `methods-communicator`
- Designing simulations → `simulation-architect`, `numerical-methods`
- Mathematical proofs → `proof-architect`, `mathematical-foundations`
- Literature review → `literature-gap-finder`, `cross-disciplinary-ideation`

---

## Architecture Details

### Unified Plugin + MCP Pattern

```
scholar/
├── src/
│   ├── core/              # Business logic (framework-agnostic)
│   │   ├── literature/    # Literature search, metadata
│   │   ├── manuscript/    # Writing assistance
│   │   └── teaching/      # Course material generation ⭐ NEW
│   │       ├── ai/        # AI provider with retry logic
│   │       ├── config/    # Configuration loader
│   │       ├── templates/ # Template system
│   │       └── validators/# Validation engine
│   ├── plugin-api/        # Claude Plugin commands/skills
│   │   ├── commands/
│   │   │   ├── literature/
│   │   │   ├── manuscript/
│   │   │   └── teaching/  # Teaching commands (Phase 2+)
│   │   └── skills/
│   └── mcp-server/        # MCP Protocol tools (future)
├── lib/                   # External API wrappers
│   ├── arxiv-api.sh
│   ├── crossref-api.sh
│   └── bibtex-utils.sh
├── tests/                 # Test suite
│   └── teaching/          # 2,252 tests ⭐
└── scripts/               # Installation scripts
```

**Benefits:**
- No IPC overhead (shared core library)
- Single source of truth for business logic
- Both APIs consume the same tested code
- Easy to maintain and extend
- Teaching foundation ready for command implementation

**Phase 0 Components (Complete):**
- **Template System** - Base schemas with inheritance and auto-field injection
- **Config Loader** - Parent directory search for `.flow/teach-config.yml`
- **Validator Engine** - Multi-layer validation (JSON Schema + LaTeX + Completeness)
- **AI Provider** - Content generation with retry logic and rate limiting

See [Phase 0 Architecture Documentation](docs/architecture/PHASE-0-FOUNDATION.md) for details.

---

## Configuration & Sync Management

### YAML ↔ JSON Workflow (v2.2.0)

Scholar v2.2.0 introduces a **dual-config system** where you write YAML configs (human-friendly) and Scholar automatically maintains JSON files (machine-optimized) with sub-100ms sync latency.

#### How It Works

```
┌─────────────────┐         ┌──────────────────┐
│  YAML (source)  │ ────→   │  JSON (auto)     │
│  You edit this  │  sync   │  Never edit this │
└─────────────────┘         └──────────────────┘
     teach-config.yml            teach-config.json
```

**Key Principles:**
- **YAML = Source of Truth** - Edit only YAML files
- **JSON = Generated** - Auto-synced from YAML (gitignored)
- **Fast Sync** - Hash-based change detection (< 100ms)
- **Safe** - Validation errors prevent broken configs

#### Automatic Sync Triggers

Sync happens automatically in these scenarios:

1. **Before Command Execution** - Pre-command hook ensures configs are synced
2. **Pre-Commit Hook** - Git hook validates and syncs before commits
3. **CI/CD Pipeline** - GitHub Actions workflow validates schemas

#### Manual Sync Commands

```bash
# Sync YAML to JSON
/teaching:sync

# Check sync status
/teaching:diff teach-config.yml

# Validate YAML schema
/teaching:validate teach-config.yml
```

#### Hash-Based Change Detection

Scholar uses SHA-256 hashing to skip unchanged files:

```
.scholar-cache/
  sync-status.json    # Tracks file hashes and sync timestamps
```

**Performance:**
- Changed files: Parse + Validate + Write JSON (~80ms)
- Unchanged files: Hash check only (~5ms)
- Cache invalidation: Automatic on YAML modification

#### Directory Structure

```
course-repo/
├── .flow/
│   ├── teach-config.yml        # YAML config (source)
│   └── teach-config.json       # JSON config (auto-generated)
├── .scholar-cache/
│   └── sync-status.json        # Hash tracking
├── content/
│   └── lesson-plans/
│       ├── week01.yml          # YAML lesson plan (source)
│       └── week01.json         # JSON lesson plan (auto-generated)
└── .gitignore                  # Excludes *.json and .scholar-cache/
```

#### Validation Levels

Scholar performs 4-level validation during sync:

1. **YAML Syntax** - Valid YAML structure
2. **JSON Schema** - Conforms to teach-config schema
3. **LaTeX Validation** - Math notation compiles
4. **Completeness** - Required fields present

**Error Handling:**
- Validation errors block sync (prevents broken configs)
- IDE-style error output: `file:line:col: message`
- Lenient mode with `--config` flag (warnings only)

#### GitHub Actions Integration

Automate validation in CI/CD:

```yaml
# .github/workflows/validate.yml
- name: Validate Configs
  run: |
    npm install -g @data-wise/scholar
    scholar validate .flow/teach-config.yml
```

See `docs/github-actions-setup.md` for complete workflow examples.

#### Migration from v2.1.0

**Before v2.2.0:**
```bash
# Edit YAML, manually convert to JSON
vim .flow/teach-config.yml
# (manual conversion required)
```

**With v2.2.0:**
```bash
# Edit YAML, sync happens automatically
vim .flow/teach-config.yml
git add .flow/teach-config.yml   # Sync in pre-commit hook
```

See [MIGRATION-v2.2.0.md](docs/MIGRATION-v2.2.0.md) for detailed upgrade guide.

---

## Development

### Running Tests

```bash
cd scholar
./tests/test-plugin-structure.sh
```

**Test Coverage:**
- ✅ Required files present
- ✅ Valid JSON in plugin.json
- ✅ Directory structure
- ✅ 17+ commands exist
- ✅ Teaching commands present
- ✅ 15+ skills exist
- ✅ API wrappers present
- ✅ No hardcoded paths
- ✅ Valid command frontmatter

### Modifying Commands

Commands are in `src/plugin-api/commands/`. Each command is a markdown file with:

1. **YAML frontmatter** (name, description)
2. **User-facing documentation**
3. **`<system>` block** with implementation details

**Example:**
```markdown
---
name: arxiv
description: Search arXiv for papers
---

# Search arXiv

User-facing instructions here...

<system>
Implementation details for Claude...
</system>
```

### Adding New Commands

1. Create `.md` file in appropriate category directory
2. Add frontmatter with `name:` and `description:`
3. Write user-facing documentation
4. Add `<system>` block with implementation
5. Test: `/namespace:command "test input"`

---

## Roadmap

### Phase 0: Foundation (Complete ✅ 2026-01-11)
**Teaching Infrastructure Layer**
- ✅ Template system with inheritance and auto-fields
- ✅ Configuration loader with parent directory search
- ✅ Multi-layer validation (JSON Schema + LaTeX + Completeness)
- ✅ AI provider with retry logic and rate limiting

**Components:**
- `src/teaching/templates/` - Template system
- `src/teaching/config/` - Configuration management
- `src/teaching/validators/` - Validation engine
- `src/teaching/ai/` - AI content generation

**Documentation:**
- [Phase 0 Architecture](docs/architecture/PHASE-0-FOUNDATION.md)
- [Test Documentation](tests/README.md)

### Phase 1: MVP (Complete)
- ✅ 14 research commands from statistical-research
- ✅ 3 teaching commands (syllabus, assignment, rubric)
- ✅ 17 A-grade skills
- ✅ Shell API wrappers
- ✅ Unified directory structure
- ✅ Installation scripts
- ✅ Test suite

### Phase 2: Teaching Commands (Complete ✅ 2026-01-13)
**Core Teaching Commands - 2,252 tests, 100% passing**

- ✅ `/teaching:quiz` (33 tests)
  - Multiple question types (MC, true-false, short-answer, numerical)
  - Quiz types: reading, practice, checkpoint, pop, review
  - Canvas QTI export support
  - Conversational generation for Claude Max users

- ✅ `/teaching:exam` (existing)
  - Question bank generation
  - Answer key creation
  - LaTeX math support

- ✅ `/teaching:assignment` (41 tests)
  - Problem types: homework, problem-set, lab, project, worksheet
  - Multi-part problems with solutions
  - Grading rubrics with partial credit
  - Code problems support (R, Python)

- ✅ `/teaching:syllabus` (48 tests)
  - Course information and instructor details
  - Learning objectives (measurable, action verbs)
  - Grading policy with scale
  - Week-by-week schedule
  - Standard policies (academic integrity, accessibility)
  - Export: markdown, JSON, LaTeX, HTML

- ✅ `/teaching:slides` (50 tests)
  - Slide types: title, objectives, content, example, practice, summary
  - Duration-based slide count calculation
  - Speaker notes support
  - Export: markdown, reveal.js, beamer, quarto

**Pending Commands:**
- [ ] `/teaching:feedback` - Constructive student feedback
- [ ] `/teaching:rubric` - Enhanced with AI generation

### Phase 3: MCP Server Integration (Future)
- [ ] Implement MCP protocol tools in `src/mcp-server/`
- [ ] Add TypeScript/Zod schemas
- [ ] Test MCP server independently
- [ ] Integrate with Claude Desktop app

### Phase 4: Advanced Features (Future)
- [ ] LMS integration (Canvas, Blackboard)
- [ ] Export to PDF/Word formats
- [ ] Calendar integration
- [ ] Student roster management
- [ ] Real-time collaboration

---

## Contributing

Contributions are welcome! This is a standalone project focused on academic workflows.

**Development workflow:**
1. Fork the repository: https://github.com/Data-Wise/scholar
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Run tests: `./tests/test-plugin-structure.sh`
5. Commit with clear messages
6. Push and submit a pull request

**See also:**
- [claude-plugins monorepo](https://github.com/Data-Wise/claude-plugins) for shared tooling and standards
- [craft](https://github.com/Data-Wise/craft) and [rforge](https://github.com/Data-Wise/claude-plugins/tree/main/rforge) - Related projects

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Support

- **Issues:** https://github.com/Data-Wise/scholar/issues
- **Repository:** https://github.com/Data-Wise/scholar
- **Documentation:** See `docs/` directory for comprehensive guides

---

## Related Projects

- **[craft](https://github.com/Data-Wise/craft)** - Full-stack developer toolkit (86 commands, 8 agents, 21 skills)
- **[rforge](https://github.com/Data-Wise/claude-plugins/tree/main/rforge)** - R package ecosystem orchestrator with mode system
- **[claude-plugins](https://github.com/Data-Wise/claude-plugins)** - Shared tooling and plugin development standards

**Migration from older plugins:**
- `workflow` → Merged into craft (v1.17.0)
- `statistical-research` → Superseded by scholar (v1.0.0)

---

**Ready to use!** Try: `/arxiv "your research topic"`
