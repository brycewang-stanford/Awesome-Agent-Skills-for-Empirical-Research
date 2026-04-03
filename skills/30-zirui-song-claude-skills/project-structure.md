---
description: Project directory organization and script naming conventions for research
---

# Research Project Code Structure Guide

This document outlines the standardized structure for research project code organization. Use this as a template for organizing future research projects.

---

## Overall Project Structure

```
Project Root/
├── Code/                           # All analysis scripts
│   ├── [Numbered]_[Descriptive].py # Data processing scripts (Python)
│   ├── AN_[Number]_[Descriptive].py # Analysis scripts (Python)
│   ├── AN_[Number]_[Descriptive].do # Analysis scripts (Stata)
│   ├── LogFiles/                   # Stata log files
│   └── README.md                   # Project documentation
├── Data/                           # All data files
│   ├── Raw/                        # Original, unprocessed data
│   ├── Intermediate/               # Partially processed data
│   └── Clean/                      # Final, analysis-ready datasets
└── Results/                        # Analysis outputs
    ├── Tables/                     # Regression tables, summary stats
    └── Figures/                    # Plots, charts, visualizations
```

---

## Script Naming Conventions

### 1. Data Processing Scripts (Python)

**Format:** `[Number]_[DescriptiveName].py`

**Examples:**
- `0_ExtractCreditAgreements.py`
- `1a_CleanCompAnnualCRSP.py`
- `1b_ProcessDealscanCompustat.py`
- `2_MergeAgreementsCompCRSP.py`
- `3a_ExtractLoanOfficerNames.py`
- `4a1_ExtractLoanTerms.py`
- `4b_CleanLoanOfficerPanel.py`

**Numbering Logic:**
- **0:** Initial data extraction from raw sources
- **1:** Data cleaning and preparation
- **2:** Data merging and linking
- **3:** Feature extraction and engineering
- **4:** Final data preparation for analysis
- **Sub-numbers (a, b, c)** for parallel processing steps
- **Sub-sub-numbers (1, 2, 3)** for sequential steps within a stage

### 2. Analysis Scripts

**Python Analysis Scripts:**
- Format: `AN_[Number]_[DescriptiveName].py`
- Examples:
  - `AN_1a_DescribeSample.py`
  - `AN_1b_DescribeSample_NoLinkedin.py`
  - `AN_1c_DescribeSample_Dealscan_Aggregated.py`

**Stata Analysis Scripts:**
- Format: `AN_[Number]_[DescriptiveName].do`
- Examples:
  - `AN_2a_MainRegressions_ChatGPT.do`
  - `AN_2b_MainRegressions_ChatGPT_NoLinkedin.do`
  - `AN_2c_MainRegressions_Dealscan_NoLinkedin.do`
  - `AN_2d_MainRegressions_Dealscan_NoLinkedin_Aggregated.do`
  - `AN_2e_MainRegressions_Dealscan_Secured.do`
  - `AN_2f_MainRegressions_Dealscan_Covenants.do`

**Analysis Numbering Logic:**
- **AN_1:** Descriptive statistics and sample characterization
- **AN_2:** Main regression analyses
- **AN_3:** Robustness tests and additional analyses
- **AN_4:** Extensions and additional specifications

---

## Script Structure Patterns

### 1. Python Data Processing Scripts

**Standard Structure:**
```python
"""
[Script Name]
[Brief Description]

[Detailed description of what the script does]
"""

import pandas as pd
import numpy as np
from pathlib import Path
# Other imports as needed

def get_project_root():
    """Automatically detect the project root directory."""
    return Path(__file__).parent.absolute()

def [main_function]():
    """Main processing function."""
    # Script logic here
    pass

if __name__ == "__main__":
    [main_function]()
```

**Key Features:**
- Always include `get_project_root()` function for path management
- Use relative paths from project root
- Include comprehensive docstrings
- Print progress updates and summary statistics
- Handle file existence checks and error cases

### 2. Stata Analysis Scripts

**Standard Structure:**
```stata
/***********
    Globals for Paths
    ***********/

*** Change repodir and overleafdir paths for different users
global repodir "/path/to/project/root"
global datadir "$repodir/Data"
global rawdir "$datadir/Raw"
global cleandir "$datadir/Clean"
global tabdir "$repodir/Results/Tables"
global figdir "$repodir/Results/Figures"
global logdir "$repodir/Code/LogFiles"

* Start logging
log using "$logdir/[ScriptName].log", replace

/***********
    [Analysis Section]
    ***********/

* Analysis code here

* Close log file
log close
```

