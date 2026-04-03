# Data Onboarding Mode

Data Onboarding mode is triggered when a user wants to profile raw data files and create a standalone data source skill. It produces a SKILL.md + reference files in `.claude/skills/` backed by a fully reproducible research project containing profiling scripts, QA reviews, and session state tracking.

## User Orientation

After mode confirmation, briefly orient the user. Key points:

- 3 phases: Setup, Profiling (4 parts of scripted analysis), Skill Creation
- 2 checkpoints where you review: after setup (to confirm scope) and after profiling (to confirm interpretations before they become part of the skill)
- You receive: a standalone data source skill ready for use in future analyses, plus a research project folder with all profiling evidence
- You need to provide: data file(s), source name, file format, and optionally any documentation, priority columns, and known exclusions
- Key characteristic: thorough automated profiling, but you review all interpretations before they are encoded into the skill
- Typical duration: a single session for files under 500 columns; larger files may require batched profiling across sessions

**When to skip:** User has completed a data onboarding before and indicates familiarity.

**For more detail:** Consult `{BASE_DIR}/user_reference/04_extending_daaf.md`.

---

## Scope

Data Onboarding is designed for **tabular datasets** — files with rows and columns in formats like CSV, TSV, Parquet, Excel, or row-oriented JSON. The profiling protocol examines column types, distributions, keys, and inter-column relationships that are specific to tabular data.

**Not designed for:** Spatial data (shapefiles, GeoPackage), deeply nested JSON/XML, graph databases, unstructured text corpora, or image/audio datasets. If your data is non-tabular, consider Ad Hoc Collaboration mode for a more flexible approach to understanding the data.

**Text-heavy tabular data:** If your dataset has columns with significant free-text content (e.g., survey open-ended responses, administrative notes), the profiling protocol will characterize these columns structurally (string lengths, null rates, unique counts) but does not perform text analysis (topic modeling, sentiment, etc.). Consider a Full Pipeline analysis for text-specific methodology.

---

## Data Onboarding Mode Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE DO-1: INTAKE & SETUP                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│  Stage DI-1: Initial Intake                                                 │
│      ├─ Collect: file path(s), format, source name, target skill name       │
│      ├─ Collect: domain context, documentation links, priority columns      │
│      ├─ Collect: known exclusions (populations/periods/geographies NOT in   │
│      │   the data — feeds analytical-context.md Population Coverage)        │
│      ├─ Determine access method:                                            │
│      │   ├─ LOCAL FILE — user provides file path(s) on disk                │
│      │   │   └─ Continue DI-1 (file structure classification below)        │
│      │   └─ API — user describes API endpoint(s)                           │
│      │       └─ Invoke PHASE DO-0 (see conditional side-phase below),      │
│      │          then resume DI-1 with downloaded file(s)                   │
│      ├─ Determine file structure (if multiple files provided):              │
│      │   ├─ SINGLE — one data file (default)                               │
│      │   ├─ HORIZONTAL — multiple files, same schema (e.g., one per year) │
│      │   └─ HIERARCHICAL — different schemas/levels, linked by keys        │
│      ├─ If HIERARCHICAL: collect entity descriptions and linking keys       │
│      ├─ Skill structure decision (multi-file only):                         │
│      │   ├─ UNIFIED — one skill for the whole source (default)             │
│      │   └─ PER-ENTITY — one skill per entity type                         │
│      ├─ Check for skill name conflict in .claude/skills/                     │
│      ├─ Verify file(s) accessible and non-empty (skip if API — DI-0 first) │
│      └─ Gate GDI-1: Required inputs collected, file(s) accessible           │
│                          ↓                                                  │
│  Stage DI-2: Project Setup                                                  │
│      ├─ Create research project folder under research/                       │
│      ├─ Copy raw data into research project data/raw/                        │
│      ├─ Initialize STATE.md from agent_reference/STATE_TEMPLATE_ONBOARDING.md   │
│      ├─ Initialize LEARNINGS.md                                             │
│      ├─ Verify {BASE_DIR}/scripts/run_with_capture.sh is accessible          │
│      └─ Gate GDI-2: Project folder ready, STATE.md initialized              │
└─────────────────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE DO-0: API DISCOVERY & ACQUISITION (CONDITIONAL — invoked from DI-1)   │
├─────────────────────────────────────────────────────────────────────────────┤
│  Stage DI-0: API Acquisition (only if access method = API)                 │
│      ├─ Triggered when DI-1 intake determines access method = API          │
│      ├─ Verify API key is set in environment; if missing → STOP with      │
│      │   setup instructions (see API Key Setup Guidance below)             │
│      ├─ DI-0a: WRITE PHASE — Invoke data-ingest (profiling_part = "DI-0") │
│      │   ├─ Agent researches API (WebFetch docs, WebSearch if needed)      │
│      │   ├─ Identifies endpoints, response format, pagination, rate limits │
│      │   ├─ Writes acquisition script: scripts/stage5_fetch/00_api-fetch.py│
│      │   └─ Returns: script path, API findings, confidence assessment     │
│      │   (Agent does NOT execute the script — returns after writing)       │
│      ├─ Orchestrator presents script to user for review and approval      │
│      │   ├─ Show: API endpoint, auth method, query params, save path      │
│      │   └─ User confirms or requests modifications                       │
│      ├─ DI-0b: EXECUTE PHASE — Orchestrator executes approved script      │
│      │   ├─ Execute via run_with_capture.sh                               │
│      │   ├─ Verify downloaded file is non-empty and loadable              │
│      │   └─ If execution fails: present error, allow user to adjust       │
│      └─ Gate GDI-0: File downloaded, accessible, non-empty                │
│                          ↓                                                  │
│  Feed downloaded file path(s) into DI-1 as the data file(s)                │
│  DI-1 resumes with downloaded file(s) for structure classification          │
│                                                                             │
│  NOTE: API + HIERARCHICAL combined case — if the user describes an API     │
│  with multiple endpoints at different levels (e.g., schools endpoint +      │
│  districts endpoint), invoke DI-0 once per endpoint. Each invocation       │
│  produces a separate 00{x}_api-fetch.py script (00a_, 00b_, etc.) and      │
│  a separate downloaded file. DI-1 then classifies file structure as        │
│  HIERARCHICAL with all downloaded files as inputs.                          │
└─────────────────────────────────────────────────────────────────────────────┘
                          ↓
            ┌──────────────────────────────────┐
            │  PSU-DI1: Setup Confirmation     │
            │  Present setup summary, profiling│
            │  plan; await user confirmation   │
            └──────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE DO-2: PROFILING & RECONCILIATION                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  Stage DI-3: Structural Profile (Part A — scripts 01-03, sequential)        │
