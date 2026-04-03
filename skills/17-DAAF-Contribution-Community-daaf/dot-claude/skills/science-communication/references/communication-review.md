# Communication Review

A systematic review framework for checking the quality of any data communication deliverable before finalization. Apply the 10-point checklist to every deliverable, then scan for the common pitfalls and statistical misinterpretation sins cataloged below.

## 10-Point Communication Review Checklist

Apply to every deliverable — executive summary, policy brief, presentation, report, or talking points — before sharing with any audience.

### The Checklist

| # | Check | Question to Ask | Pass Criteria |
|---|-------|-----------------|---------------|
| 1 | **Audience alignment** | Is the vocabulary, structure, and detail level appropriate for the stated audience? | No jargon for non-technical audiences; no oversimplification for technical audiences. See `audience-analysis.md` strategy tables. |
| 2 | **"So what?" present** | Does every finding carry an implication? Can the reader answer "why should I care?" after each section? | Every finding has at least a finding→implication chain. Key findings have finding→implication→action. |
| 3 | **Lead with the bottom line** | Does the deliverable open with the most important finding or recommendation — not with background or methodology? | The first paragraph (or first slide) states the main takeaway. Background comes after, not before. |
| 4 | **Causal language appropriate** | Does the strength of linking language match the study design? No causal claims from observational data without explicit design disclosure? | Check every verb connecting exposure to outcome against `plain-language.md` causal language guide. Recommendations do not exceed inferential capacity. |
| 5 | **Uncertainty communicated honestly** | Are findings hedged appropriately — not overconfident, not buried in caveats? | Hedging level matches evidence strength (see `plain-language.md` hedging scale). No "prove" language. Key limitations stated but not over-stated. |
| 6 | **Numbers are interpretable** | Are statistics presented in a way the audience can understand? Are comparisons meaningful? | Percentages have denominators. Differences have baselines. Large numbers have context. "1 in 5" preferred over "20%" for general audiences. |
| 7 | **Visuals match narrative** | Do charts tell the same story as the text? Are chart titles declarative (explanatory) for non-technical audiences? | No chart contradicts the narrative. Every chart has a title that states its message. Source notes present. |
| 8 | **Equity-aware framing** | Is language people-first? Are demographic groups presented respectfully? Are default comparison groups considered? | No dehumanizing labels. No white/male-as-default without justification. See `accessibility-equity.md`. |
| 9 | **Self-contained** | Could someone read only this deliverable (not the full report, not the appendix) and understand the findings? | Key findings, methodology summary, and caveats are all present within the deliverable itself. |
| 10 | **Actionable conclusion** | Does the deliverable end with clear next steps, recommendations, or specific open questions — not just "more research is needed"? | The reader knows what to do (or what to decide) after reading. |

### How to Use the Checklist

1. **Complete drafting first.** Don't apply the checklist during writing — it interrupts flow. Write the full draft, then review.
2. **Check each item independently.** Don't let a strong "so what?" compensate for inappropriate causal language.
3. **Mark failures explicitly.** If any item fails, fix it before sharing. No item is optional.
4. **Have someone else apply it if possible.** Self-review is limited by the curse of knowledge (see pitfalls below).

---

## Seven Deadly Sins of Statistical Misinterpretation

From Louis & Chapman (2017), adapted for data communication review. Each sin represents a way that statistical findings can be misrepresented or misunderstood in communication.

### Sin 1: Treating Small Differences as Meaningful

**The error:** Reporting a difference as noteworthy when it falls within the margin of error or random variation. A 1-point polling lead within a ±3-point margin tells you nothing.

**In communication:** "Group A scored higher than Group B" when the difference is 0.3 points on a 100-point scale.

**Prevention:** Always contextualize differences with their uncertainty. Ask: "Is this difference larger than the noise?" If you cannot report a confidence interval, at minimum note whether the difference is "meaningful" vs. "within the range of normal variation."

### Sin 2: Equating Statistical Significance with Practical Significance

**The error:** Conflating "statistically significant" (unlikely due to chance) with "meaningful" or "important." A statistically significant effect can be trivially small.

**In communication:** "We found a significant relationship between X and Y" without reporting effect size or practical magnitude.

**Prevention:** Always report the *size* of the effect, not just its existence. "The program improved test scores by 2 percentile points (statistically significant)" lets the reader judge whether 2 points matters for their context. For non-technical audiences, drop the significance language entirely and just state the effect size with appropriate hedging.

### Sin 3: Ignoring the Tails

**The error:** Focusing only on group averages when the distribution matters. Two groups with identical averages can have dramatically different distributions — and the extremes are often the most policy-relevant.

**In communication:** "The average student performs at grade level" when 25% of students are two or more years below grade level.

