# Civil Rights Legal Context for CRDC

The CRDC exists to support enforcement of federal civil rights laws in education. Understanding this legal framework is essential for interpreting the data correctly.

## Why Civil Rights Data Collection Exists

The CRDC serves OCR's mission to:

1. **Investigate complaints** - Data helps OCR identify potential civil rights violations
2. **Initiate compliance reviews** - Proactive investigations based on data patterns
3. **Provide technical assistance** - Help schools understand compliance requirements
4. **Inform policy guidance** - Develop guidance documents for schools and districts
5. **Support research** - Enable researchers to study educational equity

### Legal Authority

Section 203(c)(1) of the Department of Education Organization Act:
> "[The Assistant Secretary for Civil Rights has authority to] collect or coordinate the collection of data necessary to ensure compliance with civil rights laws within the jurisdiction of the Office for Civil Rights."

See 20 U.S.C. § 3413(c)(1)

---

## Title VI of the Civil Rights Act of 1964

### What It Prohibits

**Title VI prohibits discrimination based on race, color, or national origin** in programs receiving federal financial assistance.

> "No person in the United States shall, on the ground of race, color, or national origin, be excluded from participation in, be denied the benefits of, or be subjected to discrimination under any program or activity receiving Federal financial assistance."

### Key Applications in Education

| Area | Civil Rights Concern |
|------|---------------------|
| **Discipline** | Disproportionate suspension/expulsion rates by race |
| **Course access** | Unequal access to AP, honors, gifted programs |
| **School resources** | Inequitable teacher quality, facilities |
| **School assignment** | Segregation, inequitable school boundaries |
| **English learners** | Failure to provide language services (national origin) |

### CRDC Data Elements for Title VI

- Enrollment by race/ethnicity
- Discipline incidents by race/ethnicity
- Course enrollment by race/ethnicity
- Restraint/seclusion by race/ethnicity
- Chronic absenteeism by race/ethnicity
- Gifted program participation by race/ethnicity

### Enforcement Standards

Title VI violations can be established through:
- **Intentional discrimination** - Explicit discriminatory policies
- **Disparate impact** - Facially neutral policies with discriminatory effect
- **Hostile environment** - Race-based harassment

### Common Disparate Impact Analysis

```python
import polars as pl

def check_discipline_disparity(df: pl.DataFrame) -> dict:
    """
    Calculate if Black students are disciplined at
    disproportionately higher rates than White students.

    OCR often looks at risk ratios > 2.0 as potential red flags.

    Args:
        df: CRDC discipline data with race, enrollment_crdc,
            and students_susp_out_sch_single columns.
            Uses Portal integer codes: race=2 (Black), race=1 (White).
    """
    # Filter to totals for sex/disability/lep to avoid double-counting
    totals = df.filter(
        (pl.col("sex") == 99) &
        (pl.col("disability") == 99) &
        (pl.col("lep") == 99)
    )

    black = totals.filter(pl.col("race") == 2)
    white = totals.filter(pl.col("race") == 1)

    black_oss = black.filter(pl.col("students_susp_out_sch_single") >= 0)
    white_oss = white.filter(pl.col("students_susp_out_sch_single") >= 0)

    black_rate = black_oss.select(pl.col("students_susp_out_sch_single").sum()).item() / \
                 black_oss.select(pl.col("enrollment_crdc").sum()).item() * 100
    white_rate = white_oss.select(pl.col("students_susp_out_sch_single").sum()).item() / \
                 white_oss.select(pl.col("enrollment_crdc").sum()).item() * 100

    risk_ratio = black_rate / white_rate if white_rate > 0 else None

    return {
        "black_suspension_rate": black_rate,
        "white_suspension_rate": white_rate,
        "risk_ratio": risk_ratio,
        "potential_concern": risk_ratio is not None and risk_ratio > 2.0,
    }
```

---

## Title IX of the Education Amendments of 1972

### What It Prohibits

**Title IX prohibits discrimination based on sex** in education programs receiving federal financial assistance.

> "No person in the United States shall, on the basis of sex, be excluded from participation in, be denied the benefits of, or be subjected to discrimination under any education program or activity receiving Federal financial assistance."

### Key Applications in Education

