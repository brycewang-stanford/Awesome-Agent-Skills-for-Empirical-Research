# Example — R&R Response Letter

A worked example of a point-by-point response letter for a Revise &
Resubmit at AER. Built on the same fictional broadband paper used in
`intro-example.md`. Read this alongside `skills/aer-rebuttal/SKILL.md`.

The example demonstrates: triage, the four response outcomes (concede,
clarify, both, push back), explicit revision pointers, and editor-
efficient first sentences.

---

## Cover Letter to the Editor

```
[Date]

Professor [Editor Name]
American Economic Review
American Economic Association

Dear Professor [Editor Name],

Thank you for the opportunity to revise our manuscript "Broadband
Expansion and Local Wage Inequality: Evidence from the FCC's Connect
America Fund" (MS# AER-2026-0XXX) and for the constructive comments
from you and the three referees.

The revision addresses every comment as detailed in the response letter
below. The most substantive changes are:

1. We replace our staggered two-way fixed-effects specification with
   the Callaway-Sant'Anna doubly-robust estimator throughout (Section
   3, Tables 2-3, Figure 2). This addresses concerns from Referees 1
   and 3 about heterogeneous treatment effects.

2. We add a Bartik-style robustness check using a leave-one-out
   exposure measure to address Referee 2's concern about endogenous
   industry composition (new Section 5.2, Table 5).

3. We narrow our welfare claim from "broadband expansion reduces
   welfare" to "broadband expansion has ambiguous welfare consequences
   under standard parameter values" (Section 6, page 28), reflecting
   the sensitivity analysis we now report in response to Referee 1.

A marked-up version of the manuscript accompanies the clean revision.

Sincerely,
[Authors]
```

*Cover letter is one page. Three substantive bullets identifying the
biggest changes. Editor knows what to look for in 60 seconds.*

---

## Response to the Editor

### Comment E1

> *The referees agree that the question is important and the data are
> novel, but they raise serious concerns about the empirical strategy.
> Please address Referee 1's identification critique as the highest
> priority.*

**Response.** We have rebuilt the empirical strategy around the
Callaway-Sant'Anna (2021) doubly-robust estimator throughout the paper,
which directly addresses Referee 1's TWFE-staggered-bias critique. The
new main result (Table 3, column 4, page 19) is quantitatively close to
the original — 4.2 log points vs. the original 4.6 — but is now defensible
under heterogeneous treatment effects. We also report the Goodman-Bacon
decomposition (Appendix Table A.4) showing that 94% of the implicit
weight in our original TWFE came from valid comparisons, which explains
why the modern estimator yields a similar magnitude. Honest DiD sensitivity
bounds (Appendix Figure A.6) are reported alongside.

### Comment E2

> *Please ensure all replication materials comply with the AEA Data and
> Code Availability Policy.*

**Response.** A complete openICPSR deposit accompanies this revision.
The README follows the AEA Data Editor's template and is also available
at the project's deposit page. We have self-tested the master script on
a clean macOS install; total runtime is 27 minutes. The deposit ID is
[XXX].

---

## Response to Referee 1

### Comment R1.1 (high-risk; major)

> *The authors use two-way fixed effects with staggered treatment
> timing. Goodman-Bacon (2021) and de Chaisemartin and D'Haultfœuille
> (2020) show this estimator is biased when treatment effects are
> heterogeneous across units or over time. The result may be a
> mechanical artifact of the estimator.*

**Response.** **Agreed and revised.** We have replaced the TWFE
specification throughout with the Callaway-Sant'Anna (2021) doubly-
robust estimator. The new main result, reported in Table 3 (page 19),
is 4.2 log points (s.e. 1.1) over a six-year horizon, compared with the
original TWFE estimate of 4.6 log points (s.e. 1.0). The estimates are
quantitatively close because, as we now show in Appendix Table A.4 via
the Goodman-Bacon decomposition, 94% of the implicit weight in our
original specification came from valid (never-treated vs. eventually-
treated) comparisons. We are grateful to the referee for prompting this
change, which substantially strengthens the identification.

*Action stated in first sentence. Magnitude given. Mechanism for why
the result didn't change is explained, anticipating the editor's
"are you sure?" question.*

### Comment R1.2 (high-risk; major)

> *The parallel-trends assumption appears to fail in pre-period 2007-08
> (Figure 2 of the original draft).*

**Response.** **Agreed and revised.** We now report Honest DiD
sensitivity bounds (Rambachan and Roth 2023) in Appendix Figure A.6.
Under the relative-magnitudes restriction with M-bar up to 0.3 (i.e.,
allowing post-period violations as large as 30% of the worst pre-period
violation), the lower bound of our 6-year estimate remains positive at
1.8 log points. We have rewritten the relevant passage on page 14 to
state explicitly that the estimate is robust to pre-trend violations of
this magnitude but would lose statistical significance under M-bar above
0.6.

### Comment R1.3 (clarity; minor)

> *The discussion of the welfare calculation in Section 6 is too brief.*

