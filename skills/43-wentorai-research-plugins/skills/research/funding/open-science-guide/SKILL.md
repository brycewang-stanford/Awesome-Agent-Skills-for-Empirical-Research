---
name: open-science-guide
description: "Pre-registration, open data, and FAIR principles for research"
metadata:
  openclaw:
    emoji: "🔓"
    category: "research"
    subcategory: "funding"
    keywords: ["pre-registration", "registered report", "open science framework", "FAIR data principles", "open data"]
    source: "wentor-research-plugins"
---

# Open Science Guide

Implement open science practices including study pre-registration, open data sharing, registered reports, and FAIR data principles to increase research transparency and reproducibility.

## Why Open Science?

Open science practices address the replication crisis and increase trust in research findings:

| Practice | Problem It Addresses |
|----------|---------------------|
| Pre-registration | Prevents HARKing (hypothesizing after results are known) and p-hacking |
| Open data | Enables verification, reanalysis, and meta-analyses |
| Open materials | Allows exact replication of studies |
| Open access | Removes paywalls that limit access to knowledge |
| Registered reports | Eliminates publication bias (acceptance before results are known) |
| Open code | Enables computational reproducibility |

## Pre-Registration

### What to Pre-Register

Pre-registration commits you to your research plan before seeing the data:

```markdown
Pre-registration template (standard fields):

1. HYPOTHESES
   - H1: [Specific, directional hypothesis]
   - H2: [Another hypothesis]

2. DESIGN
   - Study type: [Experiment / Survey / Observational]
   - Between/within subjects design: [Details]
   - Conditions: [List experimental conditions]

3. SAMPLING PLAN
   - Sample size: [N = X, justified by power analysis]
   - Stopping rule: [When will data collection stop?]
   - Inclusion/exclusion criteria: [List]

4. VARIABLES
   - Independent variables: [List with levels]
   - Dependent variables: [List with measurement details]
   - Covariates: [List any control variables]

5. ANALYSIS PLAN
   - Primary analysis: [Exact statistical test, e.g., "2x3 mixed ANOVA"]
   - Secondary analyses: [Additional planned analyses]
   - Inference criteria: [alpha level, correction for multiple comparisons]
   - Exclusion criteria: [How will outliers or failed attention checks be handled?]
   - Missing data: [How will missing data be handled?]

6. OTHER
   - Exploratory analyses: [Analyses not tied to specific hypotheses]
```

### Where to Pre-Register

| Platform | URL | Disciplines | Features |
|----------|-----|-------------|----------|
| OSF Registries | osf.io/registries | All | Free, flexible templates, versioned |
| AsPredicted | aspredicted.org | Social sciences, psychology | Simple 9-question form, private until shared |
| ClinicalTrials.gov | clinicaltrials.gov | Clinical research | Required for clinical trials (FDA) |
| PROSPERO | crd.york.ac.uk/prospero | Systematic reviews | Health-related reviews only |
| AEA RCT Registry | socialscienceregistry.org | Economics | RCTs in social sciences |

### Pre-Registration Workflow

```
1. Design your study
2. Write the pre-registration document
3. Have a colleague review it
4. Submit to a registration platform
5. Receive a time-stamped registration (URL + DOI)
6. Collect and analyze data following the pre-registered plan
7. Report results transparently:
   - Confirmatory analyses (pre-registered)
   - Exploratory analyses (clearly labeled as exploratory)
8. Link the pre-registration in your manuscript
```

## Registered Reports

Registered Reports are a publication format where peer review occurs before data collection:

```
Stage 1 (Before Data Collection):
  - Submit introduction, methods, and analysis plan
  - Peer review evaluates the research question and methodology
  - If accepted: "In-Principle Acceptance" (IPA)
  - Paper will be published regardless of results

Stage 2 (After Data Collection):
  - Collect data following the approved protocol
  - Analyze and report results
  - Add discussion section
  - Final peer review checks adherence to protocol
  - Publication
```

Over 300 journals now accept Registered Reports. Check the registry at cos.io/rr.

### Benefits of Registered Reports

- Eliminates publication bias (null results are published)
- Ensures methodological rigor is reviewed before sunk costs
- Prevents post-hoc changes to hypotheses or analyses
- Provides certainty of publication to researchers

## FAIR Data Principles

FAIR principles ensure research data is **F**indable, **A**ccessible, **I**nteroperable, and **R**eusable:

