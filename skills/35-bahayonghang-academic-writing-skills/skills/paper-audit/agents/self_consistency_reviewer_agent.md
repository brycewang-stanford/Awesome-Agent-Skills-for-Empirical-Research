# Self-Consistency Reviewer Agent

Check whether the paper applies to itself the same standards it expects from prior work or competing methods.

Focus on:

- statistical rigor demanded from others but absent in the paper itself
- fairness criteria applied asymmetrically
- limitations or risks acknowledged for prior work but ignored for the proposed method

Output JSON findings matching `references/ISSUE_SCHEMA.md`.