**Response.** **Revised in manuscript.** Section 6 now includes a
two-paragraph discussion (pages 26-27) of the welfare framework's
assumptions, with explicit sensitivity to the inequality-aversion
parameter γ ∈ [0.5, 2.0]. Under this range, we now characterize the
welfare effect as **ambiguous in sign**, rather than negative — a
substantive softening of the original claim that responds to the
referee's concern and to Referee 2's related critique.

---

## Response to Referee 2

### Comment R2.1 (evidence_gap; major)

> *The shift-share construction in Section 5.1 uses national industry
> shares interacted with local pre-period exposure. Goldsmith-Pinkham
> et al. (2020) and Borusyak et al. (2022) emphasize that the validity
> of this design depends critically on which margin is treated as
> exogenous.*

**Response.** **Agreed and revised.** We now follow the Borusyak-Hull-
Jaravel (2022) recommendation and report both estimators. Our preferred
specification (Table 5, columns 1-3) treats the *shocks* as exogenous;
we report Rotemberg-weight diagnostics for the alternative (Goldsmith-
Pinkham) interpretation in Appendix Table A.7. The top-5 industries
driving identification under the share-exogeneity interpretation are
listed and discussed on page 22. Both interpretations yield economically
similar magnitudes (within 15% of each other), which we now state
explicitly on page 21.

### Comment R2.2 (incorrect_premise)

> *The authors' welfare calculation assumes a representative consumer.
> This is inconsistent with their finding that the effects concentrate
> at the top of the distribution.*

**Response.** **Respectfully disagree.** The representative-consumer
framework in our welfare calculation is *not* what produces the
distributional results — those come directly from the reduced-form
estimates of effects by wage decile. The welfare framework aggregates
those distributional effects under a social welfare function with
inequality aversion γ. We have clarified this distinction in Section 6.1
(page 25) and added Appendix C, which derives the welfare integral
explicitly to make the role of γ transparent. We hope this resolves the
concern; if the referee meant something different, we would welcome
further guidance.

*Push-back done respectfully. Explains why the concern reflects a
misreading, but invites further dialogue rather than stonewalling.*

---

## Response to Referee 3

### Comment R3.1 (scope_mismatch; minor)

> *It would be useful to extend the analysis to mobile broadband.*

**Response.** **Declined with justification.** The Connect America Fund
Phase II auction subsidized fixed wireline broadband specifically;
extending the analysis to mobile broadband would require a different
identification strategy (the FCC mobile auctions ran on a different
timeline and used a different exposure mechanism). We have added a
sentence in the conclusion (page 29) flagging mobile broadband as a
distinct question for future work but do not extend the empirical
analysis here. We hope the referee agrees that this preserves the
paper's identification clarity.

### Comment R3.2 (misunderstanding; minor)

> *The authors do not report the first-stage F statistic for their IV
> specification.*

**Response.** **Clarified in response.** The first-stage F statistic
(108.4, clustered at the commuting-zone level) is already reported in
the original Table 4, footnote (a). To make this more discoverable, we
have moved it to a dedicated row in the table body in the revised draft
(Table 4, row "First-stage F", page 20). We are also reporting the Olea-
Pflueger effective F (107.9) and Anderson-Rubin 95% confidence intervals
(0.012, 0.087) in Appendix Table A.8, in line with current best practice
(Andrews, Stock and Sun 2019).

---

## Summary Statistics for the Revision

| Metric | Value |
|---|---|
| Total comments addressed | 18 (E: 2, R1: 6, R2: 5, R3: 5) |
| Conceded with major revision | 8 |
| Conceded with minor revision | 6 |
| Clarified without manuscript change | 2 |
| Respectfully declined | 2 |
| New tables added | 3 (Tables 5, A.4, A.7) |
| New figures added | 2 (Figures A.5, A.6) |
| New appendices | 1 (Appendix C, welfare derivation) |
| Manuscript page change | +4 main text, +9 appendix |
| Response letter length | 14 pages |

---

## What This Example Demonstrates

1. **Every comment ends in exactly one outcome.** Conceded, clarified,
   conceded+clarified, or respectfully declined. No vague middle.
2. **Action stated in the first 1-2 sentences.** Editor scans; the
   first sentence gives the verdict.
3. **Page and line references for every revision.** Editor verifies.
4. **The push-back (R2.2) is substantive.** It explains why the
   concern reflects a misreading, rather than rejecting the comment.
5. **The decline (R3.1) is honest.** It does not pretend the request
   is unreasonable; it explains the scope boundary.
6. **The clarification (R3.2) takes the buried-information path.**
   The information existed; the referee couldn't find it. The fix is
   to move the information, not to add new analysis.

---

## What Not to Do

A common failure mode — the *thanks-without-action* response:

> *(Bad)* "We thank the referee for this insightful comment, which has
> substantially improved the paper. We have revised the discussion of
> identification accordingly."

What's wrong:
- No action specified
- No page reference
- "Insightful" is filler
- "Improved the paper" is unverifiable

The editor will read this as evasion. Always lead with the verb:
**replaced**, **added**, **rewrote**, **clarified**, **declined**.