**Prevention:** When averages tell an incomplete story, show the distribution. Report percentiles, ranges, or proportions above/below thresholds. "The average masks considerable variation: while most students are at or above grade level, 1 in 4 are two or more years behind."

### Sin 4: Trusting Spurious Correlations

**The error:** Reporting a correlation found through extensive data mining as if it were a meaningful relationship. With enough variables, spurious correlations are guaranteed.

**In communication:** Presenting a data-mined association without noting that it was discovered post hoc or that many comparisons were tested.

**Prevention:** Distinguish pre-registered hypotheses from exploratory findings. If a result was discovered during analysis (not predicted beforehand), label it as "exploratory" and note that it requires replication. For non-technical audiences: "We found an interesting pattern, but it needs to be confirmed with additional data."

### Sin 5: Getting Causation Backwards

**The error:** Assuming the direction of causation without considering reverse causality. Does unemployment cause depression, or does depression increase unemployment risk?

**In communication:** "Factor X leads to outcome Y" when the arrow could run in either direction.

**Prevention:** For every association, explicitly consider: could the outcome be causing the exposure? If you can't rule it out, use bidirectionally neutral language: "X and Y are associated" rather than "X leads to Y." See `plain-language.md` for causal language guidance.

### Sin 6: Forgetting Confounders

**The error:** Presenting an association between two variables without acknowledging that a third variable (a confounder) might explain both. Eating more vegetables "correlates with" better health — but income drives both vegetable consumption and health outcomes.

**In communication:** "People who do X have better outcomes" without noting that people who do X may differ systematically from people who don't.

**Prevention:** State what you controlled for and what you couldn't control for. "After accounting for income, education, and age, the association between X and Y remained — though we cannot rule out other unmeasured factors."

### Sin 7: Misleading with Visualization

**The error:** Using visual design choices (truncated axes, distorted scales, cherry-picked time windows) to exaggerate or minimize findings.

**In communication:** A bar chart with a y-axis starting at 50 instead of 0, making a 3-point difference look dramatic.

**Prevention:** Follow the integrity checklist in data-scientist visualization references. Bar charts start at zero. Axes are labeled. Scales are consistent across comparison panels. The visual impression matches the actual magnitude of the finding.

---

## Additional Communication Pitfalls

Beyond statistical misinterpretation, these pitfalls are specific to the act of communicating findings to non-technical audiences.

### Jargon Leakage

**The problem:** Technical terms slip into non-technical communication unnoticed by the writer, who is so familiar with the terms that they no longer register as jargon.

**Examples:** "We controlled for confounders" / "The regression coefficient was..." / "After propensity score matching..." in a policy brief.

**Prevention:** Read the deliverable aloud to someone outside your field. Every term they stumble on is jargon that needs replacement. Consult the jargon translation table in `plain-language.md`.

### Curse of Knowledge

**The problem:** Once you understand something, you cannot easily imagine not understanding it. You unconsciously assume the reader shares your background, your context, and your mental model.

**Examples:** Skipping explanation of a concept that feels "obvious" to you but is unfamiliar to the reader. Using acronyms without definition. Presenting a chart that requires domain knowledge to interpret.

**Prevention:** Write for the least knowledgeable member of your target audience. Define acronyms on first use. Ask: "Would I understand this if I hadn't done this analysis?" Have someone outside the project review the draft.

### Over-Caveating

**The problem:** Listing every limitation until the reader concludes the findings are worthless. Researchers are trained to enumerate limitations exhaustively; non-technical audiences interpret extensive caveats as "this study is unreliable."

**Examples:** Three paragraphs of limitations after two paragraphs of findings. "However, it should be noted that... Furthermore, it is important to caveat that... Additionally, one must consider that..."

**Prevention:** Apply the IES "too important to exclude" filter: include only the limitations that could meaningfully change the interpretation. Frame limitations as open questions: "We don't yet know whether..." rather than "A limitation of this study is..."

### Under-Caveating

**The problem:** The opposite of over-caveating — omitting important limitations to make findings appear more definitive than they are. This is an integrity issue.

**Examples:** Presenting observational findings as if they were causal. Omitting that results only apply to a specific subpopulation. Not mentioning that a key variable was unavailable.

**Prevention:** Include the limitations that would change a reader's interpretation if they knew about them. The test: "Would an informed critic point out something I haven't mentioned?" If yes, mention it.

### Schrödinger's Causal Inference

**The problem:** Using cautious associational language in findings but implying causation in recommendations. Per Haber et al. (2022), 44.5% of published papers with action recommendations implied stronger causality in recommendations than in findings.

**Examples:** Findings: "X is associated with Y." Conclusion: "Policymakers should adopt X to improve Y." The causal claim exists and doesn't exist depending on which section you read.

