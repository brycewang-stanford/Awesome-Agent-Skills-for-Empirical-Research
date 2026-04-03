# CRDC Data Elements

Comprehensive reference for all data categories collected in the Civil Rights Data Collection. This document covers what is collected, how it's disaggregated, and analytical considerations.

## Contents

- [Enrollment](#enrollment)
- [Discipline](#discipline)
- [Restraint and Seclusion](#restraint-and-seclusion)
- [Harassment and Bullying](#harassment-and-bullying)
- [Chronic Absenteeism](#chronic-absenteeism)
- [Course Access and Offerings](#course-access-and-offerings)
- [Advanced Courses (AP/IB/Gifted)](#advanced-courses-apibgifted)
- [Students with Disabilities](#students-with-disabilities)
- [English Learners](#english-learners)
- [Preschool](#preschool)
- [Retention](#retention)
- [Staffing](#staffing)
- [School Offenses](#school-offenses)
- [School Characteristics](#school-characteristics)

---

## Enrollment

### What's Collected

Total student enrollment disaggregated by:
- Race/ethnicity (7 categories)
- Sex (male/female)
- Disability status (IDEA-served, 504-only)
- English learner status

### Key Variables

| Portal Column | Description |
|---------------|-------------|
| `enrollment_crdc` | Enrollment count (varies by row's race/sex/disability/lep combination) |
| `psenrollment_crdc` | Preschool enrollment count |

> **Portal Data Structure:** Unlike OCR raw files which have separate columns per subgroup (e.g., `enrollment_black`, `enrollment_male`), the Portal uses a row-based structure. Each row represents a unique combination of school + race + sex + disability + lep. To get total enrollment for a school, filter to `race == 99, sex == 99, disability == 99, lep == 99`. To get Black enrollment, filter to `race == 2, sex == 99, disability == 99, lep == 99`.

### Analytical Notes

- `enrollment_crdc` serves as **denominator** for rate calculations
- Match enrollment year with outcome year carefully
- Some variables use different enrollment bases (e.g., discipline uses school enrollment, AP uses high school enrollment)
- The `psenrollment_crdc` column contains many `-2` (not applicable) values for non-preschool schools

### Cross-Tabulations Available

| Level | Available |
|-------|-----------|
| Race only | Yes |
| Sex only | Yes |
| Race × Sex | Yes |
| Disability only | Yes |
| Race × Disability | Limited |
| Sex × Disability | Limited |

---

## Discipline

### What's Collected

School discipline data is the most extensive CRDC category, covering multiple discipline types for both K-12 and preschool students.

### Discipline Categories

| Category | Definition |
|----------|------------|
| **In-school suspension (ISS)** | Student removed from regular class but remains at school |
| **Out-of-school suspension (OSS)** | Student removed from school for disciplinary reasons |
| **One suspension** | Students receiving exactly one suspension |
| **More than one suspension** | Students receiving multiple suspensions |
| **Expulsion with services** | Removed from school, educational services provided |
| **Expulsion without services** | Removed from school, no educational services |
| **Referral to law enforcement** | Any referral to police/law enforcement |
| **School-related arrest** | Arrest occurring on school grounds or for school incident |
| **Corporal punishment** | Physical discipline (permitted in some states) |

### Discipline Variables

| Portal Column Name | Description |
|-------------------|-------------|
| `students_susp_in_sch` | In-school suspension count |
| `students_susp_out_sch_single` | One out-of-school suspension |
| `students_susp_out_sch_multiple` | More than one OSS |
| `expulsions_with_ed_serv` | Expulsion with educational services |
| `expulsions_no_ed_serv` | Expulsion without services |
| `expulsions_zero_tolerance` | Zero-tolerance expulsions |
| `students_referred_law_enforce` | Referrals to law enforcement |
| `students_arrested` | School-related arrests |
| `students_corporal_punish` | Corporal punishment |
| `transfers_alt_sch_disc` | Transfers to alternative school for discipline |

> **Note:** The Portal uses a row-based structure where each row represents a combination of school + race + sex + disability + LEP. Subgroup breakdowns are obtained by filtering on the categorical columns (e.g., `race == 2` for Black students), not by separate variable names. The variable names above are the actual Portal column names as observed in `schools_crdc_discipline_k12` data.

### Disaggregation

| Disaggregation | Available |
|----------------|-----------|
| Race/ethnicity | Yes (7 categories) |
| Sex | Yes |
| Disability | Yes (IDEA students) |
| Race × Sex | Yes |
| Race × Disability | Yes |
| Sex × Disability | Yes |

### Duration Information (2020-21+)

Starting 2020-21, CRDC also collects:
- **Instances of suspension** - Total suspensions (students can have multiple)
- **School days missed** - Total days of instruction missed due to OSS

### Calculating Discipline Rates

```python
import polars as pl

def discipline_rate_by_group(df, discipline_var, enrollment_var='enrollment_crdc', per=100):
    """
    Calculate discipline rate per 100 (or 1000) students.

    Args:
        df: DataFrame filtered to a subgroup (e.g., race==2 for Black)
        discipline_var: Column with discipline counts
        enrollment_var: Column with enrollment counts
        per: Rate multiplier (100 or 1000)

    Returns:
        Rate per specified multiplier
    """
    # Filter out coded missing values
    df_valid = df.filter(pl.col(discipline_var) >= 0)

    total_disciplined = df_valid.select(pl.col(discipline_var).sum()).item()
    total_enrolled = df_valid.select(pl.col(enrollment_var).sum()).item()

    if total_enrolled == 0:
        return None
    return (total_disciplined / total_enrolled) * per

# Example: OSS rate for Black students (race=2 in Portal encoding)
black_students = df.filter(pl.col('race') == 2)
black_oss_rate = discipline_rate_by_group(
    black_students,
    'students_susp_out_sch_single',
    per=100
)
```

### Important Caveats

1. **Definition of "suspension" varies** - Length thresholds differ by district
2. **Informal discipline not captured** - Hallway talks, unofficial removals not counted
3. **Policy changes affect data** - Zero-tolerance policies inflate counts
4. **COVID impact** - 2020-21 shows artificially low discipline due to remote learning
5. **Underreporting likely** - Schools may underreport sensitive discipline data

---

## Restraint and Seclusion

### What's Collected

Data on physical intervention practices with students, particularly those with disabilities.

### Categories

| Category | Definition |
|----------|------------|
| **Mechanical restraint** | Use of device to restrict movement |
| **Physical restraint** | Personal physical contact to restrict movement |
| **Seclusion** | Involuntary confinement in room/area student cannot leave |

### Variables

| Variable | Description |
|----------|-------------|
| `students_restrained_mechanical` | Students subjected to mechanical restraint |
| `students_restrained_physical` | Students subjected to physical restraint |
| `students_secluded` | Students subjected to seclusion |
| `instances_restraint_mechanical` | Total instances of mechanical restraint |
| `instances_restraint_physical` | Total instances of physical restraint |
| `instances_seclusion` | Total instances of seclusion |

### Disaggregation

| Disaggregation | Students | Instances |
|----------------|----------|-----------|
| Total | Yes | Yes |
| Race/ethnicity | Yes | No |
| Sex | Yes | No |
| Disability (IDEA) | Yes | Yes |

### Key Concerns

- **Disproportionate use with students with disabilities** - Most restraint/seclusion involves IDEA students
- **Definition variation** - States and districts define differently
- **Underreporting** - Documentation practices inconsistent
- **Deaths and injuries** - Serious incidents have occurred

### Policy Context

OCR has issued guidance that restraint and seclusion should:
- Only be used when necessary for safety
- Never be used as punishment
- Be documented and reviewed
- Trigger review of student's behavioral plan

---

## Harassment and Bullying

### What's Collected

Reports of harassment or bullying, collected by type of harassment and by whether students were disciplined.

### Harassment Categories

| Category | Definition |
|----------|------------|
| **Based on race, color, national origin** | Targeting student's race, ethnicity, or national origin |
| **Based on sex** | Sexual harassment, gender-based harassment |
| **Based on disability** | Targeting student's disability |
| **Based on sexual orientation** | Targeting perceived sexual orientation |
| **Based on religion** | Targeting student's religion |

### Variables

For each category, CRDC collects:

| Variable Type | Description |
|---------------|-------------|
| `allegations_{type}` | Students alleging harassment |
| `disciplined_{type}` | Students disciplined for harassment |

### Disaggregation

| Variable | Race | Sex | Disability |
|----------|------|-----|------------|
| Allegations | Yes | Yes | Yes |
| Disciplined | Yes | Yes | Yes |

### Important Distinctions

- **Allegation** - Student (or parent) reported harassment
- **Discipline** - Student was disciplined for harassing behavior
- These are **different students** - victims vs. perpetrators

### Analytical Cautions

1. **Reporting vs. occurrence** - Low allegations may mean underreporting, not less harassment
2. **Definition variation** - What constitutes "harassment" varies
3. **Procedure differences** - Schools have different reporting mechanisms
4. **Substantiation not captured** - CRDC doesn't distinguish substantiated vs. unsubstantiated

---

## Chronic Absenteeism

### What's Collected (2015-16+)

Students chronically absent from school, defined as **missing 15 or more school days** during the school year.

### Variable

| Variable | Description |
|----------|-------------|
| `chronic_absent` | Students missing 15+ days |

### Disaggregation

- Race/ethnicity (7 categories)
- Sex
- Disability status (IDEA)
- English learner status

### Key Considerations

1. **Definition is 15+ days** - Some states use different thresholds
2. **Any absence counts** - Excused and unexcused absences
3. **COVID impact** - 2020-21 definition challenged by remote learning
4. **Not in early years** - First collected 2015-16

### Chronic Absenteeism vs. Truancy

| Measure | Definition |
|---------|------------|
| **Chronic absenteeism** | Missing 15+ days (any reason) |
| **Truancy** | Unexcused absences only |

CRDC collects chronic absenteeism, not truancy.

---

## Course Access and Offerings

### What's Collected

Information on courses **offered** by schools and student **enrollment** in specific courses.

### Mathematics Courses

| Course | Description |
|--------|-------------|
| Algebra I | First-year algebra |
| Algebra II | Second-year algebra |
| Geometry | Geometry |
| Advanced mathematics | Courses beyond Algebra II |
| Calculus | Calculus |

### Science Courses

| Course | Description |
|--------|-------------|
| Biology | Biology |
| Chemistry | Chemistry |
| Physics | Physics |

### Computer Science (2017-18+)

| Variable | Description |
|----------|-------------|
| `offers_cs` | School offers any computer science |
| `cs_enrollment` | Students enrolled in CS |

### Disaggregation

| Level | Available |
|-------|-----------|
| School offers course | Yes (school-level indicator) |
| Student enrollment | By race/ethnicity, sex |

### Equity Analysis

```python
import polars as pl

# Example: AP course access disparity
def course_access_analysis(df):
    """
    Analyze whether schools serving more minority students
    are less likely to offer advanced courses.

    Uses Portal integer codes: race=2 (Black), race=3 (Hispanic)
    """
    # Get enrollment totals by race for each school
    # Note: race=99 is total enrollment in Portal data
    totals = df.filter(pl.col('race') == 99).select(['ncessch', 'enrollment_crdc'])
    black = df.filter(pl.col('race') == 2).select(['ncessch', pl.col('enrollment_crdc').alias('enrollment_black')])
    hispanic = df.filter(pl.col('race') == 3).select(['ncessch', pl.col('enrollment_crdc').alias('enrollment_hispanic')])

    school_df = totals.join(black, on='ncessch', how='left').join(hispanic, on='ncessch', how='left')

    school_df = school_df.with_columns(
        ((pl.col('enrollment_black').fill_null(0) + pl.col('enrollment_hispanic').fill_null(0)) /
         pl.col('enrollment_crdc')).alias('pct_minority')
    )

    # Group by minority percentage quartile
    school_df = school_df.with_columns(
        pl.when(pl.col('pct_minority') <= 0.25).then(pl.lit('0-25%'))
        .when(pl.col('pct_minority') <= 0.50).then(pl.lit('25-50%'))
        .when(pl.col('pct_minority') <= 0.75).then(pl.lit('50-75%'))
        .otherwise(pl.lit('75-100%'))
        .alias('minority_quartile')
    )

    return school_df
```

---

## Advanced Courses (AP/IB/Gifted)

### What's Collected

Enrollment in advanced academic programs designed to provide rigorous coursework.

### Categories

| Program | Description |
|---------|-------------|
| **AP (Advanced Placement)** | College-level courses with standardized exams |
| **IB (International Baccalaureate)** | International college-prep curriculum |
| **Gifted and Talented** | Programs for academically gifted students |

### AP Course Categories

| Category | Courses Included |
|----------|-----------------|
| Mathematics | AP Calculus AB/BC, AP Statistics |
| Science | AP Biology, Chemistry, Physics, Environmental Science |
| Computer Science | AP Computer Science A, Principles |
| Other AP | All other AP courses |

### Variables (Portal Column Names)

| Variable | Description |
|----------|-------------|
| `enrl_ap` | Total AP enrollment |
| `enrl_ap_math` | AP math enrollment |
| `enrl_ap_science` | AP science enrollment |
| `enrl_ap_compsci` | AP computer science enrollment |
| `enrl_ap_language` | AP language enrollment |
| `enrl_ap_other` | AP other enrollment |
| `enrl_ib` | Students enrolled in IB program |
| `enrl_gifted_talented` | Students in gifted/talented |

> **Note:** These column names are empirically confirmed from the `schools_crdc_apib_enroll` dataset. Each row represents a combination of school + race + sex + disability + lep. Filter categorical columns to get subgroup-specific enrollments.

### Disaggregation

| Program | Race | Sex | Disability |
|---------|------|-----|------------|
| AP enrollment | Yes | Yes | No |
| IB enrollment | Yes | Yes | No |
| Gifted/Talented | Yes | Yes | Yes |

### Key Equity Concerns

1. **Access disparities** - Not all schools offer AP/IB
2. **Enrollment gaps** - Even when offered, enrollment differs by race/sex
3. **Gifted identification** - Disproportionate identification by race
4. **Resource inequity** - Funding differences for programs

---

## Students with Disabilities

### What's Collected

Information about students served under IDEA and Section 504.

### Categories

| Category | Definition |
|----------|------------|
| **IDEA students** | Students with IEPs under IDEA |
| **Section 504 only** | Students with 504 plans (not IEP) |

### IDEA Disability Categories

| Category | Code |
|----------|------|
| Autism | AUT |
| Deaf-blindness | DB |
| Emotional disturbance | ED |
| Hearing impairment | HI |
| Intellectual disability | ID |
| Multiple disabilities | MD |
| Orthopedic impairment | OI |
| Other health impairment | OHI |
| Specific learning disability | SLD |
| Speech or language impairment | SLI |
| Traumatic brain injury | TBI |
| Visual impairment | VI |
| Developmental delay | DD |

### Educational Settings

| Setting | Description |
|---------|-------------|
| Inside regular class 80%+ | Most time in general education |
| Inside regular class 40-79% | Mixed placement |
| Inside regular class <40% | Mostly separate setting |
| Separate school/facility | Entirely separate placement |

### Variables

| Variable | Description |
|----------|-------------|
| `enrollment_idea` | Total IDEA students |
| `enrollment_504_only` | 504 plan students (not IDEA) |
| `idea_setting_{type}` | IDEA students by educational setting |
| `idea_category_{type}` | IDEA students by disability category |

---

## English Learners

### What's Collected

Information about students classified as English learners (EL) / Limited English Proficient (LEP).

### Variables

| Variable | Description |
|----------|-------------|
| `enrollment_lep` | English learner students |
| `el_programs` | Types of EL programs offered |

### Program Types (collected variably)

- Dual language immersion
- Transitional bilingual
- English as a Second Language (ESL)
- Newcomer programs

### Key Considerations

1. **Definition variation** - EL classification criteria vary by state
2. **Exit criteria** - When students are reclassified varies
3. **Title VI implications** - Failure to serve ELs may violate civil rights

---

## Preschool

### What's Collected

Enrollment and discipline data for preschool (ages 3-5, pre-kindergarten).

### Preschool Discipline Variables

| Variable | Description |
|----------|-------------|
| `pk_oss_one` | Preschoolers with one OSS |
| `pk_oss_more` | Preschoolers with multiple OSS |
| `pk_expulsion` | Preschoolers expelled |

### Disaggregation

- Race/ethnicity
- Sex
- Disability status

### Major Concern

**Preschool suspension is a significant civil rights issue**:
- Very young children suspended at high rates
- Significant racial disparities
- Questions about developmental appropriateness

### Research Finding

The 2013-14 CRDC revealed that Black children represent:
- 18% of preschool enrollment
- 48% of preschool children receiving multiple out-of-school suspensions

---

## Retention

### What's Collected

Students retained in grade (held back to repeat a grade).

### Variable

| Variable | Description |
|----------|-------------|
| `retained` | Students retained in grade |

### Disaggregation

- Race/ethnicity
- Sex
- Disability status (IDEA)

### Analytical Note

Retention rates vary significantly by:
- State policy (social promotion policies)
- Grade level (transition grades often higher)
- Local policy changes

---

## Staffing

### What's Collected

Information about school staff, including teachers, counselors, and support personnel.

### Staff Categories

| Category | Description |
|----------|-------------|
| **Teachers** | Classroom teachers |
| **Counselors** | School counselors |
| **Psychologists** | School psychologists |
| **Social workers** | School social workers |
| **Nurses** | School nurses |
| **Security/SROs** | Security guards, School Resource Officers |

### Teacher Variables

| Variable | Description |
|----------|-------------|
| `teachers_fte` | Full-time equivalent teachers |
| `teachers_first_year` | First-year teachers |
| `teachers_second_year` | Second-year teachers |
| `teachers_certified` | Fully certified teachers |
| `teachers_not_certified` | Teachers not fully certified |

### Teacher Experience Variables

| Variable | Description |
|----------|-------------|
| `teachers_chronic_absent` | Teachers chronically absent (15+ days) |
| `teachers_salary_avg` | Average teacher salary |

### Support Staff

| Variable | Description |
|----------|-------------|
| `counselors_fte` | School counselor FTE |
| `psychologists_fte` | School psychologist FTE |
| `social_workers_fte` | School social worker FTE |
| `nurses_fte` | School nurse FTE |

### Equity Analysis

Staffing data enables analysis of:
- Teacher experience gaps by school demographics
- Counselor ratios by school characteristics
- SRO presence and discipline correlation

---

## School Offenses

### What's Collected

Incidents occurring at school, regardless of whether they resulted in discipline.

### Offense Categories

| Category | Description |
|----------|-------------|
| **Violent incidents without weapons** | Fights, assaults without weapons |
| **Violent incidents with weapons** | Assaults involving weapons |
| **Firearm possession** | Possession of firearm at school |
| **Other weapons possession** | Possession of knife, other weapon |
| **Drug-related incidents** | Drug possession, distribution, use |
| **Alcohol-related incidents** | Alcohol possession or use |

### Variables

| Variable | Description |
|----------|-------------|
| `offenses_violent_no_weapon` | Violent incidents without weapons |
| `offenses_violent_weapon` | Violent incidents with weapons |
| `offenses_firearm` | Firearm incidents |
| `offenses_weapon_other` | Other weapon incidents |
| `offenses_drug` | Drug incidents |
| `offenses_alcohol` | Alcohol incidents |

### Distinctions

- **Offense** - Incident occurred
- **Discipline** - Student was disciplined (different data element)
- **Referral/arrest** - Law enforcement involved (different data element)

---

## School Characteristics

### What's Collected

Basic information about school characteristics.

### Variables

| Variable | Description |
|----------|-------------|
| `grades_offered` | Grade levels served (PS-12) |
| `magnet_school` | Magnet school indicator |
| `charter_school` | Charter school indicator |
| `alternative_school` | Alternative school indicator |
| `virtual_school` | Virtual/online school |
| `single_sex_school` | Single-sex school |
| `single_sex_classes` | Offers single-sex classes |

### Note on Linking

School characteristics should be linked from **CCD** (Common Core of Data) for:
- Urbanicity
- School level
- Total enrollment
- Free/reduced lunch eligibility
- Location (state, district)

---

## Data Element Changes Over Time

| Data Element | First Collected | Notes |
|--------------|-----------------|-------|
| Basic discipline | 2011 (modern) | |
| Restraint/seclusion | 2011 | |
| Chronic absenteeism | 2015 | |
| Preschool discipline | 2011 | Expanded 2015 |
| Sexual harassment | 2011 | |
| Computer science | 2017 | |
| Instances of suspension | 2020 | |
| School days missed | 2020 | |
| COVID-related items | 2020 | Temporary |

See `./historical-changes.md` for detailed year-by-year changes.
