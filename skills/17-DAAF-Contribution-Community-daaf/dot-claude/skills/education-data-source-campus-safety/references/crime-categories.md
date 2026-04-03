# Crime Categories and Definitions

## Overview

The Clery Act requires reporting of specific categories of crimes. These categories and definitions are based on the FBI's Uniform Crime Reporting (UCR) program but have some Clery-specific adaptations.

## Primary Criminal Offenses

### Criminal Homicide

#### Murder and Non-negligent Manslaughter

**Definition**: The willful (non-negligent) killing of one human being by another.

**Includes**:
- Deaths caused by injuries received in a fight, argument, quarrel, assault, or commission of a crime
- Willful killings as a result of brawls, arguments, or domestic disputes

**Excludes**:
- Traffic fatalities
- Suicides
- Accidental deaths
- Justifiable homicides (killing of a felon by a law enforcement officer in line of duty; killing of a felon during commission of a felony by a private citizen)

#### Manslaughter by Negligence

**Definition**: The killing of another person through gross negligence.

**Includes**:
- Deaths caused by the gross negligence of another person
- Deaths resulting from reckless disregard for safety

**Excludes**:
- Deaths due to the victim's own negligence
- Accidental deaths not resulting from gross negligence
- Traffic fatalities

### Sex Offenses

Sex offense definitions were significantly updated in 2014 to align with the FBI's updated UCR definitions.

#### Rape

**Definition**: Penetration, no matter how slight, of the vagina or anus with any body part or object, or oral penetration by a sex organ of another person, without the consent of the victim.

**Key Elements**:
- Includes both male and female victims
- Includes penetration by any body part or object
- "Without consent" includes cases where victim is incapable of giving consent due to:
  - Age (below age of consent)
  - Temporary or permanent mental or physical incapacity
  - Intoxication

**Note**: Prior to 2014, rape was defined differently (forcible sexual intercourse, female victims only). This definitional change affects trend analysis.

#### Fondling

**Definition**: The touching of the private body parts of another person for the purpose of sexual gratification, without the consent of the victim, including instances where the victim is incapable of giving consent because of age or temporary or permanent mental incapacity.

**Key Elements**:
- Purpose must be sexual gratification
- Includes touching over clothing
- Consent incapacity includes intoxication

#### Incest

**Definition**: Sexual intercourse between persons who are related to each other within the degrees wherein marriage is prohibited by law.

**Key Elements**:
- Specific prohibited relationships vary by state
- Typically includes parent-child, siblings, grandparent-grandchild
- May include step-relationships depending on state law

#### Statutory Rape

**Definition**: Sexual intercourse with a person who is under the statutory age of consent.

**Key Elements**:
- Age of consent varies by state (typically 16-18)
- Consent is legally irrelevant due to victim's age
- Some states have "Romeo and Juliet" exceptions for close-in-age relationships

### Robbery

**Definition**: The taking or attempting to take anything of value from the care, custody, or control of a person or persons by force or threat of force or violence and/or by putting the victim in fear.

**Key Elements**:
- Must involve force, threat, or fear
- Victim must be present
- Distinguishes from theft (which lacks force/threat)

**Includes**:
- Strong-arm robbery (no weapon)
- Armed robbery (with weapon)
- Carjacking (if involves force/threat)

### Aggravated Assault

**Definition**: An unlawful attack by one person upon another for the purpose of inflicting severe or aggravated bodily injury. This type of assault is usually accompanied by the use of a weapon or by means likely to produce death or great bodily harm.

**Key Elements**:
- Intent to inflict severe injury
- Weapon use OR
- Means likely to cause serious harm

**Includes**:
- Assaults with weapons (gun, knife, blunt object)
- Assaults resulting in serious injury
- Attempted murder

**Excludes**:
- Simple assault (no weapon, minor injury)—unless a hate crime
- Intimidation—unless a hate crime

### Burglary

**Definition**: The unlawful entry of a structure to commit a felony or a theft.

**Key Elements**:
- **Unlawful entry**: Force is not required; entry through unlocked door counts
- **Structure**: Building, vehicle adapted as living quarters, etc.
- **Intent**: Must intend to commit felony or theft at time of entry

**Three Sub-categories**:
1. **Forcible entry**: Use of force to gain entry
2. **Unlawful entry - no force**: Entry through unlocked opening
3. **Attempted forcible entry**: Unsuccessful forced entry attempt

**Includes**:
- Breaking into residence hall room
- Breaking into office
- Entering unlocked space with intent to steal

**Excludes**:
- Shoplifting (no unlawful entry)
- Theft from open areas
- Trespass without intent to commit crime

### Motor Vehicle Theft

**Definition**: The theft or attempted theft of a motor vehicle.

