# Polish Guide

## Style Targets

### Style A: Plain Precise
- Prefer active voice, sentences < 25 words avg
- Eliminate hedge words: "somewhat", "rather", "quite"
- Strong verbs: "demonstrate" > "show", "employ" > "use", "achieve" > "get"
- Never start Introduction with "In this paper, we..."
- Transformations: "In order to" → "To", "It can be seen that" → (delete)

### Style B: Narrative Fluent
- Topic sentence must preview the paragraph
- Add 1-2 sentence bridges between sections
- Replace dangling "this" with explicit noun
- Signpost transitions: "Building on this,", "Crucially,"
- Abstract structure: Problem → Why hard → Our approach → Key result

### Style C: Formal Academic
- Passive voice acceptable in Methods/Results
- Hedge empirical claims: "suggests", "indicates", "appears to"
- Formal vocabulary: "investigate" > "look at", "substantial" > "big"
- Full sentences in all captions (not fragments)

---

## Critic Protocol

### blocks_mentor = true Criteria
Set ONLY when:
1. logic_score <= 2 (argument is so broken polish is premature), OR
2. Section is structurally absent (not detected), OR
3. A Critical-severity blocker applies to this section

### Logic Score Rubric (1-5)
- 5: Perfect flow, every claim justified
- 4: Minor gap, one unjustified assumption
- 3: Noticeable gaps, would confuse careful reviewer
- 2: Major errors, unsupported claims, missing baselines → blocks_mentor
- 1: Fundamental incoherence → blocks_mentor

### Expression Score Rubric (1-5)
- 5: Publication-ready, no improvement needed
- 4: 1-3 weak sentences per section
- 3: Several awkward constructions
- 2: Heavy polish needed
- 1: Largely unclear

---

## Mentor Protocol

### Priority Order
1. Clarity blockers (unparseable sentences)
2. Style-specific transformations (A/B/C rules above)
3. Critic top_issues in order
4. Pre-check expression_issues for this section
5. Word-level improvements

### Forbidden Mentor Actions
- Rewriting entire paragraphs without showing original
- Changing cited claims or adding/removing citations
- Adding new technical content
- Removing limitations or negative results

### Context Window Management
- Mentor receives ONLY the target section via Read(offset=start-1, limit=end-start+1)
- For sections > 1200 words: orchestrator splits at subsection boundaries,
  spawns two Mentor calls