│      ├─ 01: Format detection, encoding validation, canonical load pattern   │
│      ├─ 02: Row/column counts, memory footprint, types, schema             │
│      ├─ 03: Per-column statistics, value distributions, patterns           │
│      ├─ Code-reviewer QA loop (QAP1)                                        │
│      ├─ UPDATE STATE.md (Per-Part Execution Cycle Step 5)                  │
│      └─ Gate GDI-3: CPP1 PASSED, QAP1 PASSED/WARNING                       │
│                          ↓                                                  │
│  Stage DI-4: Statistical Profile (Part B — scripts 04-06)                   │
│      ├─ 04: Distribution profiling (always)                                 │
│      ├─ 05: Temporal analysis (conditional — if date/time columns found)    │
│      ├─ 06: Entity coverage (conditional — if entity/geo ID found)          │
│      ├─ Code-reviewer QA loop (QAP2)                                        │
│      ├─ UPDATE STATE.md (Per-Part Execution Cycle Step 5)                  │
│      └─ Gate GDI-4: CPP2 PASSED, QAP2 PASSED/WARNING                       │
│                          ↓                                                  │
│  Stage DI-5: Relational Analysis (Part C — scripts 07-09)                   │
│      ├─ 07: Key candidate identification (always)                           │
│      ├─ 08: Correlation/dependency (conditional — if >=3 numeric cols)      │
│      ├─ 09: Completeness, coded missing values, anomaly catalog (always)    │
│      ├─ Code-reviewer QA loop (QAP3)                                        │
│      ├─ UPDATE STATE.md (Per-Part Execution Cycle Step 5)                  │
│      └─ Gate GDI-5: CPP3 PASSED, QAP3 PASSED/WARNING                       │
│                          ↓                                                  │
│  Stage DI-6: Interpretation (Part D — scripts 10-11)                        │
│      ├─ 10: Column semantic classification (always)                         │
│      ├─ 11: Documentation reconciliation (conditional — if docs provided)   │
│      ├─ Code-reviewer QA loop (QAP4)                                        │
│      ├─ UPDATE STATE.md (Per-Part Execution Cycle Step 5)                  │
│      └─ Gate GDI-6: CPP4 PASSED, QAP4 PASSED/WARNING                       │
└─────────────────────────────────────────────────────────────────────────────┘
                          ↓
            ┌──────────────────────────────────┐
            │  PSU-DI2: Findings Review        │
            │  CRITICAL — user confirms or     │
            │  modifies interpretations before  │
            │  skill authoring proceeds         │
            └──────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE DO-3: SKILL AUTHORING & DELIVERY                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  Stage DI-7: Skill Authoring                                       │
│      ├─ Synthesize profiling results + user-confirmed interpretations       │
│      ├─ Create SKILL.md using DATA_SOURCE_SKILL_TEMPLATE.md                 │
│      ├─ Create reference files in .claude/skills/{skill-name}/references/   │
│      ├─ Compliance check: template (CPP-SKILL)                              │
│      └─ Gate GDI-7: CPP-SKILL PASSED                                       │
│                          ↓                                                  │
│  Stage DI-8: Review & Delivery                                              │
│      ├─ Collect session logs: collect_session_logs.sh                        │
│      ├─ Present completed skill to user for review                          │
│      ├─ Finalize STATE.md                                                   │
│      ├─ Consolidate LEARNINGS.md (review entries, populate key sections)     │
│      ├─ Add System Update Action Plan if generalizable learnings found       │
│      └─ Gate GDI-8: User confirms skill is acceptable                       │
└─────────────────────────────────────────────────────────────────────────────┘
                          ↓
                    Final Delivery
```

> **AUTHORITATIVE EXECUTION LOOP:** The Per-Part Execution Cycle referenced in each stage above (DI-3 through DI-6) is defined in full detail in the **Per-Part Execution Cycle** section below. That cycle is the MANDATORY atomic unit for all profiling work. The workflow diagram above is a visual summary; the Per-Part Execution Cycle is the binding specification.

> **Note:** The "DI-" prefix on stage identifiers (DI-1 through DI-8) is a historical abbreviation from when this mode was named "Data Ingest." The prefix is retained for backward compatibility with existing projects and scripts.

---

## Skill Naming Convention

At Stage DI-1, the orchestrator must determine the **target skill name** — the identifier used for the skill directory and frontmatter `name` field.

### Convention: `{domain}-data-source-{acronym}`

All data source skills follow this pattern. The `{domain}` groups related sources for pattern-based discovery, and the `{acronym}` is the standard abbreviation researchers use for the source.

**Examples:** `education-data-source-ccd`, `education-data-source-ipeds`, `election-data-source-countypres`

### Naming Rules

| Rule | Correct | Incorrect | Rationale |
|------|---------|-----------|-----------|
| Use the standard acronym when one exists | `education-data-source-ccd` | `education-data-source-common-core` | Acronyms are how researchers reference sources |
| Domain prefix must match `metadata.domain` | `election-data-source-countypres` (domain: `election-data`) | `voting-data-source-countypres` | Consistency enables pattern-based discovery |
| Identify specific tables when a source has multiple | `education-data-source-ccd-schools` | `education-data-source-ccd` (if ambiguous) | Prevents conflicts when onboarding additional tables later |
| Follow frontmatter validation: lowercase, hyphens only | `education-data-source-nhgis` | `education_data_source_NHGIS` | Regex: `^[a-z0-9]+(-[a-z0-9]+)*$` |

### Orchestrator Responsibilities at DI-1

1. **If the user provides a skill name:** Validate it against the `{domain}-data-source-{acronym}` convention. If it doesn't follow the pattern, suggest a corrected version and explain the convention briefly. Accept the user's preference if they insist.
2. **If the user does not provide a skill name:** Propose one using the source name, domain context, and any acronym the user mentions. Present the proposed name for confirmation.
3. **Always check** for conflicts against existing skills in `.claude/skills/` before confirming.
4. **Record** the confirmed skill name in STATE.md's Data Source Info section.

### Access Method Determination

At DI-1, determine how the user's data will be accessed:

```
Does the user have a data file on disk?
├─ YES → Does the user also want the API access pattern documented in the skill?
│   ├─ YES → Access method = LOCAL FILE + API DOCS
│   │   └─ Skip DI-0 data download; DI-0 researches API only (write phase)
│   │      to populate the skill's Data Access section with API patterns
│   └─ NO → Access method = LOCAL FILE
│       └─ Proceed to file structure classification
└─ NO → Does the user have an API to pull from?
    ├─ YES → Access method = API
    │   └─ Collect API details; Stage DI-0 will execute before DI-1 resumes
    └─ NO → Ask clarifying questions:
        ├─ "Is the data available online for download?"
        │   └─ YES → Help user download it, or use DI-0 to fetch via URL
        └─ "Can you provide the data file directly?"
            └─ Guide user to place file in an accessible location
