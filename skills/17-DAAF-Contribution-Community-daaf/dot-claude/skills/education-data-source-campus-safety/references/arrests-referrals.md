# Arrests and Disciplinary Referrals

## Overview

In addition to criminal offenses, the Clery Act requires institutions to report statistics for arrests and disciplinary referrals related to three categories of violations:

1. Liquor law violations
2. Drug law violations  
3. Weapons (carrying, possessing, etc.) violations

## Key Distinction: Arrests vs. Referrals

### Arrests

**Definition**: Persons processed by arrest, citation, or summons.

**Key Points**:
- Actual arrest by law enforcement
- Citation issued by law enforcement
- Summons for the violation
- Includes both campus and local law enforcement

### Disciplinary Referrals

**Definition**: The referral of any person to any official who initiates a disciplinary action of which a record is established and which may result in the imposition of a sanction.

**Key Points**:
- Person referred to campus disciplinary process
- A record of the referral is created
- Referral could result in sanction
- Does not require actual sanction to be imposed
- Does not include counseling referrals without disciplinary record

### No Double-Counting

**Important**: If a person is both arrested AND referred to campus discipline for the same incident:
- Count the arrest only
- Do NOT also count as a disciplinary referral

**Example**: Student arrested for marijuana possession AND referred to Dean of Students
- Count: 1 arrest for drug law violation
- Do NOT count: 1 disciplinary referral

## Liquor Law Violations

### Definition

The violation of laws or ordinances prohibiting the manufacture, sale, transporting, furnishing, possessing of intoxicating liquor; maintaining unlawful drinking places; bootlegging; operating a still; furnishing liquor to a minor or intemperate person; using a vehicle for illegal transportation of liquor; drinking on a train or public conveyance; and all attempts to commit any of the aforementioned.

### What Is Included

**Reportable Violations**:
- Underage possession or consumption
- Providing alcohol to minors
- Open container violations
- Public intoxication (where prohibited by law)
- Fake ID use (to purchase alcohol)
- Unlicensed sale of alcohol
- Bootlegging

### What Is NOT Included

**Not Reportable**:
- DUI/DWI (separate traffic violation)
- Drunk and disorderly conduct without liquor law violation
- Violations of institutional alcohol policies that are not law violations

### Examples

**Arrest Example**: Campus police arrest a 19-year-old student for underage possession of alcohol → Count 1 liquor law arrest

**Referral Example**: RA finds alcohol in room of 20-year-old student, refers to housing office which opens disciplinary case → Count 1 liquor law referral (if no arrest)

## Drug Law Violations

### Definition

Violations of state and local laws relating to the unlawful possession, sale, use, growing, manufacturing, and making of narcotic drugs. The relevant substances include opium or cocaine and their derivatives (morphine, heroin, codeine); marijuana; synthetic narcotics (Demerol, methadone); and dangerous non-narcotic drugs (barbiturates, Benzedrine).

### What Is Included

**Reportable Violations**:
- Possession of illegal drugs
- Sale or distribution of illegal drugs
- Manufacturing of illegal drugs
- Possession of drug paraphernalia (where illegal)
- Possession of controlled substances without prescription
- Marijuana violations (even in states with legalization, federal law applies on campus)

### State Marijuana Laws

**Important Consideration**:
- Marijuana remains illegal under federal law
- Institutions receiving Title IV funds must comply with Drug-Free Schools and Communities Act
- Marijuana possession/use on campus typically remains a violation regardless of state law
- Institutions should report violations consistent with their policies

### What Is NOT Included

**Not Reportable**:
- Drug under the influence (without possession/sale/manufacturing)
- Prescription medication properly possessed

### Examples

**Arrest Example**: Local police arrest student for marijuana possession → Count 1 drug law arrest

**Referral Example**: Campus security finds drug paraphernalia in dorm room, student referred to conduct office → Count 1 drug law referral (if no arrest)

## Weapons Law Violations

### Definition

The violation of laws or ordinances dealing with weapon offenses, regulatory in nature, such as: manufacture, sale, or possession of deadly weapons; carrying deadly weapons, concealed or openly; furnishing deadly weapons to minors; aliens possessing deadly weapons; and all attempts to commit any of the aforementioned.

### What Is Included

