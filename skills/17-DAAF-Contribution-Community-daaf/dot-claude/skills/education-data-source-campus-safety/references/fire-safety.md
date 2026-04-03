# Fire Safety: Statistics and Systems

## Background

The Higher Education Opportunity Act (HEOA) of 2008 added fire safety reporting requirements to the Clery Act through the Campus Fire Safety Right-to-Know Act. These requirements recognize that fires in campus housing pose significant risks to students.

## Applicability

### Who Must Report

Fire safety requirements apply to:
- All institutions that participate in Title IV federal student aid programs
- **Only for institutions with on-campus student housing facilities**

**Note**: Institutions without on-campus student housing are exempt from fire safety reporting requirements.

### What Facilities Are Covered

**On-Campus Student Housing Facilities**:
- Same definition as Clery Act on-campus student housing
- Owned or controlled by the institution
- Within the reasonably contiguous campus geographic area
- Used for student housing

**Covered Facilities Include**:
- Traditional residence halls
- Campus apartments
- Fraternity/sorority houses (if owned/controlled by institution)
- Graduate housing
- Family housing

**NOT Covered**:
- Off-campus apartments
- Privately owned housing
- Noncampus housing facilities
- Academic buildings (unless also housing)

## Definition of Fire

**Fire**: Any instance of open flame or other burning in a place not intended to contain the burning or in an uncontrolled manner.

**Key Points**:
- Any fire, regardless of cause or size
- Regardless of whether injury or damage occurs
- Includes contained fires that spread
- Includes fires extinguished quickly

**Examples**:
- Cooking fires
- Candle fires
- Smoking-related fires
- Electrical fires
- Arson
- Accidental fires

## Annual Fire Safety Report

### Required Content

Institutions must publish an Annual Fire Safety Report containing:

**1. Fire Statistics (Previous 3 Calendar Years)**:

For each on-campus student housing facility:
- Total number of fires
- Cause of each fire
- Number of deaths related to fire
- Number of injuries related to fire requiring medical treatment
- Value of property damage

**2. Fire Safety Systems Description**:

For each on-campus student housing facility:
- Fire alarm systems
- Automatic sprinkler systems
- Smoke detection systems
- Fire extinguisher devices
- Fire-rated corridors/stairwells
- Evacuation plans/placards

**3. Number of Fire Drills**:
- Number of fire drills held during the previous calendar year

**4. Policies and Rules**:

- Portable electrical appliances
- Smoking and open flames
- Evacuation procedures in case of fire

**5. Education and Training Programs**:

- Fire safety education programs for students and employees
- Titles of persons to whom fires should be reported

**6. Future Improvements**:

- Plans for future fire safety improvements (if applicable)

### Publication Requirements

**Deadline**: Published annually as part of or alongside the Annual Security Report

**Distribution**: Same requirements as Annual Security Report
- Notice to all current students and employees
- Available to prospective students and employees
- Publicly accessible

## Fire Statistics Reporting

### Required Data Elements

For each fire in each on-campus student housing facility:

| Element | Description |
|---------|-------------|
| Fire number | Sequential number for tracking |
| Date/time | When fire occurred |
| Cause | Category of fire cause |
| Injuries | Number requiring medical treatment |
| Deaths | Fire-related fatalities |
| Property damage | Estimated value of damage |

### Fire Cause Categories

Fires must be categorized by cause:

| Category | Definition |
|----------|------------|
| Unintentional | Accidental fire; includes cooking, smoking, electrical, heating, other unintentional causes |
| Intentional | Deliberately set; includes arson |
| Undetermined | Cause cannot be determined after investigation |

**Sub-Categories for Unintentional**:
- Cooking-related
- Smoking-related
- Electrical-related
- Heating equipment-related
- Open flames
- Other unintentional

### Injuries

**Reportable Injuries**:
- Any injury that required treatment at a medical facility
- Includes treatment at campus health center
- Includes hospital emergency room treatment
- Includes being admitted to hospital

**Not Counted**:
- Minor injuries treated on-scene
- Injuries not requiring medical facility treatment

### Deaths

**Reportable Deaths**:
- Any death resulting from a fire
- Deaths occurring at the scene
- Deaths occurring later as a result of fire injuries

### Property Damage