```

**If access method = API, collect:**
- API documentation URL (or user description of API endpoints)
- Name of the environment variable holding the API key (e.g., `MY_API_KEY`)
- Target endpoint(s) and any query parameters (date range, filters, format)
- Data persistence preference (ask explicitly):

> **How would you like to access this data in future analyses?**
>
> 1. **Download once and work locally** (default) — I'll download the data now, save it as a parquet file, and future analyses will use the local copy. Simpler, works offline, and faster for repeated use.
> 2. **Query the API each time** — I'll document the API access pattern so future analyses always pull fresh data directly from the source. Keeps data current, but requires API access and a valid key each time.
>
> Either way, I'll create a reproducible fetch script you can re-run any time.

Record all API details and the persistence preference in STATE.md's Data Source Info section.

### File Structure Classification

For users providing one or more local files (or after DI-0 downloads data):

```
How many data files are involved?
├─ ONE file → File structure = SINGLE (default, no further questions)
└─ MULTIPLE files → Ask the user:
    ├─ "Are these files structured the same way (same columns), just
    │    covering different time periods or segments?"
    │   └─ YES → File structure = HORIZONTAL
    │       └─ Confirm: "I'll combine these into one dataset for profiling,
    │          adding a tracking column so we know which file each row came
    │          from. Does that sound right, or would you prefer I profile
    │          them separately?"
    └─ "Do these files represent different levels of data (e.g., one file
        for schools, another for districts) that link together on key columns?"
        └─ YES → File structure = HIERARCHICAL
            └─ Collect:
                ├─ Which entity does each file represent?
                ├─ What columns link them together?
                └─ Do all files cover the same time period?
```

### Skill Structure Decision (Multi-File Only)

For HORIZONTAL or HIERARCHICAL file structures, present this decision:

> **Skill structure decision:** You're providing [N] related data files. By default, I'll create **one unified skill** that documents the entire data source — all files, their relationships, join patterns, and caveats in one place. This is simpler to load and keeps all context together.
>
> Alternatively, I can create **one skill per entity type** (e.g., `your-source-schools`, `your-source-districts`). This gives more granular detail per table within each skill but means loading multiple skills when working across levels.
>
> **Which do you prefer?** (Default: one unified skill)

If the user chooses PER-ENTITY:
- Each file gets its own skill name following the `{domain}-data-source-{acronym}-{entity}` convention
- Each skill is profiled and authored independently
- A brief cross-reference section in each skill points to the related entity skills
- The orchestrator runs the full profiling cycle per file, then authors skills separately

Record the choice in STATE.md Key Decisions Made.

### API Complexity Assessment (During DI-0)

After the orchestrator (or data-ingest agent during DI-0) has researched the API, assess complexity and present a recommendation:

**Simple API** (1-3 endpoints, single dataset, straightforward auth):

> This API has a straightforward structure — I'll document the access pattern directly in the data source skill's "Data Access" section. This keeps everything in one place.

**Complex API** (many endpoints, multiple datasets, rich query parameters, pagination):

> This API offers many endpoints and datasets. I can either:
>
> 1. **Document access in the data source skill** (default) — covers the specific dataset(s) you're onboarding now
> 2. **Create a separate query/connector skill** (e.g., `your-domain-data-query`) — a reusable reference for accessing any dataset from this API, useful if you plan to onboard multiple datasets from this source over time
>
> I'd recommend option 1 unless you know you'll be working extensively with this API. You can always create the query skill later.

Record the decision in STATE.md Key Decisions Made.

### API Key Setup Guidance (Orchestrator Reference)

When the user needs to set up an API key and it's not currently available in the environment, present these options:

**For the current session (temporary):**

> Before launching Claude Code, run this in your Docker container terminal:
> ```bash
> export YOUR_API_KEY_NAME="your_key_here"
> ```
> You can also type `! export YOUR_API_KEY_NAME="your_key_here"` directly in the Claude Code prompt to set it for this session.

**For persistence across sessions:**

> Add the export to your shell profile inside the container:
> ```bash
> echo 'export YOUR_API_KEY_NAME="your_key_here"' >> ~/.bashrc
> ```

**For Docker Compose (recommended for team or repeated use):**

> Add to the `environment:` section in `docker-compose.yml`:
> ```yaml
> environment:
>   - YOUR_API_KEY_NAME=${YOUR_API_KEY_NAME}
> ```
> Then set the variable on your host machine before running `docker compose up`.

**Security notes to convey to user:**
- DAAF's safety guardrails prevent reading or writing `.env` files — this is by design
- Credentials stay in temporary memory only and are never written to files
- The acquisition script references `os.environ["KEY_NAME"]`, never hardcodes the key value
- The script is archived in the project for reproducibility, but the key value is never in it

**OAuth / complex authentication:** If the API requires OAuth 2.0 (token refresh, browser-based authorization code flow) or other multi-step authentication, DI-0 cannot handle this automatically. In this case, advise the user to:
1. Complete the OAuth flow manually outside DAAF (e.g., using the API's web portal or a CLI tool)
2. Obtain a bearer token or access token
3. Set it as an environment variable (e.g., `export MY_API_TOKEN="bearer_token_here"`)
4. Proceed with DI-0 using the token as a simple API key

Note in the skill's Data Access section that the token may expire and needs periodic renewal. Alternatively, the user can download the data manually and provide it as a local file.

### Data Persistence Preference Effects

The user's persistence preference (collected at DI-1) determines how the skill documents data access:

| Preference | Skill "Data Access" Section | Acquisition Script | Future Pipeline Behavior |
|------------|---------------------------|-------------------|------------------------|
| **Local storage** (default) | Documents download procedure + local file path pattern | Downloads full dataset to `data/raw/` | Stage 5 loads from local parquet; re-fetch only if user requests |
| **Live query** | Documents API endpoint + query code pattern | Downloads for onboarding profiling only | Stage 5 queries API directly each time; script includes the full API call |

Both preferences produce the same profiling outcome — the difference is in what the skill tells future pipeline stages about how to access the data.

When "Live query" is selected, the skill's Data Access section includes both patterns: the API query code (primary) AND a note about local caching for offline use or performance.

### DI-0 Invocation Template

When access method = API, the orchestrator invokes the data-ingest agent for DI-0:

```
**MODE: Data Onboarding — Stage DI-0 (API Acquisition)**
**BASE_DIR:** {absolute path to DAAF root}
**PROJECT_DIR:** {absolute path to research project}

