# Hate Crimes: Bias Categories and Classification

> **CRITICAL: Portal Integer Encoding**
>
> The Education Data Portal uses **integer codes** for bias categories and crime types:
>
> | Code | Bias Category | Code | Crime Type |
> |------|---------------|------|------------|
> | `1` | Race | `12` | Larceny-Theft |
> | `2` | Religion | `13` | Simple Assault |
> | `3` | Sexual Orientation | `14` | Intimidation |
> | `4` | Gender | `15` | Vandalism |
> | `99` | Total | `99` | Total |
>
> See `variable-definitions.md` for complete mappings. Verify codes against the live codebook.
> Use `get_codebook_url("csafety/codebook_colleges_csafety_hate_crimes")` from `fetch-patterns.md`.

## Definition

A hate crime is a criminal offense that manifests evidence that the victim was intentionally selected because of the perpetrator's bias against the victim.

**Key Elements**:
- Must be a criminal offense (one of the specified Clery crimes)
- Must show evidence of bias motivation
- Bias must be against the victim (not general bias)
- Selection must be intentional

## Bias Categories (Portal Integer Encoding)

Under the Clery Act, institutions report hate crimes motivated by bias based on eight categories:

### Code 1: Race

**Definition**: A preformed negative attitude toward a group of persons who possess common physical characteristics genetically transmitted by descent and heredity which distinguish them as a distinct division of humankind.

**Examples**: Anti-Black, Anti-White, Anti-Asian, Anti-Hispanic (when based on race rather than ethnicity), Anti-American Indian/Alaska Native, Anti-Native Hawaiian/Pacific Islander, Anti-Multiple Races

### Code 2: Religion

**Definition**: A preformed negative opinion or attitude toward a group of persons who share the same religious beliefs regarding the origin and purpose of the universe and the existence or nonexistence of a supreme being.

**Examples**: Anti-Jewish, Anti-Islamic (Muslim), Anti-Catholic, Anti-Protestant, Anti-Atheist/Agnostic, Anti-Buddhist, Anti-Hindu, Anti-Sikh, Anti-Other Religion

### Code 3: Sexual Orientation

**Definition**: A preformed negative opinion or attitude toward a group of persons based on their actual or perceived sexual orientation.

**Sexual orientation**: Physical, romantic, or emotional attraction to members of the same or different sex.

**Examples**: Anti-Gay (Male), Anti-Lesbian, Anti-Bisexual, Anti-Heterosexual, Anti-LGBTQ+ (general)

### Code 4: Gender

**Definition**: A preformed negative opinion or attitude toward a person or group of persons based on their actual or perceived gender.

**Gender**: The actual or perceived sex of a person, including the cultural expectations associated with a person's sex.

**Note**: This is distinct from gender identity.

### Code 5: Gender Identity

**Definition**: A preformed negative opinion or attitude toward a person or group of persons based on their actual or perceived gender identity.

**Gender identity**: The gender-related characteristics or manner in which individuals identify themselves, regardless of their actual sex at birth.

**Examples**: Anti-Transgender, Anti-Gender Non-Conforming

**Note**: Added as a bias category with 2013 VAWA amendments (applicable to 2014+ data).

### Code 6: Ethnicity

**Definition**: A preformed negative opinion or attitude toward a group of people whose members identify with each other, through a common heritage, often consisting of a common language, common culture, and/or ideology that stresses common ancestry.

**Examples**: Anti-Hispanic/Latino, Anti-Arab (when based on ethnicity), Anti-Other Ethnicity

**Note**: Ethnicity was separated from National Origin with 2013 VAWA amendments.

### Code 7: National Origin

**Definition**: A preformed negative opinion or attitude toward a group of people based on their actual or perceived country of birth.

**Examples**: Anti-Mexican National, Anti-Chinese National, Anti-Iranian National

**Note**: National Origin was separated from Ethnicity with 2013 VAWA amendments.

### Code 8: Disability

**Definition**: A preformed negative opinion or attitude toward a group of persons based on their physical or mental impairments, whether such disability is temporary or permanent, congenital or acquired by heredity, accident, injury, advanced age, or illness.

**Examples**: Anti-Physical Disability, Anti-Mental Disability

### Code 9: Unknown/Other

Bias category not specified or does not fit standard categories.

### Code 99: Total

All bias categories combined. Use for aggregate counts across all bias types.

## Hate Crime Offenses

### Primary Clery Crimes

All primary Clery crimes can be classified as hate crimes if bias-motivated:
- Murder and Non-negligent Manslaughter
- Manslaughter by Negligence
- Rape
- Fondling
- Incest
- Statutory Rape
- Robbery
- Aggravated Assault
- Burglary
- Motor Vehicle Theft
- Arson

### Additional Hate Crime-Only Offenses

Four additional offenses are reported **only** when motivated by bias:

#### Larceny-Theft

**Definition**: The unlawful taking, carrying, leading, or riding away of property from the possession or constructive possession of another.

**Includes**:
- Pocket-picking
- Purse-snatching (without force)
- Shoplifting
- Theft from buildings
- Theft from vehicles
- Bicycle theft
- All other larceny

**Note**: Without bias motivation, larceny is NOT a Clery-reportable crime.

#### Simple Assault

