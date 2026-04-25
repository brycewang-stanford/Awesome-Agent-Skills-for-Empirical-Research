# Awesome Agent Skills for Empirical Research

<div align="center">

**🌐 Language / 语言: English | [中文](README.md)**

<br/>

  <table>
    <tr>
      <td align="center">
        <a href="https://copaper.ai"><img src="images/copaper-logo.png" alt="CoPaper.AI" width="260" /></a>
      </td>
      <td width="60"></td>
      <td align="center">
        <img src="images/stanford-reap-logo.png" alt="Stanford REAP - Center on China's Economy & Institutions" width="380" />
      </td>
    </tr>
  </table>
  <br/>
</div>

[![Awesome](https://awesome.re/badge.svg)](https://awesome.re)
[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Maintained by CoPaper.AI from Stanford REAP](https://img.shields.io/badge/Maintained%20by-CoPaper.AI%20from%20Stanford%20REAP-blue)](https://copaper.ai)

**The Definitive Collection of AI Agent Skills for Empirical Research — 119 GitHub Repos / 23,000+ Skills**

> A curated, opinionated list of **119 GitHub repositories** and **23,000+ AI Agent Skills** for empirical research in economics, political science, sociology, psychology, public health, education, management, finance, and public policy — organized by research workflow, from topic selection to journal submission.

In 2026, the way we do empirical research is being redefined. [CoPaper.AI](https://copaper.ai) can **complete a publication-quality empirical paper in 20 minutes** — from data import, descriptive statistics, causal inference models, robustness checks to formatted result tables, all in one go. The secret isn't a more powerful model — it's **Skills**: encoding senior researchers' methodological expertise into structured workflows, so the AI knows "what a complete DID analysis should include" instead of waiting for you to remind it step by step.

This repository is the **Agent Skills landscape** we compiled while building CoPaper.AI. We organized hundreds of Skills repos and tens of thousands of Skills scattered across GitHub, communities, and academia by research workflow stages, so you can pick what you need.

> **[CoPaper.AI](https://copaper.ai)** ships with **20 built-in econometric methodology Skills** (DID, IV, RDD, PSM, DML, and more), supports one-sentence triggers, multi-agent collaboration, and automatic result output. Want it out of the box? Try it: [copaper.ai](https://copaper.ai)

---

## 🆕 Changelog

<details open>
<summary><b>2026-04-24: 📗 Full Empirical Analysis Skill (R) shipped — tidyverse + fixest, 8-step Quarto-friendly loop (skills/00.3)</b></summary>

- **📗 [Full Empirical Analysis Skill — R](skills/00.3-Full-empirical-analysis-skill_R/)**: Same-day fourth member of the family, vendored at [`skills/00.3-Full-empirical-analysis-skill_R/`](skills/00.3-Full-empirical-analysis-skill_R/) — **slot #0.3, the R / Quarto edition**.
  - **🧱 Modern tidyverse + fixest stack**: `dplyr` / `tidyr` / `haven` for data; `fixest::feols/feglm/fepois` as the panel/IV/DID workhorse (one line for HD FE + multi-way cluster + IV); `did::att_gt` + `fixest::sunab` + `didimputation::did_imputation` + `synthdid` + `DIDmultiplegtDYN` + `bacondecomp` + `HonestDiD` for modern DID; `rdrobust` / `rddensity` / `rdmulti` / `rdlocrand` for RD; `Synth` / `gsynth` / `tidysynth` / `synthdid` for synthetic control; `MatchIt` / `WeightIt` / `cobalt` / `ebal` for matching; `grf::causal_forest` + `DoubleML` for ML causal; `mediation::mediate` + `lavaan::sem` for mediation; `marginaleffects::avg_slopes` / `plot_slopes` for post-estimation; `modelsummary` / `kableExtra` / `gt` / `flextable` for publication tables; `ggplot2` + `iplot` + `binsreg` + `cowplot` + `patchwork` for figures; `Quarto` to render PDF/HTML/Word in one command.
  - **🔁 8-step R closed loop (mirrors 00.1 / 00.2)**: (1) Import & cleaning (`read_dta` + `clean_names` + `naniar::vis_miss` + `mice` + `validate` / `assertr`) → (2) Variable construction (`mutate` + `across` + `DescTools::Winsorize` + `scale` + `arrange %>% group_by %>% lag/lead`) → (3) Descriptives (`gtsummary::tbl_summary` + `modelsummary::datasummary_balance` + `psych::corr.test` + `corrplot` / `ggcorrplot`) → (4) Diagnostics (12 classes: `shapiro.test` / `tseries::jarque.bera.test` / `lmtest::bptest` / `dwtest` / `bgtest` / `car::vif` / `tseries::adf.test` / `kpss.test` / `plm::pbgtest` / `pcdtest` / `phtest` / `lmtest::resettest`) → (5) Estimation (12 classes: `feols` + `AER::ivreg` + `did::att_gt` + `fixest::sunab` + `didimputation` + `synthdid` + `rdrobust` + `tidysynth` + `gsynth` + `MatchIt` + `WeightIt` + `ebal` + `grf::causal_forest` + `DoubleML` + `sampleSelection::heckit` + `quantreg::rq` + `lavaan::sem`) → (6) Robustness (`modelsummary` for M1–M6 + `clubSandwich` + `fwildclusterboot::boottest` + `ri2::conduct_ri` + `bacondecomp::bacon` + `HonestDiD::createSensitivityResults` + `robomit::o_test/o_beta`) → (7) Further analysis (formula interactions + `marginaleffects::plot_slopes` + `mediation::mediate` + `medsens` + `lavaan::sem` multi-group + `grf::causal_forest` CATE + `splines::ns` dose-response) → (8) Publication output (`modelsummary` to LaTeX/Word/HTML/Markdown in one call + `fixest::iplot` + `marginaleffects::plot_slopes/predictions` + `cowplot::plot_grid` + `patchwork` + `Quarto` rendering).
  - **📚 Progressive disclosure + Quarto-native**: `SKILL.md` 893-line spine (with full `install.packages` list, project skeleton, Quarto YAML template); 8 [`references/NN-*.md`](skills/00.3-Full-empirical-analysis-skill_R/references/) totalling 3700+ lines. The Quarto template makes "narrative + code + tables + figures" render to a single self-contained report from a single `.qmd` source.
  - **🆚 Four-skill positioning**: StatsPAI = Python one-shot DSL; 00.1 = explicit Python; 00.2 = explicit Stata; 00.3 = **R + tidyverse + Quarto**. Four parallel implementations of the same 8 steps, none replacing the others. **The Quarto-rendered reproducibility report is unique to 00.3.**
  - **Use cases**: Quarto-rendered replication reports, academic blogs (`distill` / `quarto blog`), graduate R courses, rigorous projects needing `marginaleffects` + `mediation` + `grf` post-estimation, anything R-flavoured outside of pure Bayesian work.

</details>

<details>
<summary><b>2026-04-24: 📊 Full Empirical Analysis Skill (Stata) shipped — traditional Stata ecosystem, 8-step .do loop (skills/00.2)</b></summary>

- **📊 [Full Empirical Analysis Skill — Stata](skills/00.2-Full-empirical-analysis-skill_Stata/)**: Same-day Stata sibling of StatsPAI / 00.1, vendored at [`skills/00.2-Full-empirical-analysis-skill_Stata/`](skills/00.2-Full-empirical-analysis-skill_Stata/) — **slot #0.2, for Stata users**.
  - **🧱 Traditional Stata ecosystem, de-facto standard command chain**: every step calls community-standard commands `reghdfe` / `ivreg2` / `ivreghdfe` / `csdid` / `did_imputation` / `eventstudyinteract` / `sdid` / `did_multiplegt_dyn` / `bacondecomp` / `honestdid` / `rdrobust` / `rddensity` / `synth` / `synth_runner` / `psmatch2` / `teffects` / `ebalance` / `ppmlhdfe` / `boottest` / `ritest` / `rwolf` / `psacalc` / `coefplot` / `esttab` / `outreg2` / `asdoc` / `binscatter` — **referee-level Stata replication packs, one `ssc install` block installs 30+ packages**.
  - **🔁 8-step .do loop (same structure as 00.1, Stata-native rewrite)**: (1) Import & cleaning (`use`/`import excel`/`import sas`/`destring`/`misstable`/`mdesc`/`duplicates report`/`merge m:1 ... assert(match using)`/`xtset`/`xtdescribe`/`mi impute chained`) → (2) Variable construction (`winsor2 by(industry year)`/`egen std`/`xtile`/`xtset` + `L./F./D./S.`/CPI deflation/`first_treat`+`rel_time`+`gvar`) → (3) Descriptives (`tabstat`/`balancetable`/`asdoc sum`/`pwcorr, sig star(.05)`/`heatplot`/`twoway kdensity`/`xtdescribe`) → (4) Diagnostics (12 classes: `swilk`/`sktest`/`estat hettest`/`estat imtest, white`/`xtserial`/`xttest3`/`xtcsd, pesaran`/`estat vif`/`dfuller`/`kpss`/`xtunitroot ips/llc`/`hausman fe re`/`estat ovtest`/`linktest`) → (5) Estimation (12 classes: `reghdfe`+`areg`+`xtreg, fe/re`/`ivreg2`+`ivreghdfe`+`ivregress liml/gmm`/`csdid`+`eventstudyinteract`+`did_imputation`+`sdid`+`did_multiplegt_dyn`/`rdrobust`+`rdmc`+`rddensity`/`synth`+`synth_runner`/`psmatch2`+`teffects psmatch/ipwra/aipw`+`ebalance`+`cem`/`heckman`+`heckprob`/`qreg`+`sqreg`/`ppmlhdfe`/`sem`+`gsem`) → (6) Robustness (`eststo`+`esttab` M1–M6, multi-cluster, `boottest`, `ritest`, `rwolf`, `bacondecomp`, `honestdid`, `psacalc delta`) → (7) Further analysis (factor-var interactions+`margins`+`marginsplot`/`suest` cross-eq Wald/DDD/outcome ladder coefplot/`medsem`+`khb`+`sem` `estat teffects`/dose-response via `xtile` or `bspline`/Stata-Python bridge to `econml` for CATE/spillover) → (8) Publication output (`esttab`+`outreg2`+`asdoc` to `.tex`/`.rtf`/`.docx`/`.xlsx`; `coefplot`+`marginsplot`+`binscatter`+`rdplot`+`graph combine` to `.pdf`).
  - **📚 Progressive disclosure**: `SKILL.md` 801-line spine (full `ssc install` list + complete `.do` skeleton + library cheat-sheet); 8 [`references/NN-*.md`](skills/00.2-Full-empirical-analysis-skill_Stata/references/) totalling 3500+ lines, loaded on demand.
  - **🆚 Triple positioning** (now extended to 4 with 00.3): StatsPAI = Python DSL one-shot; 00.1 = explicit Python; 00.2 = **explicit Stata** — **the only choice when a referee or co-author insists on Stata replication**.
  - **Use cases**: referee-level Stata replication packs, graduate Stata courses, AER/QJE/JPE/ReStud-style standard `.do` pipelines, rigorous research needing the full modern DID toolkit (`bacondecomp` + `honestdid` + `psacalc`).

</details>

<details>
<summary><b>2026-04-24: 📘 Full Empirical Analysis Skill shipped — traditional Python econometric stack, explicit 8-step loop (skills/00.1)</b></summary>

- **📘 [Full Empirical Analysis Skill](skills/00.1-Full-empirical-analysis-skill/)**: Same-day sibling to StatsPAI, vendored at [`skills/00.1-Full-empirical-analysis-skill/`](skills/00.1-Full-empirical-analysis-skill/) — **slot #0.1, the explicit / auditable counterpart**.
  - **🧱 Traditional Python econometrics stack, no DSL wrapper**: every step directly calls `pandas` / `numpy` / `scipy` / `statsmodels` / `linearmodels` / `pyfixest` / `rdrobust` / `econml` / `causalml` / `matplotlib` / `seaborn` — every line of agent-written code is inspectable and swappable.
  - **🔁 8-step closed loop (finer granularity than StatsPAI's 6 steps)**: (1) Data cleaning (MCAR/MAR/MNAR handling, IQR/z/Mahalanobis outliers, `validate=` on every merge, panel-structure checks) → (2) Variable construction (log/IHS/Box–Cox, 1/99 winsorization, z/MinMax/Robust scaling, interactions/lags/diffs, CPI deflation, staggered-DID timing vars) → (3) Descriptive statistics (stratified Table 1 with SMDs+t-tests, starred correlation heatmap, 4-panel distribution figure, DID motivation plot, panel-coverage heatmap) → (4) Diagnostic tests (12 classes: normality / heteroskedasticity / autocorrelation / multicollinearity / stationarity / cointegration / endogeneity / weak-IV / overid / panel Hausman / RESET / Cook's D) → (5) Baseline modeling (12 classes of estimators: OLS / panel FE-RE-FD / GLM / IV-2SLS-LIML-GMM / DID×5-2×2/TWFE/event-study/CS/SA/BJS/SDiD / RD-Sharp/Fuzzy/Kink/multi-cutoff / SC / PSM-IPW-EB / DML / Causal Forest / Heckman / Quantile) → (6) Robustness battery (M1–M6 progressive specs, cluster-level sensitivity, wild cluster bootstrap, placebo timing+permutation, specification curve, Oster δ\*, LOO, Rosenbaum) → (7) Further analysis (heterogeneity × 4, outcome-ladder mechanism, Baron–Kenny + Imai mediation, moderated mediation, dose-response, spillover) → (8) Publication tables & figures (`stargazer` / `pyfixest.etable` / coefplot / event-study / binscatter / forest / RD plot / CATE heatmap / love plot, full LaTeX/Word/Excel export).
  - **📚 Progressive-disclosure architecture**: `SKILL.md` holds only the one canonical call per step (610 lines of spine); variants are offloaded to 8 [`references/NN-*.md`](skills/00.1-Full-empirical-analysis-skill/references/) deep manuals (3000+ lines total), **loaded by agents only when needed**.
  - **🆚 Relationship to StatsPAI**: StatsPAI = **agent-native one-shot DSL** (one `sp.causal(...)` runs everything); this skill = **explicit traditional stack** (every line swappable, every diagnostic by hand). They coexist and complement — reach for StatsPAI when you trust the DSL; reach for this skill when teaching, auditing, or requiring full control.
  - **Use cases**: replicating applied-economics papers, referee-level line-by-line audit, graduate teaching, any project that insists on hanging every diagnostic and robustness check into the explicit pipeline.

</details>

<details>
<summary><b>2026-04-24: 🔥 StatsPAI Skill officially shipped — end-to-end automated empirical analysis (skills/00)</b></summary>

- **🔥🔥 [StatsPAI Skill](skills/00-StatsPAI_skill/)**: Our **agent-native, one-stop empirical-analysis Skill** is now officially vendored in this repo at [`skills/00-StatsPAI_skill/`](skills/00-StatsPAI_skill/) — **slot #0, the repository's flagship**.
  - **🚀 End-to-end automation for the entire empirical pipeline**: data cleaning (pandas pre-step) → EDA & descriptives (`sp.sumstats` / `sp.balance_table`) → pre-flight diagnostics (`sp.diagnose` / `sp.balance_panel` / overlap / missingness) → research-question DSL (`sp.causal_question(...).identify()`) → LLM-assisted DAG discovery (`sp.llm_dag_propose` / `validate` / `constrained`) → one-call estimation (`sp.causal(...)`) → robustness (`sp.spec_curve` / `sp.honest_did` / `sp.evalue`). **6-step closed loop, no tool switching — the agent runs the whole thing from a single instruction.**
  - **900+ functions, one `import statspai as sp`**: more than doubled from the 390+ version on 2026-04-12. Covers OLS, IV, panel, DID (Callaway-Sant'Anna / Sun-Abraham / Bacon / HonestDID / continuous DID), RDD (Sharp / Fuzzy / multi-cutoff / Kink), PSM, SCM, SDID, DML, Causal Forest, Meta-Learners, TMLE, AIPW, neural causal models (TARNet / CFRNet / DragonNet), **text causal (`sp.causal_text`)**, Heckman, structural estimation (BLP).
  - **Agent-native self-describing API**: `sp.list_functions()` / `sp.describe_function()` / `sp.function_schema()` — agents discover and understand functions without doc lookup. Every estimator returns a unified `CausalResult` with `.summary()` / `.plot()` / `.to_latex()` / `.to_word()` / `.to_excel()` / `.cite()` and a structured `.diagnostics` dict — **purpose-built for LLM-driven workflows**.
  - **Estimand-first decisions**: `sp.causal_question` makes the "DID vs RD vs IV?" choice **explicit and defensible** — no more guesswork.
  - **Submitted to JOSS, MIT-licensed.** [→ PyPI](https://pypi.org/project/StatsPAI/) | [→ GitHub](https://github.com/brycewang-stanford/StatsPAI) | [→ Local Skill](skills/00-StatsPAI_skill/)
- **🔁 Weekly upstream sync**: new GitHub Action auto-pulls the latest `SKILL.md` / `README.md` from the StatsPAI main repo into [`skills/00-StatsPAI_skill/`](skills/00-StatsPAI_skill/) every week — **users always get the latest version**.
- Corrected several `sp.*` signatures in Skill code examples; Step 0–6 code blocks are now explicitly flagged as *illustrative* (so agents don't copy them verbatim).

</details>

<details>
<summary><b>2026-04-13: 🇨🇳 Original Chinese De-AIGC Skill Launched (skills/48)</b></summary>

- **🇨🇳🔥 [chinese-de-aigc](skills/48-copaper-ai-chinese-de-aigc/)**: **CoPaper.AI team's original Chinese academic de-AIGC skill**. Currently the only humanizer on GitHub dedicated to Chinese academic empirical papers and targeting China's CNKI AMLC / Wanfang / VIP / Turnitin Chinese detectors.
  - **17-pattern library of Chinese AI tells** (4-character clichés / hollow connectives / explicit transitions / absolutist claims / total-part-total symmetry / sentence-length uniformity)
  - **5-step closed-loop workflow**: Locate → Diagnose → Differential Rewrite → 5-Dim Self-Score → Second-Pass Review
  - **Per-section strategy**: Abstract / Introduction / Literature Review / Methods / Results / Discussion / Conclusion each has different rewrite intensity
  - **5-dimension scoring rubric**: Concreteness / Rhythm / Caution / Implicit Cohesion / Researcher Voice (weighted max 50)
  - **12 before/after case comparisons** covering 7 main chapters of empirical papers
  - Architecture inspired by English humanizers (humanizer_academic / skill-deslop / stop-slop / avoid-ai-writing), **but fully re-designed for Chinese language context**

</details>

<details>
<summary><b>2026-04-12: Added StatsPAI Agent-Native Econometrics Package + Anti-AIGC Detection Skills</b></summary>

- **🔥 [StatsPAI](https://github.com/brycewang-stanford/StatsPAI)**: Our own **agent-native causal inference & econometrics Python package**. 390+ functions, one `import`, self-describing API (`list_functions()` / `describe_function()` / `function_schema()`). Covers OLS, IV, DID (Callaway-Sant'Anna / Sun-Abraham / Bacon / HonestDID / continuous DID), RDD, PSM, SCM, DML, Causal Forest, Meta-Learners, TMLE, neural causal models (TARNet/CFRNet/DragonNet), and more. Published in JOSS, MIT license. [→ PyPI](https://pypi.org/project/StatsPAI/) | [→ GitHub](https://github.com/brycewang-stanford/StatsPAI)
- **📝 Anti-AIGC Detection Skills** (4 new, [→ dedicated section](#-anti-aigc-detection--de-ai-academic-writing-highlighted)):
  - [humanizer_academic](https://github.com/matsuikentaro1/humanizer_academic) — Academic paper specialist, 23 AI writing pattern detectors (`skills/44`)
  - [skill-deslop](https://github.com/stephenturner/skill-deslop) — Scientific writing de-AI, respects discipline conventions (`skills/45`)
  - [stop-slop](https://github.com/hardikpandya/stop-slop) — 3-layer detection + 5-dimension scoring (`skills/46`)
  - [avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing) — Structured audit + rewrite + second-pass audit (`skills/47`)
- **🛡️ [revision-guard](https://github.com/ShiyanW/ai-revision-guard)**: Prevents AI over-refinement, limits revision rounds + 7-point homogenization checklist (community PR contribution)

</details>

<details>
<summary><b>2026-04-11: Expanded from 43 collections to 119 repos, covering 23,000+ Skills</b></summary>

- Added 76 GitHub repositories across 8 social science disciplines (economics, political science, sociology, psychology, education, public health, management, finance)
- Added skill suites for finance, law, marketing, product management, education, public health
- Added 13 academic data MCP servers (OpenAlex, Semantic Scholar, FRED, World Bank, etc.)
- Added 11 multi-agent collaboration systems (Agent Laboratory, AI-Scientist-v2, etc.)
- Added bilingual Chinese/English README

</details>

---

## Table of Contents

- [🆕 Changelog](#-changelog)
- [What Can This List Do for You?](#what-can-this-list-do-for-you)
- [Quick Lookup by Research Stage](#quick-lookup-by-research-stage)
- **Skills by Category**
  - [01 - Topic Selection & Research Design](docs/01-选题与研究设计.md)
  - [02 - Literature Search & Review](docs/02-文献检索与综述.md)
  - [03 - Paper Reading & Analysis](docs/03-论文阅读与拆解.md)
  - [04 - Data Collection & Cleaning](docs/04-数据获取与清洗.md)
  - [05 - Statistical Analysis & Causal Inference](docs/05-统计分析与因果推断.md)
  - [06 - Paper Writing](docs/06-论文写作.md)
  - [07 - Paper Revision & Polishing](docs/07-论文修改与润色.md)
  - [08 - Citation Management & Typesetting](docs/08-引用管理与排版.md)
  - [09 - Replication & Reproducible Research](docs/09-论文复现与可复现研究.md)
  - [10 - Peer Review Response & Defense](docs/10-审稿回复与学术答辩.md)
- [Comprehensive Skill Suites](#comprehensive-skill-suites)
  - 🚨 [Anti-AIGC Detection & De-AI Academic Writing (Highlighted)](#-anti-aigc-detection--de-ai-academic-writing-highlighted)
- [Multi-Agent Collaboration Systems](#multi-agent-collaboration-systems)
- [Skill Aggregation Platforms & Discovery Tools](#skill-aggregation-platforms--discovery-tools)
- [Learning Resources](#learning-resources)
- [Contributing](#contributing)

---

## What Can This List Do for You?

If you do empirical research, you've probably experienced these scenarios:

- You ask AI to run a DID, and it gives you the baseline regression and stops. You say "parallel trends?" — it adds one. "Placebo test?" — another one. "Event study plot?" — yet another. **Every time, it's like squeezing toothpaste.**
- You finally finish a draft, but citations are a mess, with a few hallucinated references mixed in.
- You want to replicate an identification strategy from a top journal, but the gap between understanding it and implementing it feels like a mountain.

**The problem isn't that AI can't do it — it doesn't know what a complete workflow should include.**

A Skill solves this: it's a **methodological playbook for AI**. With a Skill, AI knows "running DID means first testing parallel trends, then baseline regression, then 4 robustness checks, then heterogeneity analysis, then mechanism analysis, with specific output formats at each step." You just say "run a DID analysis" and it follows the complete workflow.

This list helps you find the best Skills for every stage of the empirical research workflow.

---

## Quick Lookup by Research Stage

> Not sure which Skill to use? Start from your current research stage:

```
Topic Ideation → Lit Search → Deep Reading → Research Design → Data Collection
      │              │             │              │                │
      ▼              ▼             ▼              ▼                ▼
     01             02            03             01               04

Data Cleaning → Statistical Analysis → First Draft → Revision → Typesetting
      │              │                    │            │            │
      ▼              ▼                    ▼            ▼            ▼
     04             05                   06           07           08

Replication → Submission → Peer Review Response → Defense
      │           │              │                   │
      ▼           ▼              ▼                   ▼
     09          10             10                  10
```

### One-Stop Solutions

If you don't want to pick Skills one by one, these solutions cover the full workflow:

| Solution | Coverage | Highlights | Link |
|----------|----------|------------|------|
| **CoPaper.AI** | Data Analysis → Paper Writing | 20 built-in methodology Skills, multi-agent architecture, complete publication-quality empirical paper in 20 minutes | [copaper.ai](https://copaper.ai) |
| **StatsPAI Skill** 🔥🔥 | **End-to-end automated empirical analysis** | **900+ functions, one `import statspai as sp`**. A single agent instruction runs the full 6-step loop: EDA → pre-flight → research-question DSL → DAG discovery → estimation → robustness. Agent-native self-describing API, covers OLS/IV/DID (incl. Callaway-Sant'Anna, Sun-Abraham, HonestDID, continuous DID)/RDD/PSM/SCM/DML/Causal Forest/neural causal/text causal, publication-ready output (Word/Excel/LaTeX) | [Local Skill](skills/00-StatsPAI_skill/) · [GitHub](https://github.com/brycewang-stanford/StatsPAI) |
| **Full Empirical Analysis Skill** 📘 | **Traditional Python stack, explicit 8-step loop** (StatsPAI's philosophical counterpart) | No DSL wrapper — the agent drives `pandas` / `statsmodels` / `linearmodels` / `pyfixest` / `rdrobust` / `econml` / `causalml` / `matplotlib` directly. Covers **data cleaning → variable construction → descriptive statistics → diagnostic tests → modeling → robustness → mechanism/heterogeneity/mediation/moderation → publication-ready tables & figures**, one deep reference per step. Ideal for teaching, referee-level audit, and strict replication work that needs line-by-line control | [Local Skill](skills/00.1-Full-empirical-analysis-skill/) |
| **Full Empirical Analysis Skill — Stata** 📊 | **Traditional Stata `.do` 8-step loop** (the Stata sibling of 00.1) | `reghdfe` + `ivreg2` + `csdid` + `did_imputation` + `eventstudyinteract` + `sdid` + `rdrobust` + `synth` + `psmatch2` + `teffects` + `ebalance` + `boottest` + `ritest` + `rwolf` + `bacondecomp` + `honestdid` + `coefplot` + `esttab` + `outreg2` + `asdoc` + `binscatter`. Same 8 steps, from `use` / `import` all the way to `.tex` / `.rtf` tables + `.pdf` figures. The first choice for referee-level Stata replication packs | [Local Skill](skills/00.2-Full-empirical-analysis-skill_Stata/) |
| **Full Empirical Analysis Skill — R** 📗 | **tidyverse + fixest 8-step loop + Quarto rendering** (R sibling of 00.1 / 00.2) | `dplyr` + `haven` + `fixest` + `did` + `synthdid` + `bacondecomp` + `HonestDiD` + `rdrobust` + `tidysynth` + `gsynth` + `MatchIt` + `WeightIt` + `cobalt` + `ebal` + `grf` + `DoubleML` + `mediation` + `lavaan` + `marginaleffects` + `modelsummary` + `kableExtra` + `gt` + `flextable` + `ggplot2` + `iplot` + `binsreg` + `cowplot`. All 8 steps fit in a single `.qmd`; `quarto render` produces a unified PDF/HTML/Word reproducibility report. | [Local Skill](skills/00.3-Full-empirical-analysis-skill_R/) |
| **Claude Scholar** | Ideation → Submission | 25+ Skills covering the full research lifecycle, Zotero MCP integration | [GitHub](https://github.com/Galaxy-Dawn/claude-scholar) |
| **K-Dense Scientific Skills** | Cross-disciplinary Science | 140+ Skills, 28+ scientific databases, 55+ Python packages | [GitHub](https://github.com/K-Dense-AI/claude-scientific-skills) |
| **AI-Research-SKILLs** | AI/ML Research | 22 categories, 87 skills, full research cycle | [GitHub](https://github.com/Orchestra-Research/AI-Research-SKILLs) |
| **OpenClaw Medical Skills** | Biomedical/Public Health | **869 Skills**, epidemiology, clinical research, drug safety, biostatistics | [GitHub](https://github.com/FreedomIntelligence/OpenClaw-Medical-Skills) |
| **Agent Laboratory** | Fully Autonomous Research | Lit review → Experiments → Report, 84% reduction in research costs | [GitHub](https://github.com/SamuelSchmidgall/AgentLaboratory) |

---

## Comprehensive Skill Suites

These repositories contain multiple Skills and typically cover several research stages:

### Academic Research

| Suite | Stars | # Skills | Key Features | Social Science Fit |
|-------|-------|----------|-------------|-------------------|
| [K-Dense-AI/claude-scientific-skills](https://github.com/K-Dense-AI/claude-scientific-skills) | 8,799 | 140+ | 28+ scientific databases (OpenAlex, PubMed), scientific-writing + literature-review + statistical-analysis | ⭐⭐⭐⭐ |
| [Orchestra-Research/AI-Research-SKILLs](https://github.com/Orchestra-Research/AI-Research-SKILLs) | 3,637 | 87 | 22 categories, ML paper writing, LaTeX templates, citation verification | ⭐⭐⭐ |
| [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) | ~1,790 | Multiple | Full paper pipeline (research → write → review → revise → finalize), style calibration, hallucination detection | ⭐⭐⭐⭐ |
| [Galaxy-Dawn/claude-scholar](https://github.com/Galaxy-Dawn/claude-scholar) | - | 25+ | Full research lifecycle: ideation → review → experiments → writing → peer review response, Zotero MCP | ⭐⭐⭐⭐⭐ |
| [luwill/research-skills](https://github.com/luwill/research-skills) | 209 | 3 | Research proposal generation, medical review writing, paper-to-slides, bilingual | ⭐⭐⭐⭐⭐ |
| [lishix520/academic-paper-skills](https://github.com/lishix520/academic-paper-skills) | 22 | 2 | Strategist (7-dimension reviewer simulation) + Composer (systematic writing) | ⭐⭐⭐⭐ |
| [Data-Wise/claude-plugins](https://github.com/Data-Wise/claude-plugins) | - | 17 | Statistical research: arXiv search, DOI lookup, BibTeX management, methodology writing, referee response | ⭐⭐⭐⭐⭐ |

### Economics / Causal Inference

| Suite | Key Features | Use Case |
|-------|-------------|----------|
| **[CoPaper.AI](https://copaper.ai)** | **20 methodology Skills** (OLS, DID, staggered DID, IV, RDD, PSM, SCM, DML, causal forest, etc.), multi-agent architecture (Supervisor + 4 sub-agents), smart routing, automatic output | Full empirical economics workflow |
| **[StatsPAI Skill](skills/00-StatsPAI_skill/)** 🔥🔥 | **End-to-end automated empirical analysis.** Agent-native econometrics Python package: **900+ functions**, one `import statspai as sp` runs the full loop: EDA → research-question DSL → LLM-assisted DAG discovery → estimation → robustness. Self-describing API (`list_functions()` / `describe_function()` / `function_schema()`), unified `CausalResult` objects. Covers OLS, IV, panel data, DID (Callaway-Sant'Anna / Sun-Abraham / Bacon / HonestDID / continuous DID), RDD (Sharp/Fuzzy/multi-cutoff/Kink), PSM, SCM, SDID, DML, Causal Forest, Meta-Learners, TMLE, AIPW, neural causal models (TARNet/CFRNet/DragonNet), **text causal (`sp.causal_text`)**, Heckman, structural estimation (BLP). **Submitted to JOSS, MIT license** | Whole-pipeline automation: one agent call goes from cleaned data to robust estimates |
| **[Full Empirical Analysis Skill](skills/00.1-Full-empirical-analysis-skill/)** 📘 | **Traditional Python econometrics stack, explicit 8-step closed loop** (philosophical counterpart to StatsPAI: DSL one-shot vs. explicit line-by-line). No wrapper — drives `pandas` + `numpy` + `scipy` + `statsmodels` + `linearmodels` + `pyfixest` + `rdrobust` + `econml` + `causalml` + `matplotlib` + `seaborn` directly. Fine-grained 8 steps: (1) data cleaning (MCAR/MAR/MNAR, IQR/z/Mahalanobis, `validate=` safe merges, panel-structure checks) → (2) variable construction (log/IHS/Box–Cox, 1/99 winsorization, z/MinMax/Robust, interactions/lags/diffs, CPI deflation, staggered-DID timing) → (3) descriptives (stratified Table 1 with SMD+t-tests, starred correlation heatmap, 4-panel distributions, DID motivation plot, panel-coverage heatmap) → (4) diagnostics (12 classes: normality / heteroskedasticity / autocorrelation / collinearity / stationarity / cointegration / endogeneity / weak-IV / overid / Hausman / RESET / Cook's D) → (5) modeling (OLS / panel FE-RE-FD / GLM / IV-2SLS-LIML-GMM / 5 DID variants / 4 RD variants / SC / PSM-IPW-EB / DML / CF / Heckman / QR — 12 classes) → (6) robustness (M1–M6 progressive specs, cluster sensitivity, wild bootstrap, placebo, spec curve, Oster δ\*, LOO, Rosenbaum) → (7) further analysis (heterogeneity × 4 / outcome-ladder mechanism / Baron–Kenny + Imai mediation / moderated mediation / dose-response / spillover) → (8) publication tables & figures (`stargazer` / `etable` / coefplot / event-study / binscatter / forest / RD plot / CATE heatmap / love plot, plus LaTeX/Word/Excel export). **610-line SKILL.md spine + 8 deep reference manuals (3000+ lines), progressively loaded** | Teaching, referee-level audit, graduate replication training, rigorous empirical projects requiring line-by-line control and full diagnostic coverage |
| **[Full Empirical Analysis Skill — Stata](skills/00.2-Full-empirical-analysis-skill_Stata/)** 📊 | **Traditional Stata `.do` 8-step closed loop** (Stata sibling of 00.1, same structure, same cadence). One `ssc install` block installs 30+ packages. End-to-end community-standard chain: `reghdfe` / `ivreg2` / `ivreghdfe` / `csdid` / `did_imputation` / `eventstudyinteract` / `sdid` / `did_multiplegt_dyn` / `bacondecomp` / `honestdid` / `rdrobust` / `rddensity` / `synth` / `synth_runner` / `psmatch2` / `teffects` / `ebalance` / `ppmlhdfe` / `boottest` / `ritest` / `rwolf` / `psacalc` / `coefplot` / `esttab` / `outreg2` / `asdoc` / `binscatter`. 8 steps: (1) `use`+`import`+`destring`+`misstable`+`merge assert`+`xtset` → (2) `winsor2`+`xtile`+`L./F./D./S.`+CPI+staggered timing → (3) `tabstat`+`balancetable`+`asdoc`+`pwcorr sig star`+`heatplot` → (4) 12 estat-style diagnostics → (5) 12 estimator classes (`reghdfe` + 5 DID + 4 RD + `synth` + `teffects` + `ebalance` + `heckman` + `qreg` + `ppmlhdfe` + `sem/gsem`) → (6) `eststo`+`esttab` M1–M6 + `boottest` + `ritest` + `rwolf` + `bacondecomp` + `honestdid` + `psacalc delta` → (7) factor-var + `margins` + `marginsplot` + `suest` + DDD + `medsem` + `khb` + SEM + Stata-Python bridge to `econml` for CATE → (8) `esttab`+`outreg2`+`asdoc` to `.tex/.rtf/.docx/.xlsx`; `coefplot`+`marginsplot`+`binscatter`+`rdplot`+`graph combine` to `.pdf`. **801-line SKILL.md + 8 deep references (3500+ lines) + complete `.do` skeleton** | Referee / co-author insists on Stata replication; graduate Stata courses; AER/QJE/JPE/ReStud-style standard `.do` pipelines |
| **[Full Empirical Analysis Skill — R](skills/00.3-Full-empirical-analysis-skill_R/)** 📗 | **Modern tidyverse + fixest + Quarto stack, explicit 8-step loop** (R sibling of 00.1 / 00.2; the fourth and final piece of the family). One `install.packages(...)` block installs 50+ packages. End-to-end modern R standards: `dplyr` / `tidyr` / `haven` / `janitor` / `naniar` / `mice` / `validate` / `assertr` for data; `fixest::feols/feglm/fepois` for HD FE + multi-way clustering + IV in one line; `did::att_gt` / `fixest::sunab` / `didimputation::did_imputation` / `synthdid` / `DIDmultiplegtDYN` / `bacondecomp` / `HonestDiD` for modern DID; `rdrobust` / `rddensity` / `rdmulti` / `rdlocrand` for RD; `Synth` / `gsynth` / `tidysynth` / `synthdid` for SC; `MatchIt` / `WeightIt` / `cobalt` / `ebal` for matching; `grf::causal_forest` / `DoubleML` for ML causal; `mediation::mediate` + `medsens` / `lavaan::sem` for mediation; `marginaleffects` for post-estimation; `modelsummary` / `kableExtra` / `gt` / `flextable` for tables; `ggplot2` + `iplot` + `binsreg` + `cowplot` + `patchwork` for figures. 8-step R pipeline + **Quarto template** (one `.qmd` holding narrative + code + tables + figures, `quarto render` for PDF/HTML/Word in one go). **893-line SKILL.md + 8 deep references (3700+ lines)**, progressively loaded | Quarto reproducibility reports, academic blogs (distill / quarto blog), graduate R courses, projects needing `marginaleffects` + Imai sensitivity mediation + `grf` CATE post-estimation |
| [claesbackman/AI-research-feedback](https://github.com/claesbackman/AI-research-feedback) | 2-agent economics paper pre-review: causal overclaiming detection, identification strategy assessment; supports AER/QJE/JPE/Econometrica/REStud; 6-agent grant review | Pre-submission self-review, grant applications |
| [fuhaoda/stats-paper-writing-agent-skills](https://github.com/fuhaoda/stats-paper-writing-agent-skills) | LaTeX statistical paper writing, front-end draft generation | Statistics & econometrics papers |
| [dylantmoore/stata-skill](https://github.com/dylantmoore/stata-skill) | Full Stata coverage: syntax, data management, econometrics, causal inference, graphics, Mata, 20+ community packages | Stata users |
| [SepineTam/stata-mcp](https://github.com/SepineTam/stata-mcp) | LLM operates Stata regression directly via MCP, "evolve from regression monkey to causal thinker" | Stata econometrics |

### 🚨 Anti-AIGC Detection & De-AI Academic Writing (Highlighted)

> **This is one of the most critical pain points in academic writing in 2026**. Papers failing AIGC detection can be rejected outright, and detectors like Turnitin, GPTZero, and China's CNKI are getting stricter. The 4 skills below are the **most authoritative and complete** solutions on GitHub — all MIT open-source, and all locally archived in this repo (`skills/44-47`).

| Suite | Key Features | Use Case | Local Path |
|-------|-------------|----------|-----------|
| **CoPaper.AI / chinese-de-aigc** 🇨🇳🔥 | **Original Chinese academic de-AIGC skill** by CoPaper.AI team. Targets China's CNKI AMLC / Wanfang / VIP / Turnitin Chinese detectors. 17-pattern library of Chinese-specific AI tells (4-char clichés, hollow connectives, explicit transitions, absolutist claims, sentence-length uniformity), 5-step closed loop workflow (locate→diagnose→rewrite→self-score→review), per-section strategy, 5-dim scoring rubric. **Currently the only GitHub skill dedicated to Chinese academic de-AIGC** | Chinese journal submissions, theses, grant proposals | [`skills/48`](skills/48-copaper-ai-chinese-de-aigc/) |
| **[matsuikentaro1/humanizer_academic](https://github.com/matsuikentaro1/humanizer_academic)** 🔥 | **Academic-specific**. 23 AI writing patterns (6 content + 6 language + 3 style + 3 filler + 5 word choice), examples from EMPA-REG OUTCOME cardiovascular trials, preserves legitimate academic transitions, based on Wikipedia "Signs of AI writing" | Medical, life sciences, natural science papers | [`skills/44`](skills/44-matsuikentaro1-humanizer_academic/) |
| **[stephenturner/skill-deslop](https://github.com/stephenturner/skill-deslop)** | **Scientific writing de-AI**. Smartly distinguishes legitimate discipline conventions (passive voice in methods) from AI tells; 5-dimension scoring (directness/rhythm/trust/authenticity/density); 4 reference files (examples/phrases/structures/tropes) | Scientific papers, technical blogs | [`skills/45`](skills/45-stephenturner-skill-deslop/) |
| **[hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop)** | **3-layer detection + 5-dim scoring**. Banned phrases (throat-clearing openers, emphasis crutches, corporate jargon), structural clichés (binary contrasts, dramatic fragmentation, false agency), sentence-level rules (no em dash, no Wh- starters). Below 35/50 → revise | General prose, blogs, reports | [`skills/46`](skills/46-hardikpandya-stop-slop/) |
| **[conorbronsdon/avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing)** | **Structured audit + rewrite + second-pass audit**. Four-section output: identified issues (with quotes) → rewrite → change summary → second audit. Compatible with Claude Code, OpenClaw, Hermes, and other agents | Workflows needing auditable, traceable revision | [`skills/47`](skills/47-conorbronsdon-avoid-ai-writing/) |
| [ShiyanW/ai-revision-guard](https://github.com/ShiyanW/ai-revision-guard) | **Prevents over-refinement** (different angle). Limits revision rounds (≤2 per section), 7-point homogenization checklist, cross-model verification. Protects author's voice from AI erosion | Multi-round polishing scenarios | (community PR) |

> **Recommended combos**:
> - 🇨🇳 **Chinese academic papers** (CNKI/Wanfang/VIP) → **chinese-de-aigc** (original) + **revision-guard**
> - 🇬🇧 English academic papers → **humanizer_academic** + **revision-guard** (prevent over-refinement)
> - Bilingual papers → **chinese-de-aigc** + **humanizer_academic** combined
> - Need auditable workflow → **avoid-ai-writing** (structured reports)
> - General writing → **stop-slop** (5-dim scoring for quantified improvement)

### Finance & Investment Research

| Suite | Key Features | Use Case |
|-------|-------------|----------|
| [anthropics/financial-services-plugins](https://github.com/anthropics/financial-services-plugins) | Anthropic official: investment banking, equity research, private equity, wealth management | Financial services |
| [OctagonAI/skills](https://github.com/OctagonAI/skills) | Octagon agentic financial research Claude Skills | Institutional financial research |
| [tradermonty/claude-trading-skills](https://github.com/tradermonty/claude-trading-skills) | Stock investing & trading: market analysis, technical charts, economic calendar, strategy development | Quantitative trading research |
| [himself65/finance-skills](https://github.com/himself65/finance-skills) | Agent Skills open standard, earnings analysis, consensus estimates, analyst sentiment | Financial analysis |
| [quant-sentiment-ai/claude-equity-research](https://github.com/quant-sentiment-ai/claude-equity-research) | Institutional equity research: fundamental analysis, technical indicators, risk assessment | Equity research |

### Education & Public Health

| Suite | Key Features | Use Case |
|-------|-------------|----------|
| [GarethManning/claude-education-skills](https://github.com/GarethManning/claude-education-skills) | Evidence-based education Claude Skills, designed for teachers and agent orchestration | Education research |
| [FreedomIntelligence/OpenClaw-Medical-Skills](https://github.com/FreedomIntelligence/OpenClaw-Medical-Skills) | **869** medical AI Skills: epidemiology, public health surveillance, clinical research, drug safety, biostatistics | Public health, medical research |

### Governance, Compliance & Law

| Suite | Key Features | Use Case |
|-------|-------------|----------|
| [Sushegaad/Claude-Skills-Governance-Risk-and-Compliance](https://github.com/Sushegaad/Claude-Skills-Governance-Risk-and-Compliance) | GRC Skills: ISO 27001, SOC 2, GDPR, HIPAA compliance guidance (94% vs 72% baseline) | Compliance research, policy analysis |
| [zubair-trabzada/ai-legal-claude](https://github.com/zubair-trabzada/ai-legal-claude) | Legal assistant: contract review, risk analysis, NDA generation, compliance audit, 14 Skills + 5 agents | Law & economics, regulatory research |
| [evolsb/claude-legal-skill](https://github.com/evolsb/claude-legal-skill) | AI contract review: CUAD risk detection, market benchmarks, attorney-grade red-lining | Law & economics research |

### Marketing & Consumer Behavior

| Suite | Key Features | Use Case |
|-------|-------------|----------|
| [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) | CRO, copywriting, SEO, analytics, and growth engineering | Marketing research |
| [zubair-trabzada/ai-marketing-claude](https://github.com/zubair-trabzada/ai-marketing-claude) | 15 Skills + parallel sub-agents: website audit, copy, email sequences, competitive intelligence | Consumer behavior analysis |
| [ericosiu/ai-marketing-skills](https://github.com/ericosiu/ai-marketing-skills) | Growth experiments, sales pipeline, content operations, SEO, financial automation | Marketing strategy research |

### Product Management & Organizational Behavior

| Suite | Key Features | Use Case |
|-------|-------------|----------|
| [phuryn/pm-skills](https://github.com/phuryn/pm-skills) | 100+ agent Skills: discovery → strategy → execution → launch → growth, 65 PM Skills + 36 chained workflows | Product management, organizational research |
| [mastepanoski/claude-skills](https://github.com/mastepanoski/claude-skills) | UX/UI evaluation (Nielsen heuristics, WCAG), AI governance (NIST AI RMF, ISO 42001) | UX research |

### General Agent Capabilities

| Suite | Stars | Key Features |
|-------|-------|-------------|
| [lyndonkl/claude](https://github.com/lyndonkl/claude) | - | 85 skills + 6 orchestration agents, incl. causal inference, Bayesian reasoning, experimental design, multi-criteria analysis |
| [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) | ~5,200 | 220+ skills + 298 CLI scripts, incl. financial analysis and data processing |
| [rohitg00/awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) | - | 135 agents incl. data scientist agent (EDA, DID, RDD), 35 skills, 42 commands |
| [jeremylongshore/claude-code-plugins-plus-skills](https://github.com/jeremylongshore/claude-code-plugins-plus-skills) | - | 340 plugins + **1,367 agent skills**, CCPI package manager |
| [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | - | Skills, intuition, memory, security, research-first development framework |
| [posit-dev/skills](https://github.com/posit-dev/skills) | - | Posit official: modern-r-tidyverse, predictive-modeling, quarto-authoring, shiny-bslib |

---

## Multi-Agent Collaboration Systems

A single Skill solves a point problem; multi-agent systems solve **end-to-end workflows**. These systems let multiple AI roles divide work, cross-review, and produce output quality far beyond what a single agent can achieve:

### Paper Revision & Writing

| System | Architecture | Key Features |
|--------|-------------|-------------|
| **copy-edit-master** | 3 sub-agents: structure-editor + line-editor + quality-reviewer | Auto document type detection, Strunk & White / McCloskey rules encoded, git checkpoints per phase, review loop (max 2 iterations) |
| **introduction-writer** | 4 sub-agents: strategist → drafter → reviewer → reviser | Keith Head formula for drafting introductions, reviewer independent from drafter for quality loop |
| **CoPaper.AI PaperAgent** | Supervisor + 4 sub-agents (preparation / modeling / visualization / writing) | Skills routed by target_agent, each sub-agent sees only relevant methodology guidance, reduced context noise |

> **Why multi-agent beats single agent?** When the same agent writes and reviews, it tends to approve its own work. Role separation means the reviewer is independent from the drafter — forming a genuine quality loop. Same logic as academic peer review.

### Data Analysis & Research

| System | Source | Key Features |
|--------|--------|-------------|
| [ruc-datalab/DeepAnalyze](https://github.com/ruc-datalab/DeepAnalyze) | Renmin Univ. | Autonomous data analysis agent, raw data → professional report, CSV/Excel/JSON/DB support, open-source DeepAnalyze-8B |
| [business-science/ai-data-science-team](https://github.com/business-science/ai-data-science-team) | Business Science | Multi-agent data science team: EDA Agent + SQL Agent + MLflow Agent, LangChain integration |
| [HungHsunHan/claude-code-data-science-team](https://github.com/HungHsunHan/claude-code-data-science-team) | Community | Claude Code multi-agent data science team, auto cleaning → modeling → executable Notebook |
| [HKUDS/AI-Researcher](https://github.com/HKUDS/AI-Researcher) | HKU (NeurIPS 2025 Spotlight) | Fully autonomous research pipeline: lit review → hypothesis → algorithm → paper |
| [wanshuiyin/Auto-claude-code-research-in-sleep (ARIS)](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep) | Community | Overnight autonomous research, cross-model review loops (Claude + external LLM as critic) |
| [SamuelSchmidgall/AgentLaboratory](https://github.com/SamuelSchmidgall/AgentLaboratory) | Academic (ICLR) | End-to-end autonomous research: lit review → experiments → report, arXiv/HuggingFace/LaTeX integration, 84% cost reduction |
| [SakanaAI/AI-Scientist-v2](https://github.com/SakanaAI/AI-Scientist-v2) | Sakana AI | Fully automated scientific discovery: hypothesis → experiments → paper, first AI-generated paper accepted via peer review |
| [assafelovic/gpt-researcher](https://github.com/assafelovic/gpt-researcher) | Community | Autonomous deep research agent, supports any LLM provider |
| [LitLLM/LitLLM](https://github.com/LitLLM/LitLLM) | Academic | AI literature review assistant: keyword extraction + multi-strategy retrieval + re-ranking, RAG-based |
| [pedrohcgs/claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow) | Emory Univ. | Academic LaTeX/Beamer + R template, multi-agent review + quality gates, adopted by 15+ research groups |
| [hugosantanna/clo-author](https://github.com/hugosantanna/clo-author) | Community | Extends Sant'Anna's workflow from lecture production to full social science empirical research publication |

### Academic Data MCP Servers

| System | Key Features |
|--------|-------------|
| [xingyulu23/Academix](https://github.com/xingyulu23/Academix) | Unified academic research interface aggregating OpenAlex + DBLP + Semantic Scholar + arXiv + CrossRef |
| [Eclipse-Cj/paper-distill-mcp](https://github.com/Eclipse-Cj/paper-distill-mcp) | 11-source parallel search, 4-dimension weighted ranking (relevance/recency/impact/novelty) |
| [oksure/openalex-research-mcp](https://github.com/oksure/openalex-research-mcp) | OpenAlex API: search 240M+ academic works, citation analysis, trend tracking, collaboration networks |
| [zongmin-yu/semantic-scholar-fastmcp-mcp-server](https://github.com/zongmin-yu/semantic-scholar-fastmcp-mcp-server) | Full Semantic Scholar API access: papers, authors, citation networks |
| [openags/paper-search-mcp](https://github.com/openags/paper-search-mcp) | Search 20+ sources: arXiv, PubMed, bioRxiv, Google Scholar, SSRN, Unpaywall, etc. |
| [aringadre76/mcp-for-research](https://github.com/aringadre76/mcp-for-research) | Integrates PubMed + Google Scholar + ArXiv + JSTOR, published on NPM |
| [blazickjp/arxiv-mcp-server](https://github.com/blazickjp/arxiv-mcp-server) | arXiv paper search and analysis MCP |
| [lzinga/us-gov-open-data-mcp](https://github.com/lzinga/us-gov-open-data-mcp) | 40+ US government APIs (FRED/Census/CDC/FDA/FEC, etc.), 250+ tools |
| [stefanoamorelli/fred-mcp-server](https://github.com/stefanoamorelli/fred-mcp-server) | Direct access to FRED's 800K+ economic time series |
| [llnOrmll/world-bank-data-mcp](https://github.com/llnormll/world-bank-data-mcp) | World Bank Data360, 1000+ socioeconomic indicators, 200+ countries |
| [54yyyu/zotero-mcp](https://github.com/54yyyu/zotero-mcp) | Connect Zotero library with AI assistants: paper review, summaries, citation analysis, PDF annotation |
| [datagouv/datagouv-mcp](https://github.com/datagouv/datagouv-mcp) | French national open data platform MCP |

---

## Skill Aggregation Platforms & Discovery Tools

Don't know where to find Skills? These platforms are your starting point:

| Platform | Scale | Features |
|----------|-------|----------|
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 1,000+ skills | 13,700 stars, curated by official team and community |
| [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 1,340+ skills | 28,000 stars, one-click install `npx antigravity-awesome-skills` |
| [VoltAgent/awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills) | **5,400+ skills** | Curated from OpenClaw registry (ClawHub 13,729 Skills) |
| [jeremylongshore/claude-code-plugins-plus-skills](https://github.com/jeremylongshore/claude-code-plugins-plus-skills) | 1,367 skills | 340 plugins + CCPI package manager |
| [skills.sh](https://skills.sh/) | Online market | Searchable Skill marketplace |
| [ClawHub (clawhub.com)](https://clawhub.com) | **13,729 skills** | Open-source AI skill marketplace, one-line install |
| [Agent Skills Standard](https://agentskills.io/) | Spec docs | Universal Agent Skills specification |
| [Anthropic Official Skills](https://github.com/anthropics/skills) | Official | PDF/DOCX/XLSX/PPTX document processing |
| [Anthropic Official Plugin Market](https://github.com/anthropics/claude-plugins-official) | Official | Anthropic-managed high-quality Claude Code plugin catalog |
| [Anthropic Knowledge Work Plugins](https://github.com/anthropics/knowledge-work-plugins) | Official | 11 plugins incl. Data Plugin (SQL queries, data exploration) |
| [Anthropic Financial Services Plugins](https://github.com/anthropics/financial-services-plugins) | Official | Financial services plugins: IB, equity research, PE, wealth mgmt |

---

## Learning Resources

### Official Documentation

- [Claude Code Skills Complete Guide](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf) — Anthropic's official 32-page guide
- [Agent Skills Standard Specification](https://agentskills.io/)
- [Claude Code Official Docs](https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills)

### Academic Talks & Courses

- [AI Agents for Economics Research](https://cepr.org/) — Aniket Panjwani, CEPR/VoxDev, 2026.03
- [Claude Code & Cowork for Academic Research — A Practical Guide](https://cornwl.github.io/files/claude-academic-guide.html) — Practical guide for economists and social scientists, 2026.02
- [Building Claude Code Workflow for Economics Scholars](https://zhiyuanryanchen.github.io/claude-code-workflow.html) — Building Claude Code workflows for economics researchers

### Causal Inference Textbooks

- [Causal Inference for the Brave and True](https://github.com/xieliaing/CausalInferenceIntro) — Chinese translation, Python code
- [Statistical Tools for Causal Inference](https://chabefer.github.io/STCI/) — Open-source textbook
- [Causal Inference and Machine Learning Book](https://www.causalmlbook.com/)

### Survey Papers & Awesome Lists

- [A Survey of Data Agents](https://github.com/HKUSTDial/awesome-data-agents) — Data agent survey (HKUST)
- [From AI for Science to Agentic Science](https://github.com/AgenticScience/Awesome-Agent-Scientists) — arXiv:2508.14111
- [From Automation to Autonomy](https://github.com/HKUST-KnowComp/Awesome-LLM-Scientific-Discovery) — LLM scientific discovery survey (EMNLP 2025)
- [Awesome Agents for Science](https://github.com/OSU-NLP-Group/awesome-agents4science) — Papers on LLMs and agents in scientific R&D
- [Awesome AI for Science](https://github.com/ai-boost/awesome-ai-for-science) — AI tools, papers, datasets for accelerating scientific discovery
- [Awesome AI for Economists](https://github.com/hanlulong/awesome-ai-for-economists) — AI tools, libraries, and resources for economics (OpenEcon team)
- [Awesome Econ AI Stuff](https://github.com/meleantonio/awesome-econ-ai-stuff) — AI Skills collection for economists, follows SKILL.md standard
- [AI for Grant Writing](https://github.com/eseckel/ai-for-grant-writing) — Curated resources for LLM-assisted grant writing
- [Awesome AI Scientist Papers](https://github.com/openags/Awesome-AI-Scientist-Papers) — AI scientist / robot scientist papers
- [FreedomIntelligence/OpenClaw-Medical-Skills](https://github.com/FreedomIntelligence/OpenClaw-Medical-Skills) — **869** medical AI Skills, covering epidemiology, public health, biostatistics

### Community & References

- [Awesome Claude Skills](https://github.com/travisvn/awesome-claude-skills) — Community curated
- [Awesome Claude Skills (ComposioHQ)](https://github.com/ComposioHQ/awesome-claude-skills) — Curated Claude Skills list
- [Awesome Claude Skills (BehiSecc)](https://github.com/BehiSecc/awesome-claude-skills) — Curated Claude Skills list
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code) — Skills, Hooks, slash commands, agent orchestrators
- [Reddit r/ClaudeCode](https://www.reddit.com/r/ClaudeCode/)
- [Anthropic Claude Code Skills Cookbook](https://github.com/anthropics/claude-cookbooks/blob/main/skills/notebooks/02_skills_financial_applications.ipynb) — Financial applications Skills tutorial

---

## Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) to learn how to submit new Skill recommendations.

We especially welcome:
- Skills for social science disciplines: economics, political science, sociology, psychology, education, public administration, public health
- New Skill implementations for causal inference methods
- Skills for business disciplines: finance, management, marketing, law & economics
- General academic Skills: literature review, grant writing, research proposals
- MCP servers (academic databases, government data APIs)
- Chinese-friendly Skills
- Multi-agent collaboration system case studies

---

## Star History

If this list helps you, please give it a Star so more researchers can find it.

---

<div align="center">

**AI is an amplifier, not a replacement. It handles the heavy lifting; you keep the core judgment.**

<br/>

<a href="https://copaper.ai">
  <img src="images/copaper-logo.png" alt="CoPaper.AI" width="240" />
</a>

<br/>

<table>
  <tr>
    <td align="center">
      <a href="https://copaper.ai"><img src="images/copaper-qrcode.png" alt="Visit copaper.ai" width="180" /></a><br/>
      <strong>Visit <a href="https://copaper.ai">copaper.ai</a></strong>
    </td>
    <td align="center">
      <img src="images/copaper-wechat.jpg" alt="CoPaper.AI WeChat" width="180" /><br/>
      <strong>WeChat: CoPaper.AI</strong>
    </td>
  </tr>
</table>

20 built-in methodology Skills, complete an empirical paper in 20 minutes

<br/>

Maintained by [CoPaper.AI](https://copaper.ai) | AI Assistant for Empirical Research

</div>