## Task

Research the target API and write an acquisition script that downloads the
user's requested dataset to the project's data/raw/ directory.

## API Details

- **API Documentation URL:** {url or "None — user description below"}
- **User Description of API:** {what the user told us about the API}
- **API Key Env Var:** {env var name, e.g., "HARVARD_DATAVERSE_API_KEY"}
- **Target Endpoint(s):** {what data to download}
- **Query Parameters:** {filters, date range, format preferences}
- **Data Persistence Preference:** {Local storage / Live query}

## Instructions

**DI-0 uses a split execution model: the agent WRITES the script but does NOT execute it.** The orchestrator presents the script to the user for approval, then executes it separately. This is because DI-0 makes external network calls — the user should see exactly what API call will be made before it runs.

1. Load the `data-scientist` skill for methodology guidance
2. Research the API via WebFetch (read API docs) and WebSearch if needed
3. Identify: available endpoints, response format, pagination method, rate limits, auth method
4. Write acquisition script to: `{project_script_dir}/stage5_fetch/00_api-fetch.py`
   - Script MUST check `os.environ["{env_var_name}"]` with clear error if missing
   - Script MUST use `requests` library for API calls
   - Script MUST handle pagination if the API paginates results
   - Script MUST save result as parquet to `{project_dir}/data/raw/{date}_{source}.parquet`
   - Script MUST print: rows fetched, columns, file size, file path
   - Script MUST include IAT comments (INTENT, REASONING, ASSUMES)
   - Follow file-first execution protocol (read SCRIPT_EXECUTION_REFERENCE.md)
5. **STOP — do NOT execute the script.** Return the script path and API findings to the orchestrator. The orchestrator will present the script to the user and execute after approval.

## Output Format

Return findings in this structure (max 2500 words):

### DI-0 Summary
**Status:** [SCRIPT_READY | BLOCKED]
**Script Path:** [absolute path to 00_api-fetch.py]
**Expected Output Path:** [where the parquet will be saved]

### API Findings
- **Base URL:** [discovered base URL]
- **Auth Method:** [API key via query param / header / bearer token]
- **Rate Limits:** [if discovered]
- **Pagination:** [method if applicable]
- **Available Endpoints:** [brief inventory of what else this API offers]
- **API Complexity Assessment:** [Simple / Complex — with reasoning]

### Acquisition Script
**Path:** [absolute path to 00_api-fetch.py]

### Confidence Assessment
**DI-0 Confidence:** [HIGH | MEDIUM | LOW]

| Aspect | Confidence | Rationale |
|--------|------------|-----------|
| API authentication | [H/M/L] | [evidence] |
| Data completeness | [H/M/L] | [did we get everything the user requested?] |
| Response format | [H/M/L] | [was the format as expected?] |

### Issues
[Any issues encountered, or "None"]

### Recommendations
- **Proceed?** [YES -- data acquired successfully | NO -- issues block acquisition]
- [Specific next actions or items for orchestrator attention]

