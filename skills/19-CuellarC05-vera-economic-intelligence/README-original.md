# Skills directory

Purpose

This folder contains `SKILL` documents that define modular workflows used by Vera. SKILL files with YAML frontmatter (example: `*.SKILL.md`) provide machine-readable metadata to support routing and CI checks.

SKILL format (required frontmatter keys)

- `name` — short identifier
- `description` — one-line summary
- `owner` — team or person responsible
- `tags` — list of tags
- `triggers` — list of trigger phrases/intents
- `inputs` — expected inputs
- `outputs` — expected outputs
- `examples` — example prompt + expected result
- `guardrails` — refusal/escalation conditions

Running the validator locally

Requirements: Python 3.8+

From the repository root:

```bash
python skills/scripts/validate_skills.py
```

What the validator does

- Finds `*.SKILL.md` files and `SKILL_TEMPLATE.md`.
- Checks for a YAML frontmatter block (`---` ... `---`) and the presence of required keys.

CI

A GitHub Actions workflow `.github/workflows/validate_skills.yml` runs the validator on pushes and pull requests that touch the `skills/` folder.

Next steps

- When you're happy with the template, I can batch-convert remaining skills in small, reviewable PRs.
# Skills directory

This folder contains small capability documents (SKILL files) used by Vera. New skills should follow the `SKILL.md` frontmatter pattern and include required metadata so routing and validation work reliably.

Required frontmatter keys (YAML-like) in each `*.SKILL.md`:
- `name`
- `description`
- `owner`
- `tags`
- `triggers`
- `inputs`
- `outputs`
- `examples`
- `guardrails`

Quick checks

- Run the validator locally (requires Python 3):

```powershell
python .\skills\scripts\validate_skills.py
```

- The repository runs the same validator on push/PR via GitHub Actions (`.github/workflows/validate_skills.yml`).

How to add a new skill

1. Copy `skills/SKILL_TEMPLATE.md` and fill the frontmatter and sections.
2. Save as `skills/<category>/<skill-name>.SKILL.md`.
3. Open a PR — CI will run the validator and signal missing fields.

Notes

- Keep examples short and realistic. If a skill requires sensitive data or legal advice, include an explicit guardrail that escalates to a human.