**Reportable Violations**:
- Illegal possession of firearms
- Carrying concealed weapons (where prohibited)
- Possession of prohibited weapons (switchblades, brass knuckles, etc.)
- Furnishing weapons to prohibited persons
- Possession of weapons on campus (where prohibited by policy/law)
- BB guns, pellet guns, air rifles (depending on jurisdiction)

### What Is NOT Included

**Not Reportable**:
- Legal possession of weapons (licensed concealed carry where permitted)
- Weapons used in commission of another crime (counted under that crime)
- Weapons possessed by law enforcement

### Campus Weapons Policies

Many campuses prohibit weapons even where state law would permit:
- Policy violations may result in disciplinary referrals
- Check whether violation constitutes a legal violation or policy-only violation
- Generally, only violations of law (not just policy) are counted

### Examples

**Arrest Example**: Student arrested for carrying concealed handgun without permit → Count 1 weapons arrest

**Referral Example**: RA discovers prohibited knife in student's room, refers to conduct office → Count 1 weapons referral (if weapon is prohibited by law, not just policy)

## Reporting Requirements

### Statistical Reporting

Arrests and referrals are reported:
- By calendar year
- By geographic category (on-campus, residence halls, noncampus, public property)
- Separately for arrests and referrals

### Data Structure

| Category | Arrests | Referrals |
|----------|---------|-----------|
| Liquor law violations | Reported | Reported |
| Drug law violations | Reported | Reported |
| Weapons violations | Reported | Reported |

### By Location

Statistics are reported for all four Clery geographic categories:
- On-campus (total)
- On-campus student housing (subset)
- Noncampus
- Public property

## Common Variable Names

| Variable | Description |
|----------|-------------|
| `liquor_arrests` | Arrests for liquor law violations |
| `liquor_referrals` | Disciplinary referrals for liquor law violations |
| `drug_arrests` | Arrests for drug law violations |
| `drug_referrals` | Disciplinary referrals for drug law violations |
| `weapons_arrests` | Arrests for weapons law violations |
| `weapons_referrals` | Disciplinary referrals for weapons law violations |

With location suffixes:
- `_oncampus`
- `_residencehall` or `_studenthousing`
- `_noncampus`
- `_publicproperty`

## Hierarchy Rule

**Not Applicable**: Arrests and referrals are NOT subject to the hierarchy rule.

- Always count separately from criminal offenses
- If a drug arrest accompanies a burglary: count both the burglary AND the drug arrest
- If a weapons violation accompanies an assault: count both the assault AND the weapons arrest/referral

## Interpretation Considerations

### What Numbers Mean

**High Numbers May Indicate**:
- Active enforcement
- Effective detection systems
- Campus culture issues
- Large student population
- Urban environment
- Active party scene

**Low Numbers May Indicate**:
- Less active enforcement
- Fewer violations
- Different campus culture
- Smaller student population
- Different detection approaches

### Comparing Institutions

**Factors Affecting Numbers**:
- Campus size and enrollment
- Residential vs. commuter population
- Urban vs. rural location
- Enforcement philosophy
- State/local laws
- Campus alcohol/drug policies
- Greek life presence
- Athletic programs

**Better Comparisons**:
- Per capita rates
- Similar institution types
- Similar sizes
- Similar settings

### Referrals vs. Enforcement Culture

**Higher Referral Numbers May Mean**:
- Strong reporting culture
- Active RA/staff training
- Clear reporting procedures
- Effective residential life programs

**Not Necessarily**:
- More actual violations
- Less safe campus
- Worse student behavior

### Trend Analysis Caveats

**Changes Over Time May Reflect**:
- Policy changes
- Enforcement philosophy changes
- State law changes
- Staffing changes
- Training improvements
- Reporting procedure changes

**Not Just**:
- Changes in actual violation rates

## Relationship to Drug-Free Schools Act

### Drug-Free Schools and Communities Act (DFSCA)

Separate federal requirement that institutions must:
- Have drug and alcohol prevention programs
- Conduct biennial reviews of programs
- Distribute annual notification of drug/alcohol policies

### Connection to Clery

- DFSCA compliance is separate from Clery
- Both address substance abuse on campus
- Clery statistics inform DFSCA program assessment
- Enforcement under both coordinated by Department of Education