| Area | Civil Rights Concern |
|------|---------------------|
| **Sexual harassment** | Sexual violence, harassment, hostile environment |
| **Athletics** | Unequal athletic opportunities by sex |
| **Course access** | Sex-based steering away from STEM courses |
| **Discipline** | Sex-based disparities in discipline |
| **Pregnancy** | Discrimination against pregnant students |

### CRDC Data Elements for Title IX

- Enrollment by sex
- Discipline incidents by sex
- Harassment/bullying allegations based on sex
- Course enrollment by sex (especially STEM, AP)
- Interscholastic athletics participation (2015-16, 2017-18 only)
- Single-sex classes

### Sexual Harassment Categories in CRDC

The CRDC collects harassment data in specific categories:

| Category | Definition |
|----------|------------|
| **Harassment based on sex** | Unwelcome conduct of a sexual nature |
| **Sexual violence** | Rape, sexual assault, sexual battery, sexual coercion |

### Data Collected

For each category:
- Number of students **alleging** harassment
- Number of students **disciplined** for harassment
- Disaggregated by sex and disability status

---

## Section 504 of the Rehabilitation Act of 1973

### What It Prohibits

**Section 504 prohibits discrimination based on disability** in programs receiving federal financial assistance.

> "No otherwise qualified individual with a disability in the United States... shall, solely by reason of her or his disability, be excluded from the participation in, be denied the benefits of, or be subjected to discrimination under any program or activity receiving Federal financial assistance."

### Key Applications in Education

| Area | Civil Rights Concern |
|------|---------------------|
| **Discipline** | Disproportionate discipline of students with disabilities |
| **Restraint/seclusion** | Inappropriate use with students with disabilities |
| **Course access** | Exclusion from advanced courses |
| **Program access** | Denial of accommodations, modifications |
| **Evaluation** | Failure to evaluate suspected disabilities |

### Section 504 vs. IDEA

| Aspect | Section 504 | IDEA |
|--------|-------------|------|
| **Scope** | Broader (any disability) | Narrower (13 categories) |
| **Eligibility** | "Substantially limits major life activity" | Specific disability categories |
| **Plan type** | 504 Plan | IEP (Individualized Education Program) |
| **Services** | Accommodations | Specialized instruction + related services |
| **Funding** | No additional funding | Federal IDEA funding |

### CRDC Data for Section 504

- Students with disabilities counts (served under IDEA)
- Students with Section 504 plans only
- Discipline by disability status
- Restraint/seclusion by disability status
- Course enrollment by disability status

### Restraint and Seclusion Focus

Section 504 and OCR guidance require:
- Use restraint/seclusion only when necessary for safety
- Never use as punishment or convenience
- Document all incidents
- Disproportionate use may indicate discrimination

---

## IDEA (Individuals with Disabilities Education Act)

### What It Requires

IDEA is not a civil rights law per se but an **entitlement law** that provides federal funding for special education. However, it intersects with civil rights:

- **FAPE** - Free Appropriate Public Education
- **LRE** - Least Restrictive Environment
- **Child Find** - Identify all children with disabilities
- **Procedural safeguards** - Parent rights in special education process

### CRDC Data Related to IDEA

| Data Element | Purpose |
|--------------|---------|
| Students served under IDEA | Identify special education population |
| Disability categories | Breakdown by type of disability |
| Educational settings | LRE placement information |
| Discipline of IDEA students | Monitor for disproportionality |
| Restraint/seclusion | Monitor safety concerns |

### Discipline Protections Under IDEA

IDEA provides special discipline protections:
- **Manifestation determination** - Is behavior related to disability?
- **10-day rule** - Limits on cumulative suspensions
- **Interim alternative placement** - For weapons, drugs, serious injury
- **Continuation of services** - Must continue education during removal

### Disproportionality in Special Education

CRDC helps identify:
- **Identification disproportionality** - Are certain races over/under-identified for special ed?
- **Placement disproportionality** - Are certain races more often in restrictive settings?
- **Discipline disproportionality** - Are students with disabilities over-disciplined?

---

## Age Discrimination Act of 1975

### What It Prohibits

Prohibits discrimination based on age in programs receiving federal financial assistance. Less commonly invoked in K-12 but applies to:

- Adult education programs
- GED programs
- Certain preschool policies

---

## OCR Enforcement Process

### How OCR Uses CRDC Data