### Learning Signal
**Learning Signal:** [Category] -- [One-line insight] | "None"
```

---

## Gate Definitions

| Gate | After Stage | Criteria | STOP If |
|------|-------------|----------|---------|
| GDI-0 | DI-0 | API key verified, data downloaded, file non-empty, acquisition script archived | API auth fails, empty response, rate limited (conditional — only if access method = API) |
| GDI-1 | DI-1 | Required inputs collected, file(s) accessible and non-empty, access method determined, file structure classified | File cannot be loaded, file empty, required inputs missing, or API acquisition failed |
| GDI-2 | DI-2 | Project folder created, STATE.md initialized (from `agent_reference/STATE_TEMPLATE_ONBOARDING.md`), data staged | Folder creation fails |
| GDI-3 | DI-3 | CPP1 PASSED, QAP1 PASSED or WARNING | File >1GB without sampling plan approved by user, or critical columns entirely null |
| GDI-4 | DI-4 | CPP2 PASSED, QAP2 PASSED or WARNING | >50% of columns are entirely null |
| GDI-5 | DI-5 | CPP3 PASSED, QAP3 PASSED or WARNING | No candidate keys identifiable across any table |
| GDI-6 | DI-6 | CPP4 PASSED, QAP4 PASSED or WARNING | >50% of documented columns missing from data |
| GDI-7 | DI-7 | CPP-SKILL PASSED (template compliance) | Template compliance fails after 2 revision attempts |
| GDI-8 | DI-8 | User confirms skill is acceptable | N/A (user decision point) |

**Gate enforcement:** Gates GDI-1 through GDI-7 are mandatory checkpoints. If a gate's STOP condition is triggered, halt execution, present the issue to the user, and await guidance before proceeding. Update STATE.md with the gate failure and resolution.

---

## Per-Part Execution Cycle (MANDATORY)

For EACH profiling part (DI-3 through DI-6), follow this complete cycle. **Do NOT skip any step.** This is the Data Onboarding equivalent of the Full Pipeline's Stage 5-8 Composite Execution Pattern.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 0: READ STATE.md                                                      │
│      ├─ Verify current position and prior part statuses                    │
│      ├─ Check Profiling Progress table — confirm prior part rows updated   │
│      ├─ Check Error Budget — confirm remaining budget > 0                  │
│      └─ Confirm no unresolved BLOCKERs from prior parts                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  STEP 1: INVOKE data-ingest subagent                                        │
│      │                                                                      │
│      │   Use the part-specific invocation template (Part A/B/C/D)          │
│      │   from WORKFLOW_PHASE_DO_PROFILING.md.                              │
│      │                                                                      │
│      │   Capture from return: script paths, CPP status, part summary,      │
│      │   conditional script decisions (Part A only), learning signals.     │
│      │                                                                      │
│      └─ WAIT for data-ingest subagent to return before proceeding          │
├─────────────────────────────────────────────────────────────────────────────┤
│  STEP 2: INVOKE code-reviewer (MANDATORY — DO NOT SKIP)                     │
│      │                                                                      │
│      │   Use the QA Invocation Template with part-specific values.         │
│      │                                                                      │
│      │   **Review Expectation:** code-reviewer should perform adversarial  │
│      │   analysis, not just template validation. Expect the QA report to   │
│      │   include script-specific checks and reasoning about WHY the code   │
│      │   is correct, not merely confirmation that checks passed.           │
│      │                                                                      │
│      └─ WAIT for code-reviewer to return before proceeding                 │
├─────────────────────────────────────────────────────────────────────────────┤
│  STEP 3: EVALUATE QA severity                                               │
│      ├─ PASSED → Log to STATE.md, proceed to STEP 5                        │
│      ├─ WARNING → Log to STATE.md (for PSU-DI2 review), proceed to STEP 5 │
│      └─ BLOCKER → Go to STEP 4                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  STEP 4: REVISION FLOW (if BLOCKER)                                         │
│      ├─ Re-invoke data-ingest subagent to revise failing script(s)         │
│      ├─ Re-invoke code-reviewer on revised scripts                         │
│      ├─ If still BLOCKER → Create next revision, re-invoke code-reviewer   │
│      └─ If still BLOCKER after 2 revisions → STOP and escalate to user    │
├─────────────────────────────────────────────────────────────────────────────┤
│  STEP 5: UPDATE STATE.md                                                    │
│      ├─ Profiling Progress table: update Status, CPP, QA Status for each  │
│      │   script in this part; record skip reasons in Notes column           │
│      ├─ Checkpoint Status tables: update CPP row (Primary Validation)      │
│      │   and QAP row (Secondary Validation) for this part                  │
│      ├─ QA Findings Summary: append BLOCKERs Resolved / WARNINGs Logged   │
│      │   incrementally (don't defer to DI-8)                               │
│      ├─ Error Budget Consumed: update per-part and session totals         │
│      ├─ Current Position: update Current Phase and Current Stage            │
│      ├─ Next Actions: set to upcoming part or PSU-DI2 if Part D done      │
│      ├─ Key Decisions Made: record any conditional script skip decisions   │
│      ├─ Pending Learning Signals: append any signals from subagent return  │
│      ├─ Files Created This Session: append script paths created this part  │
│      ├─ If Part D: populate Interpretation Tracking (Preliminary column)   │
│      │   from subagent return; populate Documentation Reconciliation       │
│      │   Summary from Part D discrepancy findings (if docs provided)       │
│      ├─ Verify gate criteria (CPP + QAP status) before proceeding         │
│      └─ Proceed to next part or PSU-DI2                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  STEP 6: PROGRESS UPDATE (informational — no user action required)         │
│      │                                                                      │
│      │   After each part's QA completes and STATE.md is updated, print    │
│      │   a brief, informal progress message to the user:                  │
│      │                                                                      │
│      │   **Profiling progress: [Part Name] complete**                     │
│      │   - [1-2 key findings from this part]                              │
│      │   - Next: [what comes next — next part or PSU-DI2 review]          │
│      │                                                                      │
│      │   This is a heartbeat, not a checkpoint. No user action needed.    │
│      │   Keep it to 3-4 lines. Do NOT present detailed findings —         │
│      │   those are for PSU-DI2.                                           │
│      │                                                                      │
│      └─ Proceed to next part (back to STEP 0) or PSU-DI2                  │
├─────────────────────────────────────────────────────────────────────────────┤
│  STEP 0 (before each cycle): READ STATE.md                                  │
│      ├─ Verify current position and prior part statuses                    │
│      ├─ Check Error Budget — confirm remaining budget > 0                  │
│      └─ Confirm no unresolved BLOCKERs from prior parts                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

**CRITICAL:** Steps 0-6 form an atomic unit. Step 0 runs before each new part cycle. NEVER proceed to the next part without completing all steps. NEVER invoke a new profiling subagent without first completing QA review and STATE.md update for the previous part.

**Stage DI-7 (Skill Authoring):** Does not follow this cycle. It has its own gate (GDI-7) and updates the Skill Authoring Status section of STATE.md directly. DI-7 includes skill file creation and template compliance validation. Skills are automatically discovered via YAML frontmatter once placed in `.claude/skills/`.

**Stage DI-8 (Review & Delivery):** Finalizes STATE.md and consolidates LEARNINGS.md as described in the Output Format section. The LEARNINGS.md consolidation protocol for DI-8:
1. Review LEARNINGS.md entries captured during profiling phases (DI-3 through DI-6)
2. Ensure **Access/Data Gotchas** and **Data Quality Notes** sections are populated — these are the most relevant sections for onboarding work, since profiling surfaces source-specific quirks that future analyses need to know about
3. If profiling revealed issues with existing skills, agent protocols, or templates (e.g., "the data source skill template does not account for a pattern we discovered"), add a **System Update Action Plan** section following the same format as Full Pipeline (see `WORKFLOW_PHASE5_SYNTHESIS.md`). Keep it lightweight — only include genuinely generalizable improvements, not project-specific observations.
4. If no generalizable framework updates were identified, add a brief statement: "No generalizable framework updates identified during this onboarding."
5. Include the action plan item count (or zero) in the delivery message

### STATE.md Update Gates

| Event | Required STATE.md Field Updates |
|-------|--------------------------------|
| DI-0 script approved and executed | Profiling Progress row 00 → DONE; API Access Info → all fields populated; Files Created; Current Position |
| DI-0 blocked (auth failure, empty response) | Blockers → Execution Blockers; Current Position → Status=Blocked |
| Part starts (DI-3/4/5/6) | Current Position → Current Stage, Current Phase |
| Part cycle Step 5 completes | Profiling Progress → script Status and CPP columns for each script in part |
| Conditional script skipped | Profiling Progress → Status=SKIPPED, Notes=reason; Key Decisions Made |
| CPP checkpoint passes | Checkpoint Status → Primary Validation (CPP row for this part) |
| QA completes (QAP1-4) | Checkpoint Status → Secondary Validation (QAP row); QA Findings Summary |
| QA BLOCKER encountered | QA Blockers (Pending Resolution) table; Error Budget Consumed |
| QA BLOCKER resolved via revision | QA Blockers → Status=Resolved; Profiling Progress → Revisions column |
| Gate passes (GDI-3/4/5/6) | Current Position → Status; Next Actions |
| Gate STOP triggered | Blockers → Execution Blockers; Current Position → Status=Blocked |
| Key decision made | Key Decisions Made table |
| Context utilization ≥ ELEVATED (≥ 40% or ≥ 150k tokens) | Session Continuity → Context Snapshot |
| PSU-DI2 user response received | Interpretation Tracking table (all rows populated with user decisions) |
| Skill authoring completes (DI-7) | Skill Authoring Status table; Discovery Status (confirmed) |
| Session break / finalization | Session Continuity → all fields; Session History |
| Learning signal received | Pending Learning Signals buffer |
| Files created | Files Created This Session table |

### Context Management

Context utilization thresholds from `CLAUDE.md` > "Context & Session Health" > "Context Quality Curve" apply to Data Onboarding mode. The Per-Part Execution Cycle is the atomic unit for gating decisions.

| Utilization | Status | Data Onboarding Action |
|-------------|--------|--------------------|
| **< 40% and < 150k tokens** | NOMINAL | Continue normally through profiling parts |
| **≥ 40% or ≥ 150k tokens** | ELEVATED | Complete current part cycle; assess whether remaining parts are feasible in this session; update STATE.md Context Snapshot |
| **≥ 60% or ≥ 200k tokens** | HIGH | Complete current part cycle at full quality; update STATE.md with restart prompt; report to user; do not start next part |
| **≥ 75% or ≥ 250k tokens** | CRITICAL | **Overrides atomic-unit requirement** — save STATE.md immediately (Current Position, Next Actions, Context Snapshot) and cease work; do not attempt to finish the current part cycle |

**Post-PSU-DI2 is a natural restart boundary.** If utilization is ELEVATED or higher after Part D completes, present PSU-DI2 findings, collect user decisions, populate Interpretation Tracking in STATE.md, then recommend restarting for DI-7 (skill authoring) in a fresh session.

### Post-PSU-DI2 Update Procedure

After the user responds to PSU-DI2 (confirming/rejecting/modifying interpretations), the orchestrator MUST update STATE.md before proceeding to DI-7:

1. **Interpretation Tracking table:** For each interpretation, populate User Decision (CONFIRMED/REJECTED/MODIFIED) and Final Interpretation columns from the user's response
2. **Documentation Reconciliation Summary:** If discrepancies were reported in Part D, populate the table from Part D subagent's findings
3. **Current Position:** Update to DI-7 (Skill Authoring)
4. **Next Actions:** Set to "Invoke skill authoring subagent"

This is a **mandatory gate** — DI-7 cannot be invoked until Interpretation Tracking has Final Interpretation values for all rows.

---

## PSU Templates

### PSU-DI1: Setup Confirmation

Present after Stage DI-2 completes. All user-facing text uses plain language — no internal terms (gate, QA, CPP, stage DI-N).

```
**Data Onboarding: Setup Complete**