**Motor Vehicle**: Self-propelled vehicle that runs on land surface and not on rails.

**Includes**:
- Automobiles
- Trucks
- Buses
- Motorcycles
- Motor scooters
- Golf carts
- All-terrain vehicles

**Excludes**:
- Farm equipment
- Construction equipment
- Bicycles
- Watercraft
- Aircraft

**Note**: Temporary use (joyriding) counts if taken without owner's permission.

### Arson

**Definition**: Any willful or malicious burning or attempt to burn, with or without intent to defraud, a dwelling house, public building, motor vehicle or aircraft, personal property of another, etc.

**Key Elements**:
- **Willful or malicious**: Must be intentional
- **Investigation required**: Only fires determined through investigation to be intentionally set are counted
- **Arson is the only Clery crime requiring investigation to classify**

**Includes**:
- Burning of buildings
- Burning of vehicles
- Burning of personal property
- Attempted burning (if willful)

**Excludes**:
- Accidental fires
- Fires of undetermined origin (unless evidence of intent)
- Natural fires

## Hierarchy Rule

### General Rule

When multiple offenses occur in a single incident, generally only the most serious offense is counted in Clery statistics. This is called the "hierarchy rule."

**Hierarchy (most to least serious)**:
1. Murder and Non-negligent Manslaughter
2. Manslaughter by Negligence
3. Rape
4. Fondling
5. Incest
6. Statutory Rape
7. Robbery
8. Aggravated Assault
9. Burglary
10. Motor Vehicle Theft

### Exceptions to Hierarchy Rule

**Always counted separately (no hierarchy)**:
- Arson
- Hate crimes
- VAWA offenses (dating violence, domestic violence, stalking)
- Weapons, drug, and liquor law violations

**Examples**:
- Robbery + Arson = Both counted
- Rape + Arson = Both counted
- Murder + Rape = Only murder counted (hierarchy applies)
- Robbery during Burglary = Only robbery counted (hierarchy applies)

## Classification Rules

### Attempted vs. Completed

- **General rule**: Attempted crimes are classified the same as completed crimes
- **Exception**: Attempted murder is classified as aggravated assault

### Multiple Victims

- Count one offense per victim for crimes against persons
- Count one offense per distinct operation for crimes against property

**Examples**:
- One assault against three people = 3 aggravated assaults
- One robbery of a group = 1 robbery
- Three cars stolen from one parking lot in one incident = 1 motor vehicle theft

### Ongoing Crimes

- **Stalking**: Counted once per victim, regardless of number of acts
- **Series of related incidents**: May be counted separately or together depending on circumstances

## Data Reporting Variables

### Common Variable Names in CSS Data

| Variable | Description |
|----------|-------------|
| `murder` | Murder and non-negligent manslaughter |
| `neg_manslaughter` | Manslaughter by negligence |
| `rape` | Rape (2014+ definition) |
| `fondling` | Fondling |
| `incest` | Incest |
| `statutory_rape` | Statutory rape |
| `robbery` | Robbery |
| `aggravated_assault` | Aggravated assault |
| `burglary` | Burglary |
| `motor_vehicle_theft` | Motor vehicle theft |
| `arson` | Arson |

### Location Suffixes

Variables may have suffixes indicating geographic category:
- `_oncampus`: On-campus total
- `_residencehall` or `_studenthousing`: On-campus student housing
- `_noncampus`: Noncampus property
- `_publicproperty`: Public property

## Historical Changes

### 2014 Changes (VAWA Implementation)

**Sex Offense Definitions**:
- Rape definition expanded significantly
- "Forcible" and "non-forcible" categories replaced
- Added fondling, incest, statutory rape as separate categories
- Previous categories: Forcible sex offenses (rape, sodomy, sexual assault with object, fondling) and Non-forcible (incest, statutory rape)

**Impact on Trend Analysis**:
- Pre-2014 and post-2014 sex offense data are not directly comparable
- Expanded rape definition generally resulted in higher rape counts
- Reclassification of fondling may affect counts

### 2008 Changes (HEOA)

- Added fire safety reporting
- Enhanced emergency notification requirements
- No major changes to crime categories

## Interpreting Crime Statistics

### What Counts Are NOT

- **Not comprehensive crime data**: Only Clery-defined crimes in Clery geography
- **Not arrest statistics**: Crimes reported, not arrests made
- **Not conviction data**: Does not indicate case outcomes
- **Not all campus crime**: Only crimes reported to CSAs or law enforcement

### What Statistics Represent

- Crimes **reported** to Campus Security Authorities or local law enforcement
- That occurred within **Clery geography**
- During the **calendar year**
- Classified according to **Clery definitions** (not state law)
