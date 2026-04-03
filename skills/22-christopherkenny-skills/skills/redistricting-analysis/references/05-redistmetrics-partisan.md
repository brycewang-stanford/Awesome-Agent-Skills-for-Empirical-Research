# redistmetrics — Partisan Fairness Metrics

## Overview

`redistmetrics` provides a suite of partisan fairness measures for evaluating how district plans translate votes into seats. These all require election data columns (typically `ndv` for Democratic votes and `nrv` for Republican votes, as provided by the ALARM datasets). All work with `pl()` in `mutate()` pipelines.

## Vote Share Basics

Before computing partisan metrics, understand what columns you're working with:

```r
# Standard ALARM column names
map$ndv    # total Democratic votes (summed across recent elections)
map$nrv    # total Republican votes

# Two-party Democratic vote share for a district
dvs <- ndv / (ndv + nrv)   # values ~0.5 = competitive, >0.5 = Dem-leaning
```

Some metrics aggregate across districts, some return one value per district.

## Efficiency Gap

Measures wasted votes — the difference in wasted votes (votes for losing candidate + votes beyond 50%+1 for the winner) between the two parties, as a fraction of total votes. Negative = Republican advantage.

```r
plans <- plans |>
  mutate(egap = part_egap(pl(), ndv, nrv))
# Returns one value per plan (plan-level scalar)
```

```r
# Seats-votes version (uses projected seat share instead of actual seats)
plans <- plans |>
  mutate(egap_sv = part_egap_sv(pl(), ndv, nrv))
```

## Mean-Median Difference

Difference between the mean and median district-level Democratic vote share. Positive values favor Democrats; negative values favor Republicans. Robust to outlier districts.

```r
plans <- plans |>
  mutate(mm = part_mean_median(pl(), ndv, nrv))
# Returns one value per plan
```

## Partisan Bias

At the hypothetical 50% statewide vote share, what fraction of seats does each party win? Bias = Democratic seat share - 0.5. Negative = Republican advantage.

```r
plans <- plans |>
  mutate(bias = part_bias(pl(), ndv, nrv))
```

## Declination

Measures asymmetry in the geographic distribution of party vote shares across districts. Compares the "angle" of Democratic vs. Republican district vote distributions. Values near 0 = symmetric.

```r
plans <- plans |>
  mutate(decl = part_decl(pl(), ndv, nrv))
```

## Responsiveness

Measures how much seat share changes in response to a 1-point swing in vote share. Higher responsiveness means the plan is more proportional to vote swings.

```r
plans <- plans |>
  mutate(resp = part_resp(pl(), ndv, nrv))
```

## Partisan Advantage (Seat Share)

Count Democratic seats directly:

```r
plans <- plans |>
  mutate(
    dem_seats = part_dseats(pl(), ndv, nrv),   # expected Dem seats
    rep_seats = part_rseats(pl(), ndv, nrv)    # expected Rep seats
  )
```

## District-Level Vote Shares

To get district-level vote shares (one value per district per plan):

```r
plans <- plans |>
  mutate(dvs = part_dvs(pl(), ndv, nrv))    # Dem two-party vote share per district
```

## Multiple Elections

The ALARM datasets include multiple election cycles. Compute metrics for each and average for robustness:

```r
# If you have multiple election columns (e.g., gov18, sen18, pre20)
plans <- plans |>
  mutate(
    egap_gov18 = part_egap(pl(), gov18_dem, gov18_rep),
    egap_sen18 = part_egap(pl(), sen18_dem, sen18_rep),
    egap_pre20 = part_egap(pl(), pre20_dem, pre20_rep),
    egap_avg = (egap_gov18 + egap_sen18 + egap_pre20) / 3
  )
```

## Comparing Enacted Plan to Baseline

```r
library(ggplot2)

# Efficiency gap distribution with enacted plan highlighted
enacted_egap <- plans |> filter(draw == 'Enacted') |> pull(egap) |> unique()

plans |>
  filter(draw != 'Enacted') |>
  ggplot(aes(egap)) +
  geom_histogram(bins = 40) +
  geom_vline(xintercept = enacted_egap, color = 'red', linewidth = 1) +
  labs(x = 'Efficiency Gap', title = 'Simulated distribution vs. enacted plan')
```

## Summary Table

| Function | Returns | Interpretation |
|----------|---------|---------------|
| `part_egap()` | plan-level | Wasted vote diff; <0 = Rep advantage |
| `part_egap_sv()` | plan-level | Seats-votes efficiency gap |
| `part_mean_median()` | plan-level | Mean−median; <0 = Rep advantage |
| `part_bias()` | plan-level | Seat bias at 50% vote; <0 = Rep advantage |
| `part_decl()` | plan-level | Geometric asymmetry measure |
| `part_resp()` | plan-level | Responsiveness to vote swings |
| `part_dseats()` | plan-level | Projected Democratic seat count |
| `part_dvs()` | district-level | Democratic two-party vote share |

## See Also

- Compactness metrics: [04-redistmetrics-compactness.md](04-redistmetrics-compactness.md)
- Splits, minority representation, other metrics: [06-redistmetrics-other.md](06-redistmetrics-other.md)
- Pre-built election data: [12-alarmdata.md](12-alarmdata.md)