**Data Source Summary:**
- File(s): [file name(s) and path(s); list all if multi-file]
- Format: [parquet / CSV / etc.]
- Size: [file size; combined total if multi-file]
- Source name: [source-name]
- Target skill: [skill-name]
- Access method: [Local file / API (data downloaded via [API name])]
[If multi-file:]
- File structure: [Horizontal (same schema) / Hierarchical (different levels)]
- Skill structure: [One unified skill / One skill per entity type]
[If HIERARCHICAL:]
- Entity hierarchy: [e.g., "Schools → Districts → States"]
- Linking keys: [e.g., "leaid links schools to districts; state_fips links districts to states"]
[If API:]
- Data persistence: [Downloaded locally / Will query API live in future analyses]

**Project Folder:** [absolute path to research project]

**Profiling Plan:**
The following profiling parts will run automatically:
[If SINGLE or HORIZONTAL:]
- Part A: Structural profiling (schema, column details, file metadata) — scripts 01-03
- Part B: Statistical profiling (distributions[, temporal analysis][, geographic analysis]) — scripts 04[-06]
- Part C: Relational analysis (key candidates[, cross-table joins], referential integrity) — scripts 07[-09]
- Part D: Interpretation (semantic classification[, documentation reconciliation]) — scripts 10[-11]
[If HIERARCHICAL:]
- Part A: Structural profiling — per-file (scripts 01a-03a, 01b-03b, etc.)
- Part B: Statistical profiling — per-file (scripts 04a[-06a], 04b[-06b], etc.)
- Part C: Relational analysis — per-file + cross-file linkage testing (scripts 07a, 07b, 08?, 09a, etc.)
- Part D: Interpretation — per-file + cross-file schema map (scripts 10a, 10b, [11])

[Note which scripts are conditional and why they will/will not run based on intake info.]

**What You Receive:**
- A standalone data source skill for use in future DAAF analyses
- A research project folder with all profiling scripts, outputs, and QA reviews
[If API:] - A reproducible API fetch script you can re-run any time

**What Happens Next:**
Profiling runs through all [four] parts automatically. After profiling completes, you will review the findings and confirm or adjust interpretations before the skill is written.