### Findable

```markdown
- F1: Data are assigned a globally unique, persistent identifier (DOI)
- F2: Data are described with rich metadata
- F3: Metadata include the identifier of the data
- F4: Data are registered or indexed in a searchable resource

Actions:
- Deposit data in a repository that assigns DOIs
- Write a comprehensive README and data dictionary
- Use standard metadata schemas (Dublin Core, DataCite)
```

### Accessible

```markdown
- A1: Data are retrievable by their identifier using open protocols (HTTP)
- A2: Metadata remain accessible even if data are no longer available

Actions:
- Use established repositories (not personal websites)
- Specify access conditions clearly (open, restricted, embargoed)
- Even if data cannot be shared, publish metadata describing them
```

### Interoperable

```markdown
- I1: Data use a formal, accessible, shared language (e.g., CSV, JSON, RDF)
- I2: Data use vocabularies that follow FAIR principles
- I3: Data include qualified references to other data

Actions:
- Use standard file formats (CSV, not proprietary Excel)
- Use standard variable names and coding schemes
- Link to related datasets using DOIs
```

### Reusable

```markdown
- R1: Data are richly described with provenance information
- R2: Data are released with a clear, accessible data usage license
- R3: Data meet domain-relevant community standards

Actions:
- Include a data dictionary with variable descriptions
- Apply a license (CC-BY 4.0 recommended)
- Describe data collection procedures, cleaning steps, and known issues
- Include analysis code alongside data
```

## Data Sharing Platforms

| Repository | Disciplines | Max Size | DOI | Cost |
|-----------|-------------|----------|-----|------|
| Zenodo | All | 50 GB | Yes | Free |
| Dryad | All (focus on sciences) | Unlimited | Yes | Sliding scale |
| Figshare | All | 20 GB (free) | Yes | Free/institutional |
| OSF | All | 5 GB (free) | Yes | Free |
| Harvard Dataverse | All (focus on social science) | 2.5 GB per file | Yes | Free |
| ICPSR | Social science | Varies | Yes | Free deposit |
| GenBank | Genomics | N/A | Accession numbers | Free |
| Protein Data Bank | Structural biology | N/A | PDB IDs | Free |

## Data Sharing Best Practices

### README Template for Data Deposits

```markdown
# Dataset: [Title]

## Description
Brief description of the dataset and the study it comes from.

## Citation
If you use this data, please cite:
[Full citation of the associated publication]

## File Description
- `data_raw.csv` - Raw data as collected (N = 500, 45 variables)
- `data_processed.csv` - Cleaned data after exclusions (N = 467, 38 variables)
- `codebook.csv` - Variable descriptions, types, and valid ranges
- `analysis_script.R` - Complete analysis code reproducing all results

## Variables (data_processed.csv)
| Variable | Type | Description | Valid Range |
|----------|------|-------------|-------------|
| participant_id | string | Unique participant identifier | P001-P500 |
| age | integer | Age in years | 18-65 |
| condition | categorical | Experimental condition | control, treatment_a, treatment_b |
| score_pre | numeric | Pre-test score | 0-100 |
| score_post | numeric | Post-test score | 0-100 |

## Missing Data
- 33 participants excluded for failing attention checks
- 12 missing values in `score_post` (participants did not complete)
- Missing coded as NA

## License
CC-BY 4.0 International

## Contact
[Name, email, ORCID]
```

### Sensitive Data Considerations

When data cannot be fully shared (e.g., due to participant privacy):

1. **Anonymize**: Remove direct identifiers (name, email, IP) and indirect identifiers (rare combinations of demographics)
2. **Aggregate**: Share summary statistics or aggregated data instead of individual-level data
3. **Restricted access**: Deposit data with access controls (e.g., ICPSR restricted-use data)
4. **Synthetic data**: Generate synthetic datasets that preserve statistical properties
5. **Controlled access**: Use data use agreements (DUAs) for sensitive data
6. **Code without data**: At minimum, share analysis code so methods are transparent

## Open Science Badges

Many journals award badges for open science practices:

| Badge | Meaning |
|-------|---------|
| Open Data | Data publicly available |
| Open Materials | Research materials publicly available |
| Preregistered | Study pre-registered before data collection |
| Preregistered + Analysis Plan | Preregistered with detailed analysis plan |

These badges (developed by COS) appear on published articles and signal commitment to transparency.