```
CRDC Data Collection
        ↓
┌───────────────────────────────────────┐
│  OCR Analysis and Monitoring          │
│  - Identify patterns of disparity     │
│  - Flag potential compliance issues   │
│  - Prioritize reviews                 │
└───────────────────────────────────────┘
        ↓
┌───────────────────────────────────────┐
│  Complaint Investigation              │
│  - Individual files complaint         │
│  - OCR investigates using CRDC data   │
│  - May expand to systemic review      │
└───────────────────────────────────────┘
        ↓
┌───────────────────────────────────────┐
│  Compliance Review                    │
│  - OCR-initiated (proactive)          │
│  - Based on CRDC patterns             │
│  - Can be statewide or local          │
└───────────────────────────────────────┘
        ↓
┌───────────────────────────────────────┐
│  Resolution                           │
│  - Voluntary resolution agreement     │
│  - Letter of findings                 │
│  - Fund termination (rare)            │
└───────────────────────────────────────┘
```

### Types of OCR Actions

| Action | Description |
|--------|-------------|
| **Complaint resolution** | Resolve individual complaint |
| **Compliance review** | Proactive investigation |
| **Technical assistance** | Guidance without enforcement |
| **Dear Colleague letters** | Policy guidance for field |
| **Resource materials** | Best practice documents |

### Filing a Complaint

Anyone can file a civil rights complaint with OCR:
- Within **180 days** of alleged discrimination
- Can be filed by student, parent, or third party
- Triggers OCR investigation
- CRDC data may be used in investigation

---

## Intersection of Civil Rights Laws

Many civil rights concerns involve **multiple protected classes**:

### Intersectional Analysis

| Scenario | Laws Implicated |
|----------|-----------------|
| Black girls suspended at high rates | Title VI (race) + Title IX (sex) |
| Latino students with disabilities in restrictive settings | Title VI (national origin) + Section 504/IDEA |
| Sexual harassment of student with disability | Title IX (sex) + Section 504 (disability) |
| English learner denied AP courses | Title VI (national origin) |

### CRDC Disaggregation Enables Intersectional Analysis

CRDC provides cross-tabulated data:
- Race × Sex
- Race × Disability
- Sex × Disability
- Some data: Race × Sex × Disability

---

## Key OCR Guidance Documents

| Document | Topic | Relevance |
|----------|-------|-----------|
| Dear Colleague Letter on Discipline (2014, rescinded 2018) | Discipline disparities | Framework for analyzing discipline |
| Dear Colleague Letter on Sexual Violence (2011, rescinded 2017) | Title IX compliance | Sexual harassment response |
| Resource Guide on Disability Harassment (2014) | Section 504/IDEA | Harassment of students with disabilities |
| Dear Colleague Letter on Transgender Students (2016, rescinded 2017) | Title IX | Gender identity protections |
| OCR Restraint and Seclusion Guidance (various) | Section 504/IDEA | Appropriate use of restraint |

**Note**: Several Obama-era guidance documents were rescinded during Trump administration but concepts remain relevant for understanding civil rights frameworks.

---

## Implications for Data Analysis

When analyzing CRDC data, always consider:

1. **Why this data exists** - Civil rights enforcement, not just research
2. **Protected classes** - Race, sex, disability, national origin
3. **Disparate impact** - Neutral policies can still violate civil rights
4. **Intersectionality** - Multiple identities may compound disparities
5. **Policy context** - Guidance and enforcement priorities change
6. **Local context** - National data may not reflect local conditions

### Analytical Caution

```
CRDC finding of disparity ≠ Civil rights violation

Disparity may indicate:
- Discrimination requiring remedy
- Legitimate non-discriminatory explanation
- Data quality or reporting issues
- Need for further investigation
```

---

## Resources

### Official Resources
- OCR website: https://www2.ed.gov/about/offices/list/ocr/
- CRDC data: https://civilrightsdata.ed.gov/
- CRDC Resource Center: https://crdc.communities.ed.gov/

### Legal References
- Title VI: 42 U.S.C. § 2000d
- Title IX: 20 U.S.C. § 1681
- Section 504: 29 U.S.C. § 794
- IDEA: 20 U.S.C. § 1400 et seq.
- Age Discrimination Act: 42 U.S.C. § 6101
