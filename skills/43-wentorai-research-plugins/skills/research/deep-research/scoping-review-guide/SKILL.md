---
name: scoping-review-guide
description: "Scoping review methodology for broad evidence mapping"
metadata:
  openclaw:
    emoji: "🔭"
    category: "research"
    subcategory: "deep-research"
    keywords: ["scoping review", "scoping study", "rapid review", "umbrella review"]
    source: "wentor-research-plugins"
---

# Scoping Review Guide

Conduct scoping reviews to map the breadth and nature of research evidence on a topic, using the Arksey & O'Malley framework and JBI methodology with PRISMA-ScR reporting.

## Scoping Review vs. Systematic Review

| Feature | Scoping Review | Systematic Review |
|---------|---------------|-------------------|
| **Purpose** | Map the evidence landscape | Answer a specific clinical/research question |
| **Question** | Broad, exploratory | Focused, narrow |
| **Inclusion criteria** | Broadly defined, may evolve | Strictly predefined |
| **Quality assessment** | Optional (not always done) | Required (risk of bias) |
| **Synthesis** | Descriptive/thematic mapping | Quantitative (meta-analysis) or narrative |
| **Protocol registration** | Recommended (OSF) | Required (PROSPERO) |
| **Reporting guideline** | PRISMA-ScR | PRISMA 2020 |

### When to Choose a Scoping Review

- To examine the extent, range, and nature of research activity on a topic
- To determine whether a full systematic review is warranted
- To identify key concepts, evidence gaps, and types of available evidence
- To map the research landscape before designing a primary study
- When the topic is too broad or heterogeneous for a systematic review

## Arksey and O'Malley Framework (5 Stages)

### Stage 1: Identifying the Research Question

Scoping review questions are broad and use the PCC framework:

```
Population:  Who is being studied?
Concept:     What is the key concept or phenomenon?
Context:     In what setting or discipline?

Example question:
"What is known about the use of AI tools in undergraduate
STEM education, including types of tools, pedagogical
approaches, and reported outcomes?"
```

### Stage 2: Identifying Relevant Studies

Conduct a comprehensive search across multiple sources:

```
Search strategy development:
1. Identify key terms from the PCC framework
2. Develop synonyms and related terms for each concept
3. Combine using Boolean operators

Example search string (PubMed):
("artificial intelligence" OR "machine learning" OR "deep learning"
 OR "natural language processing" OR "chatbot" OR "intelligent tutoring")
AND
("undergraduate" OR "higher education" OR "university student"
 OR "college student")
AND
("STEM" OR "science education" OR "engineering education"
 OR "mathematics education" OR "computer science education")

Databases to search:
- Discipline-specific databases (ERIC, PubMed, IEEE Xplore, etc.)
- Multidisciplinary databases (Scopus, Web of Science)
- Grey literature sources (ProQuest Dissertations, conference proceedings)
- Reference lists of included studies
```

### Stage 3: Study Selection

Develop and apply inclusion/exclusion criteria iteratively:

```markdown
| Criterion | Inclusion | Exclusion |
|-----------|-----------|-----------|
| Population | Undergraduate STEM students | K-12, graduate, non-STEM |
| Concept | AI-based educational tools | Non-AI technology (e.g., basic LMS) |
| Context | Formal educational settings | Informal learning, self-study apps |
| Study type | Empirical research (any design) | Editorials, opinion pieces |
| Language | English, Chinese | Other languages |
| Date | 2015-2025 | Before 2015 |
```

Screening process:
1. Import all records into a reference manager or screening tool (Rayyan, Covidence)
2. Remove duplicates
3. Title/abstract screening by two reviewers (independently recommended but not always required)
4. Full-text screening with documented exclusion reasons
5. Pilot screening on 50-100 records to calibrate inclusion criteria

### Stage 4: Charting the Data

Create a data charting form to extract standardized information:

