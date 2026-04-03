<!--
  README v2.0.0 — Revised draft
-->

## Summary: What is DAAF?

<img width="1258" height="433" alt="daaf_20_thumbnail3" src="https://github.com/user-attachments/assets/b9bfc613-170d-41e4-b35f-b871989dc428" />

<p align="center">
  <a href="https://github.com/DAAF-Contribution-Community/daaf/releases"><img src="https://img.shields.io/badge/version-v2.0.0-blue" alt="Version v2.0.0"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-LGPL--3.0--or--later-green" alt="License: LGPL-3.0-or-later"></a>
  <a href="https://github.com/DAAF-Contribution-Community/daaf/stargazers"><img src="https://img.shields.io/github/stars/DAAF-Contribution-Community/daaf?style=flat" alt="GitHub Stars"></a>
  <a href="https://github.com/DAAF-Contribution-Community/daaf/commits/main"><img src="https://img.shields.io/github/last-commit/DAAF-Contribution-Community/daaf" alt="Last Commit"></a>
  <a href="https://doi.org/10.5281/zenodo.19343886"><img src="https://zenodo.org/badge/1152411514.svg" alt="DOI"></a>
</p>

LLM-based AI assistants are becoming **increasingly capable**, but they are always at risk of hallucination, sycophancy, over-confidence, and laziness. So can these flawed and non-deterministic tools ever be useful for conducting rigorous data analysis? 

**Yes** -- but only with the right guidance, right guardrails, and in expert hands to direct all core decisions and verify all key outputs.

Enter **DAAF, the Data Analyst Augmentation Framework.** DAAF is a free and open-source instructions framework for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that helps skilled researchers rapidly scale their expertise and accelerate data analysis across any domain with AI assistance -- without sacrificing the transparency, rigor, or reproducibility that good science demands. DAAF sits between you and Claude Code to automatically and consistently help Claude think more like a responsible and rigorous researcher by:

- Enforcing strict auditability and reproducibility standards for all work, thus allowing you to **verify everything** Claude does on your behalf
- Preventing potentially dangerous unintended file access and editing, by sandboxing Claude with strict protections and logging traces
- Setting high standards of care, rigor, and thoroughness in all data analysis, by forcing Claude to comment, verify, and review all analytic code before you ever see it
- Embedding best practices for a wide variety of research methodologies like causal inference and geospatial analysis, by providing rich Skills that extend Claude's base capabilities with real research and resources
- Collaborating with **you**, the human expert, directly on all key decisions, thus keeping you firmly in the driver's seat

Think of it as a **force-multiplying exoskeleton** for human researchers -- a tool explicitly designed to **augment** your hard-earned expertise, not replace it. The goal is to make it easy for researchers to use Claude Code effectively **and** responsibly. Importantly, DAAF is not and will never be perfect -- but it is already immensely useful, and this is the worst a tool like DAAF will ever be from now on with the help and support of the broader research community.

Install and begin using it in as little as 10 minutes from a fresh install with a high-usage Anthropic account.

Watch the 4 minute v2.0.0 Showcase video below, or read on for more information!
  <p align="center">                                                                                                  
    <a href="https://youtu.be/747r7VT4a78">
      <img width="607" height="339" alt="image" src="https://github.com/user-attachments/assets/ba265c65-ba25-4a98-9789-d4a1d5af6815" alt="Watch the DAAF v2.0.0 Showcase />
      <img src="https://img.youtube.com/vi/747r7VT4a78/maxresdefault.jpg" "        
  width="720" />                                                                                                      
    </a>                                                                                                              
  </p>    

<p align="center">
  <a href="https://youtu.be/ZAM9OA0AlUs"><strong>Watch the v1.0.0 10-minute demo/walkthrough</strong></a> &nbsp;|&nbsp;
  <a href="user_reference/01_installation_and_quickstart.md"><strong>Installation Guide</strong></a> &nbsp;|&nbsp;
  <a href="#full-user-documentation-reference-and-recommended-next-steps"><strong>User Documentation Reference</strong></a> &nbsp;|&nbsp;
  <a href="https://daafguide.substack.com/"><strong>DAAF Field Guide Substack</strong></a> &nbsp;|&nbsp;
  <a href="https://discord.gg/7FWTnZJDqy"><strong>AI for Responsible and Rigorous Research Discord</strong></a> &nbsp;|&nbsp;
  <a href="CONTRIBUTING.md"><strong>Contributing to DAAF</strong></a>
