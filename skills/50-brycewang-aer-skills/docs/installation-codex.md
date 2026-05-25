# Installation — Codex

## Clone and Copy

```bash
git clone https://github.com/brycewang-stanford/AER-skills.git
cd AER-skills
mkdir -p ~/.codex/skills
cp -R skills/aer-* ~/.codex/skills/
```

Restart Codex so new skills are picked up.

Manual copying installs the skill instructions. Keep the cloned repository
available if you want the `templates/` and `examples/` resources referenced by
the skills.

## Verify

Ask Codex:

```
List all skills starting with aer-.
```

You should see all nine.

## First Prompt

```
Use aer-workflow to decide which skill to apply to this paper next.
```

## Updating

```bash
cd AER-skills
git pull
cp -R skills/aer-* ~/.codex/skills/
```

## One-Line Install for Codex

If you'd rather have Codex install for you, paste this into Codex:

```
Install the AER-skills bundle into ~/.codex/skills/: aer-workflow,
aer-topic-selection, aer-identification, aer-robustness, aer-introduction,
aer-tables-figures, aer-replication, aer-submission, aer-rebuttal. Copy the
full skill directories, not just SKILL.md. When finished, list the installed
directories and use aer-workflow to tell me which skill I should apply next
to my manuscript.
```

## Coexistence with Claude Code

Codex uses `~/.codex/skills/`; Claude Code uses `~/.claude/skills/`. The two install locations are independent and do not conflict.
