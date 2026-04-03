# Sport-Level EADA Data

Guide to analyzing EADA data at the individual sport level.

## Overview

EADA collects data not just at the institution level, but for each varsity sport offered. This enables:
- Sport-specific equity analysis
- Comparison of similar sports across genders
- Investment patterns by sport type

## Sports Covered

### NCAA Sports (Common)

| Men's Sports | Women's Sports | Coed Sports |
|--------------|----------------|-------------|
| Baseball | Softball | Rifle |
| Basketball | Basketball | Equestrian |
| Cross Country | Cross Country | Fencing |
| Football | Field Hockey | Skiing |
| Golf | Golf | |
| Ice Hockey | Ice Hockey | |
| Lacrosse | Lacrosse | |
| Soccer | Soccer | |
| Swimming & Diving | Swimming & Diving | |
| Tennis | Tennis | |
| Track & Field (Indoor) | Track & Field (Indoor) | |
| Track & Field (Outdoor) | Track & Field (Outdoor) | |
| Volleyball | Volleyball | |
| Wrestling | Rowing | |
| | Gymnastics | |
| | Water Polo | |

### Emerging/Other Sports

Institutions may report additional sports:
- Beach Volleyball
- Bowling
- Triathlon
- Acrobatics & Tumbling
- Esports (some institutions)
- Club sports elevated to varsity

## Sport-Level Variables

### For Each Sport

| Variable Type | What's Reported |
|---------------|-----------------|
| Participation | Number of participants |
| Operating Expenses | Game-day expenses |
| Head Coaches | Number by gender and status |
| Assistant Coaches | Number by gender and status |
| Recruiting Expenses | Recruiting budget |
| Total Expenses | All expenses for the sport |
| Revenues | Revenue generated |

### Sport Identification

Sports are identified by:
- Sport name/code
- Classification (men's, women's, coed)

## Meaningful Sport Comparisons

### Equivalent Sports

Compare the same sport across genders for more meaningful equity analysis:

| Men's Sport | Women's Equivalent |
|-------------|-------------------|
| Basketball | Basketball |
| Soccer | Soccer |
| Tennis | Tennis |
| Golf | Golf |
| Swimming & Diving | Swimming & Diving |
| Cross Country | Cross Country |
| Track & Field | Track & Field |
| Lacrosse | Lacrosse |
| Ice Hockey | Ice Hockey |
| Volleyball (rare) | Volleyball |

### Non-Equivalent Sports

Some sports don't have direct equivalents:

| Men's Only | Women's Only |
|------------|--------------|
| Football | Field Hockey |
| Baseball | Softball |
| Wrestling | Rowing (predominantly) |
| | Gymnastics (predominantly) |

### Football Considerations

Football significantly impacts aggregate statistics:
- Large rosters (85-120 players)
- High operating costs
- High coaching costs
- Dominates men's totals

**Analysis Tip**: Consider analyzing with and without football:

```python
# All sports
total_exp_men = sum(all_mens_sports_expenses)

# Excluding football
non_football_exp_men = total_exp_men - football_expenses
```

## Sport-Level Analysis Examples

### Per-Participant Investment

Compare equivalent sports:

```python
# Basketball comparison
basketball_men_per_athlete = basketball_men_exp / basketball_men_partic
basketball_women_per_athlete = basketball_women_exp / basketball_women_partic

# Investment ratio
basketball_ratio = basketball_women_per_athlete / basketball_men_per_athlete
```

### Coaching Resources

```python
# Coaches per athlete by sport
coaches_per_athlete_men = (
    sport_hdcoach_men + sport_asstcoach_men
) / sport_partic_men

coaches_per_athlete_women = (
    sport_hdcoach_women + sport_asstcoach_women
) / sport_partic_women
```

### Recruiting Investment

```python
# Recruiting per slot
recruiting_per_athlete_men = sport_recruiting_men / sport_partic_men
recruiting_per_athlete_women = sport_recruiting_women / sport_partic_women
```

## Sport Categories for Analysis

### By Revenue Potential

| Category | Sports |
|----------|--------|
| Revenue | Football, Men's Basketball, (some) Women's Basketball |
| Olympic | Swimming, Track, Soccer, Tennis, Golf, etc. |
| Emerging | Beach Volleyball, Triathlon, Acrobatics |

### By Roster Size

| Category | Example Sports | Typical Roster |
|----------|----------------|----------------|
| Large | Football | 85-120 |
| Medium | Soccer, Lacrosse, Track | 25-60 |
| Small | Tennis, Golf, Gymnastics | 8-20 |

### By Expense Profile

| Category | Characteristics |
|----------|-----------------|
| High Travel | Ice Hockey (less common), non-conference sports |
| Facility-Intensive | Swimming, Ice Hockey, Gymnastics |
| Equipment-Intensive | Football, Ice Hockey |
| Lower Expense | Cross Country, Tennis |

## Title IX and Sport Sponsorship

### Counting for Participation

Each sport opportunity counts toward participation equity. Institutions may:
- Add women's sports to improve ratios
- Reduce men's sports (controversial)
- Adjust roster sizes

### "Roster Management"

Practice of managing team sizes to affect ratios:
- Capping men's team rosters
- Expanding women's team rosters
- Adding participants vs. meaningful opportunities

**EADA Data Limitation**: Cannot distinguish meaningful participation from roster padding.

## Sport-Specific Trends

### Growing Women's Sports

- Lacrosse
- Beach Volleyball
- Triathlon
- Acrobatics & Tumbling

### Declining Sports

- Men's gymnastics
- Men's wrestling (some regions)
- Men's swimming (some institutions)

### Emerging Issues

- NIL (Name, Image, Likeness) impact
- Transfer portal effects
- Scholarship distribution changes

## Cross-Sport Analysis

### Building Sport-Level Dataset

```python
# Example: Aggregating sport-level data
sports_data = []
for sport in institution_sports:
    sports_data.append({
        'sport_name': sport.name,
        'gender': sport.gender,
        'participation': sport.participation,
        'expenses': sport.total_expenses,
        'revenue': sport.revenue,
        'coaches': sport.total_coaches
    })
```

### Comparison Framework

For each equivalent sport pair:
1. Compare participation counts
2. Compare per-athlete expenses
3. Compare coaching resources
4. Compare recruiting investment
5. Note revenue differences (context, not justification)

## Limitations of Sport-Level Data

### Shared Resources

Some resources are shared and hard to allocate:
- Training facilities
- Academic support
- Medical staff
- Administrative overhead

### Timing Issues

- Different seasons mean different timing of expenses
- Multi-sport athletes complicated
- Year-to-year roster variation

### Reporting Variations

- How expenses are allocated varies by institution
- Some sports combined (e.g., Track Indoor/Outdoor)
- Emerging sports may be inconsistently reported

## Best Practices for Sport Analysis

1. **Compare equivalent sports** when possible
2. **Consider roster size** differences
3. **Analyze with and without football**
4. **Look at per-athlete metrics** not just totals
5. **Track trends** across multiple years
6. **Note context** (conference, region, institutional mission)