**Does this look correct? Ready to begin profiling?**
```

### PSU-DI2 Presentation at Scale

For datasets with many columns (>30), the full interpretation table can be overwhelming. Structure the presentation to prioritize user attention:

**For datasets with 30+ columns:**

1. **Lead with low-confidence interpretations** that genuinely need user input (group under "Interpretations Needing Your Review")
2. **Follow with high-confidence interpretations** for quick scanning (group under "Likely Correct — Please Confirm")
3. **Group by semantic family** (identifiers, outcomes, demographics, temporal, etc.) within each confidence tier — this mirrors how script 10 organizes its output

**For datasets with 60+ columns:**

Consider a two-tier approach:
- **Tier 1 (presented in detail):** Low/medium-confidence interpretations + all identifier and key columns + user-specified priority columns
- **Tier 2 (summarized):** High-confidence interpretations presented as a condensed table ("These N columns are straightforward — see full list below")

The goal is to focus user attention where it adds the most value, not to hide information. Both tiers should be visible, but the user's limited review time should be directed to where uncertainty exists.

### PSU-DI2: Profiling Findings Review

Present after Stage DI-6 completes. This is the CRITICAL user review point — interpretations presented here become the basis for the skill definition in Stage DI-7.

```
**Data Onboarding: Profiling Complete — Review Needed**

**Quality Summary:**
[From Part A-D profiling findings — overall data quality assessment in plain language]

[If SINGLE or HORIZONTAL:]

**Structural Findings:**
- Rows: [count]
- Columns: [count]
- Data types: [summary of type distribution]
- [Notable structural observations]
[If HORIZONTAL:] - Schema compatibility: [identical / divergent — details]

**Column Highlights:**
- Key columns: [identified primary/candidate keys]
- High-null columns: [columns with significant missingness and rates]
- Distribution notes: [notable distributions, outliers, or skew]

[If HIERARCHICAL — repeat per file, then show cross-file:]

**Per-File Findings:**

**[File 1: Entity Type] ([filename])**
- Rows: [count], Columns: [count]
- Key columns: [identified keys]
- Notable: [highlights for this file]

**[File 2: Entity Type] ([filename])**
- Rows: [count], Columns: [count]
- Key columns: [identified keys]
- Notable: [highlights for this file]

**Cross-File Relationships:**

| Link | Key Column(s) | Cardinality | Coverage | Orphan Count | Notes |
|------|--------------|-------------|----------|--------------|-------|
| [File1 → File2] | [key] | [1:M / M:M] | [% match] | [count] | [observations] |

[Common to all structures:]

**Temporal Coverage:** [date range, granularity — or "N/A" if no temporal columns]

**Geographic Coverage:** [geographic levels, scope — or "N/A" if no geographic columns]

**Quality Issues:**
- Coded values: [list of columns with coded values and their mappings if identified]
- Anomalies: [unexpected patterns, potential data quality issues]
- Suppression: [any suppressed or redacted values found]

**Preliminary Interpretations:**

| # | [File] | Interpretation | Basis | Status |
|---|--------|---------------|-------|--------|
| 1 | [file or "All"] | [e.g., "Column X appears to be a fiscal year indicator"] | [evidence] | CONFIRM / REJECT / MODIFY |
| 2 | [file or "Cross-file"] | [e.g., "leaid links schools to districts as a 1:M relationship"] | [evidence] | CONFIRM / REJECT / MODIFY |
| ... | ... | ... | ... | ... |

[If documentation was provided and reconciled:]
**Documentation Discrepancies:**
- [Column/field where data differs from documentation]
- [Expected vs. observed behavior]

Please review each interpretation above. For each row, indicate:
- **CONFIRM** — interpretation is correct as stated
- **REJECT** — interpretation is wrong; provide correction
- **MODIFY** — interpretation is partially correct; provide adjustment

**Are these interpretations accurate? Please confirm, reject, or modify each one.**
```

---

## Context Completeness Checklists

### Profiling Invocation Checklist

Before dispatching a profiling subagent (Stages DI-3 through DI-6), verify:

- [ ] Script target path specified (absolute, following naming convention)
- [ ] Data file path(s) specified (absolute)
- [ ] Source name and format inlined
- [ ] Column batching boundaries specified (if >100 columns)
- [ ] Prior part outputs inlined (for Parts B-D: structural findings from Part A)
- [ ] Conditional script decisions documented with reasoning
- [ ] Priority columns from intake highlighted (if any)
- [ ] Documentation excerpts inlined (if provided and relevant to current part)
- [ ] Execution command uses {BASE_DIR}/scripts/run_with_capture.sh
- [ ] IAT documentation standards referenced
- [ ] If user has R/Stata background: include translation skill directive in prompt ("User has [R/Stata] background. Load [r-python-translation/stata-python-translation] skill. Add inline [R/Stata]-equivalent comments for non-trivial data operations.")

### QA Invocation Checklist

Before dispatching a code-reviewer subagent (QAP1 through QAP4), verify:

- [ ] Script path specified (exact path to script being reviewed)
- [ ] Expected outputs described (what the script should produce)
- [ ] Profiling part context inlined (what this part was meant to accomplish)
- [ ] Data characteristics inlined (row count, column count, file size)
- [ ] IAT compliance expectations stated
- [ ] QA tolerance thresholds specified (BLOCKER if, WARNING if)
- [ ] Prior QA findings inlined (for QAP2-QAP4: issues from earlier parts)

### Skill Authoring Invocation Checklist

See `WORKFLOW_PHASE_DO_AUTHORING.md` for the complete skill authoring invocation checklist (loaded at Stage DI-7).

---

## Operational References

### Data Location Convention

All data for a Data Onboarding project lives inside the research project folder, following the same pattern as Full Pipeline projects.

#### Project Data Structure

```
research/YYYY-MM-DD_{Source_Name}_Onboarding/
├── data/
│   └── raw/                    # Original data files (immutable after drop)
│       ├── {file1}.parquet
│       └── {file2}.parquet
├── ...
```

#### Setup Protocol

1. **Stage DI-2:** Create the research project folder under `research/`
2. **Create `data/raw/`** subdirectory inside the research project
3. **Copy** user-provided data files into `data/raw/`
4. **Initialize STATE.md** from `{BASE_DIR}/agent_reference/STATE_TEMPLATE_ONBOARDING.md` — this template has onboarding-specific sections (DI-1 through DI-8 stages, Profiling Progress table, Interpretation Tracking, Skill Authoring Status) that differ from the Full Pipeline template. Populate the Data Source Info and User Request sections with intake information.
5. **Instruct user** if files need manual placement (e.g., files too large to copy, or user prefers to place them directly)

---

## Output Format

### Final Delivery (Stage DI-8)

Before presenting to the user, collect session logs into the project:
```
bash {BASE_DIR}/scripts/collect_session_logs.sh {PROJECT_DIR}
```
Then update STATE.md Session Metadata to confirm log collection.

Present to the user after Stage DI-7 completes and the skill passes compliance:

```
**Data Onboarding Complete**

