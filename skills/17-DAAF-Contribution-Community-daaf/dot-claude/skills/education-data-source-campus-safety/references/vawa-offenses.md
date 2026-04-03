# VAWA Offenses: Dating Violence, Domestic Violence, and Stalking

## Background

The Violence Against Women Reauthorization Act (VAWA) of 2013 amended the Clery Act to require institutions to:
- Collect and report statistics on dating violence, domestic violence, and stalking
- Implement prevention and awareness programs
- Establish procedures for handling these offenses
- Provide written notification of victim rights and resources

These requirements took effect with the 2014 calendar year (reported in 2015).

## Dating Violence

### Definition

**Federal Definition** (34 U.S.C. 12291(a)(10)):
Violence committed by a person who is or has been in a social relationship of a romantic or intimate nature with the victim. The existence of such a relationship shall be determined based on the reporting party's statement and with consideration of the length of the relationship, the type of relationship, and the frequency of interaction between the persons involved in the relationship.

### Key Elements

**Relationship Requirement**:
- Must be romantic or intimate in nature
- Can be current or former relationship
- Determination based on victim's statement
- Considers length, type, and frequency of interaction

**Violence**:
- Includes actual physical harm
- Includes threatened physical harm
- May include sexual violence within the relationship

### What Constitutes a Dating Relationship

**Factors Considered**:
- Self-identification by parties as dating
- Romantic or intimate involvement
- Length of relationship
- Frequency of interaction
- Type of interaction

**May Include**:
- Casual dating
- Serious committed relationships
- Non-cohabiting romantic relationships
- Short-term romantic involvement

**Does Not Include**:
- Ordinary fraternization (acquaintances, co-workers)
- Friendship without romantic element
- Family relationships (see Domestic Violence)

### Distinction from Domestic Violence

Dating violence applies when the relationship is **romantic/intimate but does not meet domestic violence criteria**:
- Parties have never lived together
- Not in any of the familial/household categories

## Domestic Violence

### Definition

**Federal Definition** (34 U.S.C. 12291(a)(8)):
A felony or misdemeanor crime of violence committed by:
- A current or former spouse or intimate partner of the victim
- A person with whom the victim shares a child in common
- A person who is cohabitating with, or has cohabitated with, the victim as a spouse or intimate partner
- A person similarly situated to a spouse of the victim under the domestic or family violence laws of the jurisdiction in which the crime of violence occurred
- Any other person against an adult or youth victim who is protected from that person's acts under the domestic or family violence laws of the jurisdiction in which the crime of violence occurred

### Key Elements

**Relationship Categories**:
1. Current or former spouse/intimate partner
2. Person sharing a child with victim
3. Current or former cohabitant (as spouse/intimate partner)
4. Person similarly situated to spouse under state law
5. Person covered under state domestic/family violence laws

**Crime Requirement**:
- Must be a crime of violence (felony or misdemeanor)
- Violence committed by person in one of the enumerated relationships

### State Law Considerations

The definition incorporates state domestic/family violence laws, which vary significantly:

**Common State Variations**:
- Some states include same-sex relationships explicitly
- Some states include dating relationships under domestic violence
- Some states include family members beyond spouses
- Age requirements may vary

**Implication for Clery**:
Institutions must understand their state's definition of domestic violence and who is protected under state law.

## Stalking

### Definition

**Federal Definition** (34 U.S.C. 12291(a)(30)):
Engaging in a course of conduct directed at a specific person that would cause a reasonable person to:
- Fear for the person's safety or the safety of others; or
- Suffer substantial emotional distress

### Key Elements

**Course of Conduct**:
- Two or more acts
- Including but not limited to: following, monitoring, observing, surveilling, threatening, communicating, or interfering with property

**Directed at Specific Person**:
- Targeted behavior toward an identifiable victim

**Reasonable Person Standard**:
- Would a reasonable person in similar circumstances feel fear or substantial distress?
- Not what the actual victim felt
- Objective standard

### Examples of Stalking Conduct

