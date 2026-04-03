---
name: referee-response
description: Drafts a point-by-point response letter to referee comments with suggested edits. Use after a revise-and-resubmit.
argument-hint: "<path> or 'paste'"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Draft Referee Response

Draft a structured point-by-point response to referee comments.

## Arguments

- `$ARGUMENTS` — path to a file containing referee comments (e.g., `notes/referee-report-R1.txt`), or the word "paste" to accept inline input

## Steps

1. Read the referee comments:
   - If a file path is provided, read that file
   - If "paste" is specified, ask the user to paste the comments

2. Read `index.qmd` to understand the current manuscript content, structure, and arguments.

3. Parse the referee comments into individual points. Each point typically starts with a number, letter, or dash.

4. For each referee point, draft a structured response:

   ```markdown
   **Point N:** [Quote or paraphrase the referee's comment]

   **Response:** [Address the comment — acknowledge the concern, explain what was done
   or why you disagree, provide additional evidence or reasoning]

   **Changes made:** [Describe specific edits with section references, e.g.,
   "We have added two paragraphs to Section 3 (@sec-data) clarifying the sample selection."]
   ```

5. Use appropriate response conventions:
   - Thank the referee for constructive comments
   - Be respectful even when disagreeing
   - Distinguish between changes made and changes not made (with justification)
   - Reference specific sections, tables, and figures in the manuscript
   - If a comment requires new analysis, note what was done and where results appear

6. Organize the response by referee:
   ```markdown
   # Response to Referee Comments

   ## Referee 1

   [Point-by-point responses]

   ## Referee 2

   [Point-by-point responses]

   ## Editor

   [Point-by-point responses]
   ```

7. Save the response letter to `notes/referee-response-R<N>.md` where N is the revision round number (check existing files to determine the round).

8. Generate a separate list of suggested manuscript edits — specific changes to `index.qmd` or notebooks that address the referee's concerns. Present these to the user but do NOT apply them without explicit approval.

9. Report the response letter file path and the list of suggested edits.

## Error handling

- If the comments file does not exist, ask for the correct path.
- If the comments are too brief or ambiguous to parse into individual points, present them as-is and ask the user to help segment them.