**Skill Created:**
- Name: {skill-name}
- Location: {BASE_DIR}/.claude/skills/{skill-name}/
- Files: SKILL.md + [N] reference files + [N] bundled profiling scripts

**Profiling Summary:**
- [Row count] rows, [column count] columns
- [Key quality findings in 2-3 bullets]
- [Temporal/geographic coverage summary if applicable]

The skill is automatically discoverable via its YAML frontmatter and ready for use in future analyses. If you'd like to adjust the description or trigger conditions, edit the skill's frontmatter in `.claude/skills/{skill-name}/SKILL.md`.

**Research Project:**
- Location: [absolute path to research project folder]
- Contains: [N] profiling scripts, [N] QA reviews, STATE.md, LEARNINGS.md
- Session logs: `logs/` (collected via `collect_session_logs.sh`)

**Confidence Assessment:**
- Structural profile: [HIGH/MEDIUM/LOW] — [brief rationale]
- Statistical profile: [HIGH/MEDIUM/LOW] — [brief rationale]
- Semantic interpretation: [HIGH/MEDIUM/LOW] — [brief rationale]

**Skill Maturity:**
This skill is at **v1 (Initial)** — created through automated profiling with your confirmed interpretations. Profiling scripts are bundled with the skill for reproducibility — re-run them to re-verify if the source data is updated. As you use this data in future analyses, you'll discover additional edge cases and domain-specific patterns worth documenting. You can refine the skill at any time using Framework Development mode.

**Want to adjust the skill?**
If anything in the skill doesn't look right — descriptions, decision trees, reference file content — let me know and I can make targeted revisions. For more substantial restructuring, we can switch to Framework Development mode.

**Recommendations:**
- [Any follow-up actions: e.g., columns needing manual review, documentation gaps, suggested analyses]

[If System Update Action Plan has action items:]
**Framework Updates Available:** Profiling generated [N] action items for improving DAAF skills, templates, or protocols. To incorporate these, start a new session and say "incorporate learnings" — this uses Framework Development mode to process the action plan.
```

---

## Phase-Specific References

The orchestrator loads these files progressively — only when the corresponding phase begins:

| Phase | Reference File | When to Load |
|-------|---------------|--------------|
| DO-2 (Profiling) | `WORKFLOW_PHASE_DO_PROFILING.md` | Before dispatching the first profiling subagent (Stage DI-3) |
| DO-3 (Skill Authoring) | `WORKFLOW_PHASE_DO_AUTHORING.md` | After PSU-DI2 user confirmation, before Stage DI-7 |

**Do NOT load both files at mode start.** Load each file just-in-time for its phase to conserve orchestrator context.

---

## Boundaries

These boundaries supplement the universal safety boundaries in `CLAUDE.md`. This section is the canonical source for all Data Onboarding Mode-specific boundaries.

**Always Do:**
1. Verify file accessibility and non-emptiness before starting profiling
2. Place raw data files inside the research project's `data/raw/` folder and record provenance in STATE.md's Data Source Info section
3. Run all mandatory scripts (01-04, 07, 09, 10) regardless of file characteristics
4. Apply conditional script rules strictly based on Part A findings and intake info
5. Present all interpretations to the user at PSU-DI2 and wait for confirmation
6. Use DATA_SOURCE_SKILL_TEMPLATE.md as the structural basis for all generated skills
7. Follow the Per-Part Execution Cycle for all profiling parts — STATE.md must be updated after every part per the STATE.md Update Gates table
8. Preserve the full audit trail — never modify scripts after execution log is appended

**Ask First Before:**
1. Profiling files larger than 1GB (propose sampling strategy)
2. Skipping a conditional script when the evidence is ambiguous
3. Interpreting coded values that are not self-evident
4. Creating a skill that covers multiple unrelated data sources
5. Overwriting an existing skill with the same name

**Never Do:**
1. Encode interpretations into the skill without user confirmation at PSU-DI2
2. Modify the original data files in `data/raw/`
3. Skip QA review for any profiling part
4. Create analysis scripts or run statistical models (profiling only, not analysis)
5. Proceed past PSU-DI2 without explicit user confirmation of interpretations

---

## Escalation Triggers

### Data Onboarding to Full Pipeline

After skill creation completes (Stage DI-8), the user may want to analyze the data they just profiled. Propose escalation:

> "The data source skill is ready. Would you like to proceed with a Full Pipeline analysis using this data?"

If confirmed, load `{SKILL_REFS}/full-pipeline-mode.md` and begin Full Pipeline mode. The newly created skill is immediately available for the pipeline's domain configuration.

### Full Pipeline Phase 1 to Data Onboarding

During Full Pipeline Discovery (Stages 2-3), if a required data source has no existing skill and the user has the raw data file, propose escalation:

> "This analysis needs [source name] data, but no skill exists for it yet. You have the raw file — would you like to pause the pipeline and run Data Onboarding to create the skill first?"

If confirmed, pause Full Pipeline (record state in STATE.md), switch to Data Onboarding mode. After skill creation, resume Full Pipeline from the point of interruption.

### Data Discovery to Data Onboarding

During Data Discovery mode, if the user has a data file but no skill exists for it, propose escalation:

> "It looks like you have a data file for [source name] but there is no skill for it yet. Would you like to switch to Data Onboarding mode to profile it and create a skill?"

If confirmed, load this mode reference and begin Data Onboarding. The user can return to Data Discovery afterward if needed.