```python
# Example: Data charting template as a structured dictionary
charting_template = {
    "study_id": "",           # Author, year
    "country": "",            # Country where study was conducted
    "study_design": "",       # RCT, quasi-experimental, case study, survey, etc.
    "sample_size": 0,
    "population": "",         # Student demographics
    "ai_tool_type": "",       # Chatbot, ITS, NLP-based, etc.
    "ai_tool_name": "",       # Specific tool name (e.g., ChatGPT, ALEKS)
    "subject_area": "",       # Physics, CS, Math, Biology, etc.
    "pedagogical_approach": "",  # Flipped classroom, adaptive learning, etc.
    "outcome_measures": [],   # Learning gains, engagement, satisfaction, etc.
    "key_findings": "",       # Brief summary of main results
    "limitations": ""         # Reported limitations
}
```

### Stage 5: Collating, Summarizing, and Reporting Results

Present results using multiple formats:

**Descriptive numerical summary**:
- Number of studies by year of publication
- Geographic distribution
- Study designs used
- AI tool types
- Outcome categories

**Thematic analysis**:
- Group findings into themes
- Identify patterns, trends, and gaps
- Map the conceptual landscape

```python
import pandas as pd
import matplotlib.pyplot as plt

# Example: Visualize publication trends
df = pd.read_csv("charted_data.csv")

# Publications by year
year_counts = df["year"].value_counts().sort_index()
fig, ax = plt.subplots(figsize=(10, 5))
ax.bar(year_counts.index, year_counts.values, color="#0072B2")
ax.set_xlabel("Publication Year")
ax.set_ylabel("Number of Studies")
ax.set_title("Included Studies by Year")
plt.tight_layout()
plt.savefig("studies_by_year.pdf", dpi=300)

# Evidence map: cross-tabulation
evidence_map = pd.crosstab(df["ai_tool_type"], df["outcome_measures"])
print(evidence_map)
```

## Other Review Types

### Rapid Review

A streamlined systematic review with methodological shortcuts to produce evidence within a compressed timeline (typically 2-6 months):

| Shortcut | Trade-off |
|----------|-----------|
| Limit to 2-3 databases | May miss some studies |
| Single reviewer screening | Risk of selection bias |
| Simplified data extraction | Less comprehensive data |
| No formal quality assessment | Cannot assess evidence strength |
| Limit publication date range | May miss foundational studies |

### Umbrella Review (Review of Reviews)

A review of existing systematic reviews and meta-analyses on a topic:

1. Search for systematic reviews (use review filter in PubMed)
2. Assess methodological quality of reviews using AMSTAR 2
3. Extract and compare pooled estimates across reviews
4. Identify areas of agreement, disagreement, and gaps

### Narrative Review

A traditional literature review that is not systematic:
- No pre-defined protocol or search strategy
- Author-selected references
- Subjective synthesis
- Appropriate for educational overviews, opinion pieces, and introductory sections of papers
- Not suitable for evidence-based decision-making

## PRISMA-ScR Checklist (Key Items)

| Item | Description |
|------|-------------|
| Title | Identify the report as a scoping review |
| Protocol | Indicate if a protocol was registered |
| Objectives | State the research question using PCC |
| Eligibility criteria | Describe inclusion/exclusion criteria |
| Information sources | List all databases and other sources searched |
| Search strategy | Present full search strategy for at least one database |
| Selection of evidence | Describe screening process |
| Data charting | Describe data charting process and variables |
| Results | Present characteristics of included studies (tables, charts) |
| Discussion | Summarize main findings, compare to existing knowledge |
| Limitations | Discuss limitations of the evidence and of the review process |

## Practical Tips

1. **Use a reference manager from the start**: Import all search results into Zotero or EndNote to track deduplication and screening decisions.
2. **Iterate on inclusion criteria**: Unlike systematic reviews, scoping review criteria can be refined post hoc as you become more familiar with the literature. Document all changes.
3. **Create visual evidence maps**: Tables and figures (bubble charts, Sankey diagrams) are more effective than narrative descriptions for communicating the landscape.
4. **Consider stakeholder engagement**: Arksey and O'Malley recommend an optional Stage 6: consultation with practitioners, policymakers, or patients to validate findings.
5. **Plan for scale**: Scoping reviews often retrieve thousands of records. Budget time accordingly (expect 2-4 months for a well-done scoping review).