**Key Features:**
- Standardized global path definitions
- Automatic logging to LogFiles directory
- Clear section headers with asterisk borders
- Consistent commenting style

### 3. Python Analysis Scripts

**Standard Structure:**
```python
"""
[Script Name]
[Brief Description]

This script [detailed description] based on the analysis
in [corresponding Stata do file]
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

def get_project_root():
    """Automatically detect the project root directory."""
    return Path(__file__).parent.absolute()

def load_data():
    """Load the cleaned data."""
    # Data loading logic
    pass

def [analysis_function]():
    """Perform specific analysis."""
    # Analysis logic
    pass

def main():
    """Main analysis function."""
    # Orchestrate all analyses
    pass

if __name__ == "__main__":
    main()
```

---

## Data Organization Principles

### 1. Data Folder Structure
- **Raw/:** Original data files (never modify)
- **Intermediate/:** Partially processed data (can be regenerated)
- **Clean/:** Final analysis-ready datasets

### 2. File Naming Conventions
- Use descriptive names with underscores
- Include version indicators when appropriate
- Examples:
  - `loan_officer_final_panel_chatgpt_cleaned.csv`
  - `dealscan_merged_tranche_level.csv`
  - `comp_crspa_merged.csv`

### 3. Data Flow
```
Raw Data → Intermediate Processing → Clean Data → Analysis
(Scripts 0-4)                    (Scripts AN_1-AN_4)
```

---

## Logging and Output Management

### 1. Stata Logging
- All Stata scripts automatically log to LogFiles/ directory
- Log files named to match script names
- Use "replace" option to overwrite previous runs

### 2. Python Output
- Print progress updates and summary statistics
- Save figures to Results/Figures/ with descriptive names
- Save tables to Results/Tables/ when applicable

### 3. Error Handling
- Check for file existence before processing
- Provide clear error messages
- Handle missing data gracefully

---

## Version Control and Collaboration

### 1. Script Versioning
Use descriptive suffixes for different versions:
- `_ChatGPT.py` (uses ChatGPT-extracted data)
- `_NoLinkedin.py` (excludes LinkedIn variables)
- `_Dealscan.py` (uses Dealscan data)
- `_Aggregated.py` (uses aggregated data)

### 2. Path Management
- Always use `get_project_root()` for Python scripts
- Use global macros for Stata scripts
- Make paths easily configurable for different users

### 3. Documentation
- Include comprehensive README.md
- Document all output files and their purposes
- Explain data flow and dependencies

---

## Best Practices Summary

### 1. Naming
- Use consistent numbering system (0, 1, 2, 3, 4 for processing; AN_1, AN_2 for analysis)
- Include descriptive names that explain the script's purpose
- Use underscores for multi-word names

### 2. Organization
- Separate data processing from analysis
- Group related scripts with similar numbering
- Keep all code in Code/ directory

### 3. Structure
- Follow standard script templates
- Include comprehensive docstrings and comments
- Use consistent path management

### 4. Output
- Log all Stata runs automatically
- Print progress updates in Python
- Save outputs to appropriate Results/ subdirectories

### 5. Collaboration
- Make paths easily configurable
- Document all dependencies and requirements
- Use version suffixes for different data sources or specifications

---

## Example Project Setup

For a new research project, create this structure:

```
NewProject/
├── Code/
│   ├── 0_ExtractRawData.py
│   ├── 1a_CleanDatasetA.py
│   ├── 1b_CleanDatasetB.py
│   ├── 2_MergeDatasets.py
│   ├── 3_ExtractFeatures.py
│   ├── 4_PrepareAnalysisData.py
│   ├── AN_1a_DescribeSample.py
│   ├── AN_2a_MainRegressions.do
│   ├── AN_2b_RobustnessTests.do
│   ├── LogFiles/
│   └── README.md
├── Data/
│   ├── Raw/
│   ├── Intermediate/
│   └── Clean/
└── Results/
    ├── Tables/
    └── Figures/
```

This structure ensures:
- Clear separation of data processing and analysis
- Consistent naming conventions
- Easy navigation and understanding
- Reproducible research workflow
- Collaboration-friendly organization