**How to Estimate**:
- Total value of damage caused by fire
- Includes structural damage
- Includes damage to contents
- Includes damage to personal property

**Reporting**:
- Report in dollar value ranges or exact amounts
- Follows Department of Education reporting format

## Fire Log

### Requirement

Institutions with on-campus student housing must maintain a fire log similar to the crime log.

### Required Information

| Element | Description |
|---------|-------------|
| Nature of fire | Type/description |
| Date fire was reported | When reported to institution |
| Date and time fire occurred | When it happened |
| General location | Building/address |

### Accessibility

**Current Entries (60 days)**:
- Open to public inspection during normal business hours

**Older Entries**:
- Available within 2 business days of request

**Entry Deadline**:
- Entries must be made within 2 business days of the report

## Fire Safety Systems

### Types of Systems Reported

**Fire Alarm Systems**:
- Pull stations
- Audio/visual alarms
- Connection to monitoring service

**Automatic Fire Suppression**:
- Full sprinkler systems
- Partial sprinkler systems
- Sprinkler coverage (rooms, common areas, hallways)

**Smoke Detection**:
- Hardwired smoke detectors
- Battery-operated smoke detectors
- Location (each room, hallways, common areas)

**Fire Extinguishing Equipment**:
- Portable fire extinguishers
- Standpipes

**Other Fire Safety Features**:
- Fire-rated corridors
- Fire-rated stairwells
- Emergency lighting
- Evacuation maps/plans

### Reporting Format

For each facility, institutions report presence/absence and description of:

| System | Typical Reporting |
|--------|------------------|
| Fire alarm | Yes/No, type, monitoring |
| Sprinklers | Full/Partial/None, coverage areas |
| Smoke detectors | Type, location, coverage |
| Extinguishers | Yes/No, number |
| Evacuation plan | Yes/No, posted |
| Fire drills | Number conducted per year |

## Policy Requirements

### Portable Electrical Appliances

Institution must have and disclose policies regarding:
- Prohibited appliances (hot plates, space heaters, etc.)
- Permitted appliances
- Power strip and extension cord usage
- Inspection procedures

### Smoking and Open Flames

Institution must have and disclose policies regarding:
- Smoking in residential facilities
- Candles and incense
- Other open flame sources
- Enforcement procedures

### Evacuation Procedures

Institution must describe:
- Evacuation procedures
- Emergency exits
- Assembly points
- Procedures for persons with disabilities
- Re-entry procedures

## Data Variables

### Common Variable Names in CSS Fire Data

| Variable | Description |
|----------|-------------|
| `fires_total` | Total number of fires |
| `fire_injuries` | Number of fire-related injuries |
| `fire_deaths` | Number of fire-related deaths |
| `fire_damage` | Property damage value/range |

### Facility-Level Variables

Fire data is reported at the facility level:
- Building name
- Building address
- Fire safety systems present
- Fires for each year

## Relationship to Arson

### Distinction

**Fire Statistics**: All fires, regardless of cause (accidental, intentional, undetermined)

**Arson (Crime Statistics)**: Only intentionally set fires

**Overlap**: Arson fires appear in both:
- Fire statistics (as "intentional" cause)
- Crime statistics (as arson)

### Counting

A fire that is determined to be arson:
- Counts once in fire statistics
- Counts once in arson crime statistics
- These are separate reporting requirements

## Interpretation Considerations

### Fire Statistics Context

**What Fire Numbers Mean**:
- Reported fires in on-campus housing
- Does not indicate fire risk level
- Does not account for building age, population, or size

**Factors Affecting Fire Numbers**:
- Number and size of housing facilities
- Number of residents
- Age and construction type of buildings
- Presence of kitchens (cooking fires)
- Smoking policies
- Fire prevention programs

### Comparing Institutions

**Caution in Comparisons**:
- Different numbers of housing facilities
- Different facility sizes
- Different student populations
- Different building ages
- Different cooking arrangements

**Better Metrics**:
- Fires per resident
- Fires per building
- Fires per square foot
- Controlling for facility characteristics

### Trend Analysis

**Year-to-Year Variation**:
- Small absolute numbers
- Single incidents affect statistics significantly
- May not indicate meaningful trends

**Longer-Term Trends**:
- Look at 5+ year patterns
- Consider changes in housing stock
- Consider policy changes