**Following/Surveillance**:
- Physical following
- Appearing at victim's workplace, home, classes
- Monitoring movements through GPS or tracking
- Using surveillance equipment

**Communication**:
- Repeated unwanted phone calls
- Excessive text messages or emails
- Social media harassment
- Sending unwanted gifts

**Threats**:
- Direct threats of harm
- Threats to family, friends, pets
- Implied threats through behavior

**Property Interference**:
- Damaging victim's property
- Entering victim's residence
- Tampering with victim's vehicle

### Cyberstalking

Stalking conducted through electronic means:
- Email harassment
- Social media monitoring
- Location tracking apps
- Hacking accounts
- Creating fake profiles

**Note**: Cyberstalking is counted if it occurs within Clery geography OR if any act in the course of conduct occurred in Clery geography.

### Counting Stalking

**One Count Per Victim**:
- Stalking is counted once per victim regardless of the number of acts
- If stalking continues into a new calendar year, it may be counted in both years

**Geographic Considerations**:
- Count if ANY act in the course of conduct occurred in Clery geography
- Does not require ALL acts to occur in Clery geography

## Reporting Requirements

### Statistical Reporting

VAWA offenses are reported:
- By calendar year
- By geographic category (on-campus, residence halls, noncampus, public property)
- Separately from hierarchy rule (all VAWA offenses counted even when other crimes occur)

### Common Variable Names

| Variable | Description |
|----------|-------------|
| `domestic_violence` | Domestic violence incidents |
| `dating_violence` | Dating violence incidents |
| `stalking` | Stalking incidents |

With location suffixes:
- `_oncampus`
- `_residencehall` or `_studenthousing`
- `_noncampus`
- `_publicproperty`

### Hierarchy Rule Exception

**VAWA offenses are NEVER subject to the hierarchy rule**:
- If dating violence includes aggravated assault: count both
- If domestic violence results in murder: count both
- Always count VAWA offense separately

### Overlap with Sex Offenses

Some incidents may constitute both a sex offense AND a VAWA offense:

**Example**: A rape committed by a dating partner would be counted as:
- 1 Rape (sex offense category)
- 1 Dating violence (VAWA category)

This is not double-counting—they are different statutory categories.

## Policy Requirements

### Required Policies (Beyond Statistics)

Institutions must have written policies addressing:

**Primary Prevention Programs**:
- Orientation programs
- Ongoing awareness campaigns
- Bystander intervention training
- Risk reduction information

**Reporting Options**:
- How and where to report
- Options for confidential reporting
- Options to report to law enforcement

**Victim Services**:
- Available resources (counseling, health, advocacy)
- Options for academic accommodations
- Housing modifications
- Employment accommodations

**Disciplinary Procedures**:
- Standard of evidence
- Procedural rights for both parties
- Range of sanctions
- Appeals process

## Data Limitations

### Underreporting Concerns

VAWA offenses have particularly high underreporting rates:

**Reasons for Underreporting**:
- Fear of retaliation
- Concern about confidentiality
- Relationship with perpetrator
- Shame or self-blame
- Lack of awareness that conduct is reportable
- Concern about consequences for perpetrator
- Fear of not being believed

**Research Context**:
Studies consistently show that campus sexual assault, dating violence, domestic violence, and stalking are significantly underreported. Clery statistics represent only crimes reported to CSAs or law enforcement, which is a fraction of actual incidents.

### Comparability Issues

**Pre-2014 Data**:
- VAWA offenses not reported before 2014
- No historical baseline for comparison

**Institutional Variation**:
- Awareness campaigns may increase reporting (higher numbers = better reporting, not necessarily more crime)
- Support services availability affects reporting willingness
- Campus culture impacts disclosure rates

### Trend Interpretation

**Caution**: Increases in VAWA offense statistics may reflect:
- Improved reporting mechanisms
- Better victim support services
- More effective awareness campaigns
- Changes in campus climate encouraging disclosure

They do not necessarily indicate increases in actual incidents.