**Prevention:** The strength of language in recommendations must not exceed the strength of language in findings. If you found an "association," your recommendation cannot assume a causal mechanism. See `plain-language.md` for the full causal language framework.

### Numerical Overload

**The problem:** Presenting too many numbers too quickly, overwhelming the reader's working memory. Research shows most people can hold 3-4 items in working memory simultaneously.

**Examples:** "The coefficient was 0.34 (SE = 0.08, p < 0.001, 95% CI [0.18, 0.50]), indicating that a one-standard-deviation increase in X is associated with a 0.34-standard-deviation increase in Y, which corresponds to roughly 12 percentile points (N = 4,523)."

**Prevention:** Present one number at a time. Lead with the most intuitive number ("about 12 percentile points"). Put technical details in footnotes or appendices. For non-technical audiences, round aggressively: "about 12 points" not "11.7 percentile points."

### Missing the "So What"

**The problem:** Reporting findings without explaining their significance. The reader is left with data but no meaning.

**Examples:** "Students in District A scored 14 points higher than students in District B." (So what? Is that a lot? What should someone do about it?)

**Prevention:** Apply the "So What?" framework (see `narrative-frameworks.md`) to every finding. Finding → Implication → Action. "Students in District A scored 14 points higher — roughly one full grade level. This suggests that District A's literacy program model may be worth replicating."

### Confusing Verbal Probability

**The problem:** Using probability words that mean different things to different people. "Likely" means ~70% to most laypeople but 66-100% in the IPCC framework. "Rare" could mean 1% or 10% depending on context.

**Examples:** "Adverse effects are unlikely" — does this mean 5%? 20%? 33%?

**Prevention:** Pair verbal probability with concrete context: "Adverse effects are uncommon — in our study, fewer than 3% of participants experienced any side effect." See the IPCC calibrated uncertainty framework in `plain-language.md` for a systematic approach.

### Deficit Model Thinking

**The problem:** Assuming that the audience's failure to adopt your conclusion stems from their lack of information, rather than from legitimate differences in values, priorities, or interpretation. "If they just understood the data, they'd agree with us."

**Examples:** Responding to audience skepticism by presenting more data instead of engaging with their concerns. Framing public disagreement as "science illiteracy."

**Prevention:** Recognize that evidence is one input to decisions, not the only input. People can understand your findings and still reach different conclusions based on different values. Communicate findings clearly and let the audience draw their own conclusions. Engage with concerns rather than repeating the data louder.

### Equity-Blind Communication

**The problem:** Presenting data about people without considering how the framing, language, and defaults affect those people. Using demographic groups as decoration rather than treating them as audiences who will encounter the work.

**Examples:** Using "minorities" when you mean "communities of color." Defaulting to white/male as the comparison group. Framing achievement gaps as deficits of one group rather than as systemic inequities.

**Prevention:** See `accessibility-equity.md` for comprehensive guidance on people-first language, equity-aware framing, and the Urban Institute Do No Harm principles.

---

## Quick Pre-Release Review Protocol

Before sharing any deliverable, spend 10 minutes on this rapid review:

1. **Read only the first paragraph and the last paragraph.** Do they tell a coherent story? Is the bottom line clear in both places?
2. **Scan every verb connecting a cause to an effect.** Is the causal strength appropriate? (Checklist item 4)
3. **Count the caveats.** Are there too many (>3 in a brief) or too few (0 in a brief)?
4. **Read chart titles in isolation.** Do they state findings? Could someone understand the story from titles alone?
5. **Search for jargon.** Ctrl+F for technical terms from the jargon translation table. Replace any that survived.
6. **Read the recommendations.** Do they exceed the inferential capacity of the findings?
7. **Check the "so what."** After the last finding, ask yourself: "Would the reader know what to do next?"

## References and Further Reading

Haber, N.A. et al. (2022). "Causal and Associational Language in Observational Health Research." *American Journal of Epidemiology*, 191(12), 2084-2097.

Louis, W. and Chapman, C. (2017). "The Seven Deadly Sins of Statistical Misinterpretation, and How to Avoid Them." *The Conversation*. https://theconversation.com/the-seven-deadly-sins-of-statistical-misinterpretation-and-how-to-avoid-them-74306

IES. "Six Strategies for Effectively Communicating Research Findings to Decision Makers." https://ies.ed.gov/blogs/research/post/six-strategies-for-effectively-communicating-research-findings-to-decision-makers

Cairo, A. (2016). *The Truthful Art: Data, Charts, and Maps for Communication*. New Riders.

Tufte, E.R. (1983). *The Visual Display of Quantitative Information*. Graphics Press.