**Definition**: An unlawful physical attack by one person upon another where neither the offender displays a weapon, nor the victim suffers obvious severe or aggravated bodily injury involving apparent broken bones, loss of teeth, possible internal injury, severe laceration, or loss of consciousness.

**Distinction from Aggravated Assault**: No weapon, no serious injury

**Note**: Without bias motivation, simple assault is NOT a Clery-reportable crime.

#### Intimidation

**Definition**: To unlawfully place another person in reasonable fear of bodily harm through the use of threatening words and/or other conduct, but without displaying a weapon or subjecting the victim to actual physical attack.

**Examples**:
- Verbal threats
- Written threats
- Threatening gestures
- Following behavior intended to threaten
- Online/cyber intimidation

**Note**: Without bias motivation, intimidation is NOT a Clery-reportable crime.

#### Destruction/Damage/Vandalism of Property

**Definition**: To willfully or maliciously destroy, damage, deface, or otherwise injure real or personal property without the consent of the owner or the person having custody or control of it.

**Examples**:
- Graffiti with bias messages
- Defacing property with hate symbols
- Destruction of religious objects
- Vandalism targeting specific groups

**Note**: Without bias motivation, vandalism is NOT a Clery-reportable crime (unless arson).

## Classification Process

### Determining Bias Motivation

**Evidence of Bias May Include**:
- Oral comments, written statements, or gestures made by the offender
- Drawings, markings, symbols, or graffiti
- Hate group involvement
- Previous bias incidents
- Victim's perception
- Offender's admission
- Community context
- Pattern of similar incidents

**Factors to Consider**:
1. Was the victim a member of a group identifiable by bias category?
2. Were bias indicators present at the scene?
3. Did the offender perceive the victim as belonging to an identifiable group?
4. Was there any connection to prior bias incidents?
5. Was the incident proximate to a date of significance to bias groups?

### Two-Pronged Test

1. **Was a Clery crime committed?** (or hate crime-only offense)
2. **Was there evidence that the victim was selected due to bias?**

If both are yes, it is reported as a hate crime.

### Uncertain Cases

When bias motivation is unclear:
- Report as a hate crime if objective facts support bias determination
- Do not require proof beyond reasonable doubt
- Use "preponderance of evidence" standard
- When in doubt, institutions often consult with law enforcement

## Reporting Requirements

### Statistical Reporting

Hate crimes are reported:
- By calendar year
- By geographic category (on-campus, residence halls, noncampus, public property)
- By bias category
- By crime type

### Hierarchy Rule Exception

**Hate crimes are NOT subject to the hierarchy rule**:
- Report each hate crime regardless of other crimes in the same incident
- If multiple bias categories motivate one crime, select one and note others in caveat

### Multiple Bias Motivations

When a single hate crime is motivated by multiple biases:
- Select one bias for the data table
- Note additional biases in the caveat/notes
- Example: A crime motivated by both race and religion bias would be counted once with one bias selected

### Data Variables (Portal Format)

In Portal mirror parquet files:

| Variable | Type | Description |
|----------|------|-------------|
| `crime_type` | Integer | Crime type code (1-18, 99) |
| `bias` | Integer | Bias category code (1-9, 99) |
| `on_campus_hate_crimes` | Integer | Count on campus |
| `residence_hall_hate_crimes` | Integer | Count in residence halls |
| `non_campus_hate_crimes` | Integer | Count at noncampus properties |
| `public_property_hate_crimes` | Integer | Count on public property |
| `other_hate_crimes` | Integer | Count in other locations |
| `total_hate_crimes` | Integer | Total across all locations |

**Filtering Example**:
```python
import polars as pl

# Race-based intimidation crimes
df.filter(
    (pl.col("bias") == 1) &  # Race
    (pl.col("crime_type") == 14)  # Intimidation
)
```

## Historical Changes

### 2008 Changes

Effective with 2008 calendar year:
- Added larceny-theft, simple assault, intimidation, and destruction/damage/vandalism as hate crime-only offenses

### 2013 Changes (VAWA)

Effective with 2014 calendar year:
- Added gender identity as a bias category
- Separated national origin and ethnicity into distinct categories

**Pre-2014 Data**:
- National origin and ethnicity were combined
- Gender identity was not a separate category
- Comparisons across this period require caution

## Interpretation Guidance

### What Hate Crime Statistics Show

- Crimes where evidence of bias motivation was present
- Reported to Campus Security Authorities or law enforcement
- Meeting Clery definitions and geography requirements

### What They Do NOT Show

- All bias-motivated incidents on campus
- Microaggressions or bias incidents not rising to criminal level
- Incidents not reported to appropriate officials
- Incidents where bias could not be established

### Contextual Factors

**Low Numbers May Indicate**:
- Actual low incidence of hate crimes
- Underreporting
- Failure to identify bias motivation
- Victims not recognizing incidents as crimes

**Higher Numbers May Indicate**:
- More hate crime activity
- Better reporting mechanisms
- Better identification of bias motivation
- Greater trust in reporting systems

### Research Considerations

- Hate crime statistics are particularly sensitive to reporting culture
- Small absolute numbers make statistical analysis challenging
- Single incidents can significantly affect institutional statistics
- Year-to-year variation may not indicate trends