</p>

---

## Quick Start

If you're already comfortable with the Terminal and Claude Code, you can get started almost immediately using the Quick Start instructions below. Otherwise, I recommend starting with the full [Installation Guide](user_reference/01_installation_and_quickstart.md) for beginner-friendly details, prerequisites, and troubleshooting.

**Requirements:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) (running) and an [Anthropic Max subscription](https://claude.com/pricing/max) ($100-200/mo) or [API key](https://console.anthropic.com/). 

<table>
<tr>
<td><strong>macOS / Linux (Terminal)</strong></td>
<td><strong>Windows (PowerShell)</strong></td>
</tr>
<tr>
<td>

```bash
# 1. Download the project files
curl -L -o daaf.zip https://github.com/DAAF-Contribution-Community/daaf/archive/refs/heads/main.zip

# 2. Extract the ZIP file
unzip daaf.zip

# 3. Enter the project directory
cd daaf-main

# 4. Copy files into a secure Docker volume
docker run --rm -v "${PWD}:/source:ro" \
  -v "daaf_daaf-data:/dest" \
  busybox sh -c 'cp -a /source/. /dest/'

# 5. Build and start the container
docker compose up -d --build

# 6. Enter the container
docker compose exec daaf-docker bash

# 7. Launch Claude Code
claude
```

</td>
<td>

```powershell
# 1. Download the project files
Invoke-WebRequest -Uri "https://github.com/DAAF-Contribution-Community/daaf/archive/refs/heads/main.zip" -OutFile daaf.zip

# 2. Extract the ZIP file
Expand-Archive -Path daaf.zip -DestinationPath .

# 3. Enter the project directory
cd daaf-main

# 4. Copy files into a secure Docker volume
docker run --rm -v "${PWD}:/source:ro" `
  -v "daaf_daaf-data:/dest" `
  busybox sh -c 'cp -a /source/. /dest/'

# 5. Build and start the container
docker compose up -d --build

# 6. Enter the container
docker compose exec daaf-docker bash

# 7. Launch Claude Code
claude
```

</td>
</tr>
</table>

On first launch, Claude Code will prompt you to authenticate. Set your model to **Opus 4.6** via `/model`, and set **Auto-compact** to **False** and **Verbose output** to **True** via `/config`. You're ready to go; see [Understanding DAAF](user_reference/02_understanding_daaf.md) for some suggestions on how to get started with progressively more complex tasks with DAAF!

---

## Design Principles

DAAF explicitly embraces the fact that LLM research assistants will never be perfect and can never be trusted as a matter of course. But with the right guardrails, they can still be immensely valuable for critically-minded researchers. Every design decision serves five core requirements:

- **Transparent.** Because LLMs will always be susceptible to lying, hallucinating, and cutting corners, DAAF forces Claude Code to operate using file-first principles: all data operations are drafted and run as actual Python files, all reasoning is stored as verbose comments, plan documents, and structured code output that you can review and intervene on at any time.
- **Scalable.** Because most LLMs are trained as generalists susceptible to sycophancy and overconfidence, DAAF provides a comprehensive and extensible set of explicit instructions and standards enforcing highly opinionated best practices (via agent and skill documents), injecting the right information at the right time for any specific task -- so you don't have to hold its hand every time to get good output.
- **Rigorous.** Because LLMs can work at speeds orders of magnitude faster than humans, DAAF's workflows force Claude to be meticulous, cautious, self-checking, and extremely thorough. Code is broken into hyper-atomic steps and adversarially reviewed. Plans and reports are informed by deep-dives into actual data documentation and actual exploratory analyses, then also reviewed by equally informed counterparts.
- **Reproducible.** Because good science needs to be reproducible, every single data file, script, and output is automatically stored throughout the entire process. You **do not** have to just trust DAAF or Claude Code -- you can and should verify everything yourself.
- **Responsible.** Because AI-assisted research demands accountability, DAAF ensures that data sources are properly cited, AI assistance is transparently disclosed via the [GUIDE-LLM](https://llm-checklist.com/) reporting standard, data usage terms are respected, limitations are honestly acknowledged, and the human researcher's judgment remains the final authority on all analytical decisions.

---

## Engagement Modes

When you open DAAF, just begin by asking it any question or for support with any type of task. DAAF intelligently responds to your needs by automatically selecting and walking you through one of eight possible research workflow modes (and you can feel free to redirect it if it gets it wrong!) while providing easy opportunities to transition across supported workflows as needed:

**Data Onboarding:** Make Claude an expert in **your** data
- *What you do:* Point DAAF to your data (local file, web download, or API) and any associated documentation
- *What DAAF does:* Runs a multi-stage data profiling process to learn all the ins and outs, with fully reproducible code
- *What you get:* An in-depth data documentation Skill that DAAF references for all future work with your data -- fully portable, share with colleagues
- *Example:* I've got a new BLS employment dataset I want to explore and understand a bit more. I've got this link to the dataset and a technical paper from them: can you start profiling it?

**Data Lookup:** Your personal data documentation oracle
- *What you do:* Ask DAAF a specific question about any dataset it has access to
- *What DAAF does:* Loads the data documentation Skill and reviews all relevant reference information in seconds
- *What you get:* A precise, documentation-informed answer with opportunities to dig deeper
- *Example:* Can you give me a sense of what the year variables actually indicate in the various IPEDS datasets?

**Data Discovery:** Connect the dots across data sources and topics
- *What you do:* Ask DAAF a broad data or research scoping question
- *What DAAF does:* Launches explorations across all available data documentation relevant to your question
- *What you get:* An in-depth summary of relevant opportunities, insights, clarifications, and caveats to consider
- *Example:* What are all the socioeconomic status related variables we have access to across the Urban Institute Education Portal datasets?

**Ad Hoc Collaboration:** A smarter, more grounded research partner
- *What you do:* Ask DAAF to help you riff on anything research-related -- code review, debugging, brainstorming, writing scripts
- *What DAAF does:* Engages as a collaborator with embedded domain and methodological expertise guiding the way
- *What you get:* A much more knowledgeable and careful Claude assistant for flexible, multi-turn working sessions
- *Example:* How would I implement a diff-in-diff design in Python? I know how in R but not the Python equivalents

**Full Pipeline:** From research question to results, with your guidance every step of the way
- *What you do:* Ask DAAF for support answering any arbitrarily complex research question with your data
- *What DAAF does:* Data scoping, analytic planning, data acquisition and cleaning, in-depth code review, analysis, visualization, and report writing -- the works
- *What you get:* A pre-analysis plan, a fully reproducible end-to-end analysis for close review, and a summary report with key findings, data visualizations, limitations, and citations
- *Example:* I want to analyze how graduation rates relate to admissions selectivity, while better accounting for factors like Pell share, student demographics, and other related factors

**Revision and Extension:** Make the first draft better and build beyond
- *What you do:* Ask for revisions to or new deliverables from any prior analysis
- *What DAAF does:* Reviews the prior analysis, launches targeted revisions, reruns analyses as needed, updates all downstream work
- *What you get:* Refined analyses, new dashboards, additional visualizations, stakeholder reports -- whatever you need
- *Example:* The scatter plots from yesterday look scrunched -- fix the sizing and propagate the changes downstream

**Reproducibility Verification:** Verify, don't trust. Ensure prior work is fully reproducible.
- *What you do:* Point DAAF to a completed Full Pipeline analysis (yours or someone else's)
- *What DAAF does:* Reruns and re-verifies every script against the final report, critiquing and exploring along the way
- *What you get:* An in-depth reproducibility report with issues, concerns, and summary takeaways
- *Example:* I want to verify that the graduation rate analysis reproduces correctly from its replication notebook before we share it with our collaborators

**Framework Development:** Make DAAF work for **you**
- *What you do:* Ask DAAF to improve its own functionality: new methodologies, new Python libraries, new domain expertise, or new modes entirely
- *What DAAF does:* Reviews its own architecture, conducts in-depth research, and meticulously updates its functionality
- *What you get:* A better DAAF with modular skills and agents you can share with colleagues or the community
- *Example:* I want to explore building in more supports for more sophisticated natural language processing techniques that allow us to classify open-response text

---

## Capabilities

The base framework comes ready to analyze any or all of the 40+ foundational public education datasets available via the [Urban Institute Education Data Portal](https://educationdata.urban.org/documentation/), and is readily extensible to new data domains and methodologies. DAAF also comes out-of-the-box with a deep understanding of many of the most common social science research methods and beyond: from causal inference techniques like difference-in-differences, to geospatial analysis, to unsupervised machine learning methods. Several additional skills are included to help DAAF support broader science communication skills, as well -- embedding many best practices related to data visualization, data dashboarding, science communication, and more.

**Included data sources:** CCD, CRDC, EdFacts, EADA, FSA, IPEDS, MEPS, NACUBO, NCCS, NHGIS, PSEO, SAIPE, College Scorecard, Campus Safety

**Methodological support:**
Difference-in-differences &bull; Fixed/random effects &bull; Mixed effects models &bull; Instrumental variables &bull; Regression discontinuity &bull; Synthetic control &bull; Event studies &bull; Propensity score matching &bull; Time series analysis &bull; Complex survey analysis &bull; Geospatial analysis & spatial statistics &bull; Decomposition analysis &bull; Quantile regression &bull; Exploratory data analysis &bull; DAG modeling &bull; Predictive analytics &bull; Cross-validation &bull; Algorithmic fairness assessment &bull; Cluster analysis &bull; Wild bootstrap inference &bull; Sensitivity analysis

**Python library expertise:**
polars &bull; pyfixest &bull; linearmodels &bull; statsmodels &bull; scikit-learn &bull; geopandas &bull; plotly &bull; plotnine &bull; marimo &bull; svy &bull; fairlearn &bull; SHAP &bull; PySAL &bull; LightGBM &bull; seaborn &bull; rdrobust &bull; marginaleffects

**Additional features:**
Interactive dashboards (Plotly) &bull; Reactive analytic notebooks (marimo) &bull; R/tidyverse-Python code translation &bull; Stata-Python code translation &bull; Citation propagation & verification &bull; GUIDE-LLM AI use disclosure &bull; Git version control &bull; Session transcript archiving &bull; Docker-based safety sandboxing &bull; Destructive command prevention &bull; Secret/credential scanning &bull; File-first execution enforcement &bull; Science communication

---

## Demos & Sample Projects

- [**Watch the v2.0.0 Showcase**](https://youtu.be/747r7VT4a78) highlighting all the current functionalities of DAAF
- [**Explore a sample Full Pipeline project**](https://github.com/DAAF-Contribution-Community/daaf/tree/main/research/2026-03-29_College_Graduation_Rate_Selectivity_Analysis) to see what kinds of reports, visualizations, reproducible scripts, and other artifacts DAAF can produce
- [**Explore a sample Reproducibility Verification project**](https://github.com/DAAF-Contribution-Community/daaf/tree/main/research/2026-03-30_College_Graduation_Rate_Selectivity_Analysis_Reproduction) to explore the outputs of a Reproducibility Verification process (using the same Full Pipeline project above)
- [**Watch the data onboarding demo**](https://www.youtube.com/watch?v=G5uKSlI6jls) explaining how the data onboarding process works (formerly "data ingestion" in v1.0.0) and talking through a use-case where we replicate the NYTimes' "Red Shift" interactive data visualization
- [**Watch the v1.0.0 10-minute demo**](https://youtu.be/ZAM9OA0AlUs) talking through the original modes, philosophy, and intentions behind DAAF

---

## Why Education Data?

DAAF is designed to be domain-extensible -- you can readily bring your own data sources into the ecosystem by engaging with the Data Onboarding mode (see this [10-minute tutorial](https://youtu.be/G5uKSlI6jls) for a demonstration). The [Urban Institute Education Data Portal](https://educationdata.urban.org/) serves as an excellent out-of-the-box demonstration domain because it offers:

- High-quality, well-documented public data
- Real, immediate policy relevance (K-12 schools, districts, colleges, outcomes)
- Sufficient complexity to stress-test the system (multiple sources, coded values, suppression rules, cross-state comparability issues)

These datasets allow new users to quickly and easily experiment with DAAF using genuine research questions, nuanced datasets, and complex analytic plans. The architecture, agents, methodological skills, validation protocols, engagement modes, and workflow stages are all domain-agnostic.

---

## Contributing

DAAF is in constant development as AI advances continue, and as more and more users find value in using DAAF for their own research. DAAF needs the support of the research community to grow into a reliable, scalable tool, so contributions of all kinds are welcome!

- **Bug reports and session learnings** -- even a quick issue with context is extremely valuable. Every completed Full Pipeline project produces a LEARNINGS.md file with actionable improvements that can be fed back into the framework for improvements
- **New data sources and methodological tools** -- use Data Onboarding mode to profile new datasets, or use the Framework Development mode to develop new statistical methods and domain expertise Skills to share back with the community.
- **Workflow improvements and documentation** -- suggestions for balancing quality with efficiency, clearer onboarding, and better documentation are all welcome.
- **Platform ports** -- the vast majority of DAAF's tooling can be ported to other agentic coding harnesses (Gemini CLI, Codex, OpenCode, etc.) with a good bit of elbow-grease, but it requires people who know the real ins-and-outs of these various harnesses' idiosyncrasies.

See [**Contributing to DAAF**](CONTRIBUTING.md) for the full contribution guide and [**Extending DAAF**](user_reference/04_extending_daaf.md) for adding new capabilities for your own use.

---

## Full User Documentation Reference and Recommended Next Steps

- **00. README** — **\[This document\]** Project overview, quick start, design philosophy, capabilities, and acknowledgments
- [**01. Installation & Quick Start**](user_reference/01_installation_and_quickstart.md) — **(Recommended Next Step)** Get started! Installation prerequisites, step-by-step setup, day-to-day usage, and troubleshooting
- [**02. Understanding and Working with DAAF**](user_reference/02_understanding_daaf.md) — Learn to work with DAAF for the first time: what to expect, how to use it, and how to test its strengths and limitations
- [**03. Best Practices**](user_reference/03_best_practices.md) — Tips for working with Claude Code, writing effective prompts, ensuring quality and rigor with DAAF, reviewing outputs, and managing context
- [**04. Extending DAAF**](user_reference/04_extending_daaf.md) — How to add new data source skills, analytical tools and methodologies, and creating your own additional specialized agents
- [**05. Contributing to DAAF**](CONTRIBUTING.md) — Get involved in developing DAAF! How to file issues via GitHub, support expanding the capabilities of the framework, contribute to educational tutorials and how-to's, and more!
- [**06. FAQ: Philosophy**](user_reference/06_faq_philosophy.md) — **(Recommended Next Step)** Grapples with the broader implications of this work, AI automation in general, model advancement pace, approaching the "exponential", environmental ethics, what this means for the next generation of researchers, and more
- [**07. FAQ: Technical Support**](user_reference/07_faq_technical.md) — Covers frequently asked questions about Docker, issues with Claude Code, usage limits, authentication errors, and other common errors

---

## How to Cite

If you use DAAF in your research, please cite it and all underlying data sources, methodological guidance, and software tooling (more on that below). Software citation ensures credit for open-source tools and supports reproducibility by recording the exact version used.

**Plain text (APA):**

> Kim, B. H. (2026). *DAAF: Data Analyst Augmentation Framework* (Version 2.0.0) [Computer software]. [https://doi.org/10.5281/zenodo.19343886](https://doi.org/10.5281/zenodo.19343886)

**BibTeX:**

```bibtex
@software{kim2026daaf,
  author = {Kim, Brian Heseung},
  title = {{DAAF}: Data Analyst Augmentation Framework},
  year = {2026},
  url = {https://github.com/DAAF-Contribution-Community/daaf},
  doi = {10.5281/zenodo.19343886},
  version = {2.0.0},
  license = {LGPL-3.0-or-later}
}
```

GitHub also provides a "Cite this repository" button (powered by the [`CITATION.cff`](CITATION.cff) file) that generates APA and BibTeX citations automatically. Following [FORCE11 Principle 6](https://force11.org/info/software-citation-principles-published-2016/) (Specificity), please cite the **exact version** of DAAF you used -- every DAAF report automatically records the git commit hash and version in its AI Use Disclosure section.

### Automatic Citation Tracking

Knowing the importance of citing who we build upon, DAAF includes a built-in citation propagation system that tracks data, methodological, and software attribution throughout the analysis pipeline. As DAAF executes your analysis, it accumulates citations for every data source accessed, statistical method applied, and software library used for estimation -- guided by a parsimony principle (cite what directly produced a result, not every library touched along the way). These are verified at the end of the pipeline and rendered into a structured References section in your final report, organized by data sources, methodological references, software and tools, and reporting standards.

That being said, the citations generated are best-effort, not guaranteed -- always review the References section of your report and add or adjust as needed for your publication context. See the [Citation Reference](agent_reference/CITATION_REFERENCE.md) for more information and examples for how the system thinks about this.

---

## Open Source & Licensing

This project is licensed under the **GNU Lesser General Public License v3.0** (LGPL-3.0-or-later). Anyone can use DAAF for any reason, for free, forever -- this work is too important and high-stakes to treat as anything but a shared effort we can all benefit from and contribute to.

**Internal use** -- personally or within your organization, no matter how extensively you modify the framework -- is completely unrestricted. More restrictions apply only if you **distribute a modified version**: core framework improvements must also be licensed open-source, but extensions built on top (skills for proprietary datasets, bespoke agents, etc.) can remain private under any license. This ensures DAAF stays open and community-driven while allowing use in contexts involving sensitive, proprietary, or classified data.

For the full philosophy behind this decision, see [FAQ: Philosophy](user_reference/06_faq_philosophy.md). See [LICENSE](LICENSE) and [COPYING.LESSER](COPYING.LESSER) for the full license text.

---

## About the Author

Hello! My name is Brian Heseung Kim ([@brhkim](https://github.com/brhkim)). I have been at the frontier of finding rigorous, careful, and auditable ways of using LLMs and their predecessors in social science research since roughly 2018. I focused my [entire Ph.D. dissertation](https://libraetd.lib.virginia.edu/public_view/nz806060w) on teaching others how to use these tools responsibly (finished in mid-2022, months before ChatGPT was released), and I've [continued](https://journals.sagepub.com/doi/10.3102/0013189X241276814) to [work](https://journals.sagepub.com/doi/10.3102/00028312241292309) on [that frontier](https://link.springer.com/article/10.1007/s11162-025-09847-5) through to today. As a former public high school English teacher, much of why DAAF is packaged as an educational endeavor comes from my belief that helping peers and colleagues rapidly skill-up on this frontier is one of the most important things I can do. I now work full-time developing DAAF and other AI frameworks to support the work of public-interest and research organizations as Founder and Chief Data Scientist at [Open Augments](https://openaugments.org/).

---

## Acknowledgments

### Urban Institute Education Data Portal

The current proof-of-concept iteration of this project would not be possible without the **[Urban Institute Education Data Portal](https://educationdata.urban.org/)** -- a remarkable public resource that harmonizes data from over a dozen federal education data sources into a single, well-documented API. We are deeply grateful to the Urban Institute for making high-quality education data freely accessible, providing excellent documentation and consistent data structures, harmonizing complex federal datasets, and supporting the research community with responsive maintenance and updates.

If you use DAAF or the Education Data Portal in your work, please cite the Urban Institute appropriately. See the [Education Data Portal documentation](https://educationdata.urban.org/documentation/) for citation guidelines.

### GUIDE-LLM Reporting Checklist

DAAF integrates the **[GUIDE-LLM](https://llm-checklist.com/)** reporting checklist into all output workflows to help researchers transparently and rigorously disclose how AI was used in their work. GUIDE-LLM is a consensus-based reporting standard developed by over 80 experts for studies using large language models in the behavioral and social sciences.

> Feuerriegel, S., Barrie, C., Crockett, M. J., Globig, L. K., McLoughlin, K. L., Mirea, D.-M., Spirling, A., Yang, D., ..., Rathje, S., & Ribeiro, M. H. (2026). A consensus-based reporting checklist for large language models in behavioral and social science. Available at: https://llm-checklist.com/

### Inspiration

Several core workflow patterns -- particularly around agent specialization, shared working memory, and task decomposition -- were improved thanks to excellent practices in **[Get Shit Done](https://github.com/glittercowboy/get-shit-done)** by [@glittercowboy](https://github.com/glittercowboy). Early thinking on DAAF was also rapidly accelerated by Dr. Anton Korinek's working paper, [AI Agents for Economic Research](https://www.genaiforecon.org/JEL-2025-Aug-AIAgents.pdf).

---

<p align="center">
  DAAF is free and always will be, as the flagship project of <a href="https://openaugments.org/">Open Augments</a>.
</p>
